
`timescale 1ns/1ps

// No auto creation of nets
`default_nettype none

// A Tx-side BERT, using pattern generators for each way
// For DataWidths > Ways (such that a multi-bit PRBS is used), the bits produced
// has an LSB->MSB bit ordering

// WARNING: MAKE SURE A SERIALIZER/DESERIALIZER OF THE COMPATIBLE BIT ORDERING IS USED

// The pgen_cfg field is split into N cfg_units, where N is the number of ways
// Each pgen_cfg_unit is a bit vector representing the configuration for the pattern
// generator of that unit
// Example: {pgen_cfg_unit[N-1], pgen_cfg_unit[N-2], ... , pgen_cfg_unit[1], pgen_cfg_unit[0]} = pgen_cfg

// The snapshot is not resettable

module tx_bert(
        clk,
        reset,
        
        pgen_cfg,
        snap_en,

        prbs_seed_good,        

        pgen_seed_in,        
        data_out,
        snap_in,
        snap_out        
    );

    
    //-----------------------------------------------------------------------------------
    //  Parameters
    //-----------------------------------------------------------------------------------
    parameter SnapLength =              32;
    parameter PattLength =              32;
    parameter PRBSLength =              31;
    parameter DataWidth =               8;
    parameter Ways =                    2;
    //-----------------------------------------------------------------------------------
    
    //-----------------------------------------------------------------------------------
    //  Constants
    //-----------------------------------------------------------------------------------
    localparam BitsPerWay =             DataWidth / Ways;

    localparam SeedLength =             `max(PattLength, PRBSLength);
    localparam PGenCfgBits =            4 + SeedLength;
    localparam TotPGenCfgBits =         Ways * PGenCfgBits;    
    localparam TotSnapLength =          Ways * SnapLength;
    //-----------------------------------------------------------------------------------
    
    //-----------------------------------------------------------------------------------
    //  I/O
    //-----------------------------------------------------------------------------------
    input wire                          clk;
    input wire                          reset;
    
    input wire  [TotPGenCfgBits-1:0]    pgen_cfg;
    input wire  [Ways-1:0]              snap_en;

    input wire  [DataWidth-1:0]         pgen_seed_in;    
    output wire [Ways-1:0]              prbs_seed_good; // Indicates whether PRBS's have self-seeded to a good state
    
    output wire [DataWidth-1:0]         data_out;
    input wire  [DataWidth-1:0]         snap_in;
    output wire [TotSnapLength-1:0]     snap_out;    
    //-----------------------------------------------------------------------------------

    //-----------------------------------------------------------------------------------
    //  Genvars
    //-----------------------------------------------------------------------------------
    genvar                              i, j;
    //-----------------------------------------------------------------------------------

    //-----------------------------------------------------------------------------------
    //  Signals
    //-----------------------------------------------------------------------------------
    wire        [PGenCfgBits-1:0]       pgen_cfg_unit       [Ways-1:0];
    reg         [Ways-1:0]              snap_en_sync;
    
    wire        [BitsPerWay-1:0]        pgen_out_raw        [Ways-1:0];
    wire        [BitsPerWay-1:0]        pgen_seed_in_raw    [Ways-1:0];
    wire        [BitsPerWay-1:0]        snap_in_raw         [Ways-1:0];
    //-----------------------------------------------------------------------------------
    
    //-----------------------------------------------------------------------------------
    //  Assigns
    //-----------------------------------------------------------------------------------    
    generate for (i = 0; i < Ways; i = i + 1) begin: gen_ways
        for (j = 0; j < BitsPerWay; j = j + 1) begin: gen_way_bits
            assign data_out[j*Ways+i] =         pgen_out_raw[i][j];
            assign pgen_seed_in_raw[i][j] =     pgen_seed_in[j*Ways+i];
            assign snap_in_raw[i][j] =          snap_in[j*Ways+i];
        end
    end endgenerate
    
    // Configuration unit splitting
    generate for (i = 0; i < Ways; i = i + 1) begin: gen_cfg_unit
        assign pgen_cfg_unit[i] =               pgen_cfg[PGenCfgBits*i +: PGenCfgBits]; 
    end endgenerate    
    //-----------------------------------------------------------------------------------
        
    //-----------------------------------------------------------------------------------
    //  Input Cfg Synchronizers
    //-----------------------------------------------------------------------------------    
    always @(posedge clk or posedge reset) begin
        if (reset) snap_en_sync <= {Ways{1'b0}};
        else snap_en_sync <= snap_en;
    end        
    //-----------------------------------------------------------------------------------
    
    //-----------------------------------------------------------------------------------
    //  Pattern Generator For Each Way
    //-----------------------------------------------------------------------------------
    generate for (i = 0; i < Ways; i = i + 1) begin: gen_pgen    
        pattern_generator_cfg_wrapper 
                        #   (   .OutBits        (BitsPerWay),
                                .PattLength     (PattLength),
                                .PRBSLength     (PRBSLength)) 
                     pgen   (   .clk            (clk),
                                .reset          (reset),
                                .cfg            (pgen_cfg_unit[i]),
                                .pgen_seed_in   (pgen_seed_in_raw[i]),
                                .prbs_seed_good (prbs_seed_good[i]),
                                .data_out       (pgen_out_raw[i]));
    end endgenerate
    //-----------------------------------------------------------------------------------

    //-----------------------------------------------------------------------------------
    //  Snapshot For Each Way
    //-----------------------------------------------------------------------------------
    generate for (i = 0; i < Ways; i = i + 1) begin: gen_snap 
        snapshot        #   (   .PWidth         (SnapLength),
                                .SWidth         (BitsPerWay))
                    snap    (   .clk            (clk),
                                .reset          (1'b0),
                                .en             (snap_en_sync[i]),
                                .data_in        (snap_in_raw[i]),
                                .data_snap      (snap_out[SnapLength*i +: SnapLength]));    
    end endgenerate
    //-----------------------------------------------------------------------------------

    //-----------------------------------------------------------------------------------
    //  Consistency Check
    //-----------------------------------------------------------------------------------
    //-----------------------------------------------------------------------------------
        
endmodule

