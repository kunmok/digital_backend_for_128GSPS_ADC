
`timescale 1ns/1ps

// A Rx-side BERT, using pattern generators for each way
// For DataWidths > Ways (such that a multi-bit PRBS is used), the input bits
// have an LSB->MSB bit ordering

// WARNING: MAKE SURE A SERIALIZER/DESERIALIZER OF THE COMPATIBLE BIT ORDERING IS USED

// The pgen_cfg field is split into N cfg_units, where N is the number of ways
// Each pgen_cfg_unit is a bit vector representing the configuration for the pattern
// generator of that unit
// Example: {pgen_cfg_unit[N-1], pgen_cfg_unit[N-2], ... , pgen_cfg_unit[1], pgen_cfg_unit[0]} = pgen_cfg

// The snapshot is not resettable

module rx_bert(
        clk,
        reset,
        
        pgen_cfg,
        snap_en,
        ber_mode,
        ber_count_enable,
        ber_shutoff_sel,
        ber_invert_data,
        
        prbs_seed_good,        
        
        data_in,
        snap_out,
        
        ber_shutoff,
        ber_count,
        bit_count        
    );

    //-----------------------------------------------------------------------------------
    //  Parameters
    //-----------------------------------------------------------------------------------
    parameter SnapLength =              32;
    parameter PattLength =              32;
    parameter PRBSLength =              31;
    parameter DataWidth =               8;
    parameter Ways =                    2;

    parameter BERCountWidth =           41;
    //-----------------------------------------------------------------------------------
    
    //-----------------------------------------------------------------------------------
    //  Constants
    //-----------------------------------------------------------------------------------
    localparam BitsPerWay =             DataWidth / Ways;
    
    localparam SeedLength =             `max(PattLength, PRBSLength);
    localparam PGenCfgBits =            4 + SeedLength;
    localparam TotPGenCfgBits =         Ways * PGenCfgBits;    
    localparam TotSnapLength =          Ways * SnapLength;
    localparam TotBERCountWidth =       Ways * BERCountWidth; 
    localparam MWidth =                 `log2(BitsPerWay + 1);
    
    localparam ShutoffSelWidth =        4;

    localparam ShutoffBit0 =            10;
    localparam ShutoffBit1 =            20;
    localparam ShutoffBit2 =            30;
    localparam ShutoffBit3 =            40;
    //-----------------------------------------------------------------------------------

    //-----------------------------------------------------------------------------------
    //  I/O
    //-----------------------------------------------------------------------------------
    input wire                          clk;
    input wire                          reset;

    input wire  [TotPGenCfgBits-1:0]    pgen_cfg;
    input wire  [Ways-1:0]              snap_en;
    input wire  [Ways-1:0]              ber_mode;
    input wire  [Ways-1:0]              ber_count_enable;
    input wire  [ShutoffSelWidth-1:0]   ber_shutoff_sel;
    input wire                          ber_invert_data;

    output wire [Ways-1:0]              prbs_seed_good;
    
    input wire  [DataWidth-1:0]         data_in;
    output wire [TotSnapLength-1:0]     snap_out;

    output reg                          ber_shutoff;
    output wire [TotBERCountWidth-1:0]  ber_count;
    output wire [BERCountWidth-1:0]     bit_count;
    //-----------------------------------------------------------------------------------

    //-----------------------------------------------------------------------------------
    //  Variables
    //-----------------------------------------------------------------------------------
    genvar i, j;
    //-----------------------------------------------------------------------------------

    //-----------------------------------------------------------------------------------
    //  Signals
    //-----------------------------------------------------------------------------------
    wire        [BitsPerWay-1:0]        way_bits            [Ways-1:0];
    wire        [BitsPerWay-1:0]        way_bits_correct    [Ways-1:0];

    wire        [DataWidth-1:0]         data_in_bar;

    reg         [BitsPerWay-1:0]        way_bits_test       [Ways-1:0];

    wire        [PGenCfgBits-1:0]       pgen_cfg_unit       [Ways-1:0];

    reg         [Ways-1:0]              ber_count_enable_sync;
    reg                                 ber_count_enable_sync_d;    
    reg         [Ways-1:0]              snap_en_sync;
    

    assign data_in_bar[DataWidth-1:0] = ~data_in[DataWidth-1:0];

    //-----------------------------------------------------------------------------------    

    //-----------------------------------------------------------------------------------
    //  Assigns
    //-----------------------------------------------------------------------------------    
    // Reorder the bits based on how the PRBS ways are set up
    generate for (i = 0; i < Ways; i = i + 1) begin: gen_ways
        for (j = 0; j < BitsPerWay; j = j + 1) begin: gen_way_bits
        //support data inversion
            assign way_bits[i][j] =     (ber_invert_data) ? data_in_bar[j*Ways + i] : data_in[j*Ways + i];
        end
    end endgenerate
    
    // Pattern Generator Configuration unit splitting
    generate for (i = 0; i < Ways; i = i + 1) begin: gen_cfg_unit
        assign pgen_cfg_unit[i] =       pgen_cfg[PGenCfgBits*i +: PGenCfgBits];        
    end endgenerate    
    //-----------------------------------------------------------------------------------
        
    //-----------------------------------------------------------------------------------
    //  Input Cfg Synchronizers
    //-----------------------------------------------------------------------------------    
    always @(posedge clk or posedge reset) begin
        if (reset) snap_en_sync <= {Ways{1'b0}};
        else snap_en_sync <= snap_en;
    end
    
    // Keep ber counts off if we shutoff
    always @(posedge clk or posedge reset) begin
        if (reset) ber_count_enable_sync <= {Ways{1'b0}};
        else ber_count_enable_sync <= ber_count_enable & {Ways{~ber_shutoff}};        
    end
    //-----------------------------------------------------------------------------------
        
    //-----------------------------------------------------------------------------------
    //  Instantiate Pattern Generators
    //-----------------------------------------------------------------------------------
    generate for (i = 0; i < Ways; i = i + 1) begin: gen_pgen
        pattern_generator_cfg_wrapper
                    #   (   .OutBits        (BitsPerWay),
                            .PattLength     (PattLength),
                            .PRBSLength     (PRBSLength))
            pgen        (   .clk            (clk),
                            .reset          (reset),
                            .cfg            (pgen_cfg_unit[i]),
                            .pgen_seed_in   (way_bits[i]),
                            .prbs_seed_good (prbs_seed_good[i]),
                            .data_out       (way_bits_correct[i]));
    end endgenerate
    //-----------------------------------------------------------------------------------

    //-----------------------------------------------------------------------------------
    //  Test Bits Delay Flop
    //-----------------------------------------------------------------------------------
    // Adds a one cycle delay to the test bits, this just delay matches the self-seeding
    // path through the pattern generator with the tested path
    generate for (i = 0; i < Ways; i = i + 1) begin: gen_way_bits_test
        always @(posedge clk or posedge reset) begin
            if (reset) way_bits_test[i] <= {BitsPerWay{1'b0}};
            else way_bits_test[i] <= way_bits[i];
        end
    end endgenerate
    //-----------------------------------------------------------------------------------

    //-----------------------------------------------------------------------------------
    //  Instantiate BERs
    //-----------------------------------------------------------------------------------
    
// Add 1 cycle delay before BER block and snapshot
    reg                           reset_del;
    reg   [Ways-1:0]              ber_mode_del;
    reg   [Ways-1:0]              ber_count_enable_sync_del;
    reg   [BitsPerWay-1:0]        way_bits_test_del       [Ways-1:0];
    reg  [BitsPerWay-1:0]        way_bits_correct_del    [Ways-1:0];
    
    reg         [Ways-1:0]              snap_en_sync_del;
 
    generate for (i = 0; i < Ways; i = i + 1) begin: gen_cycle_delay
        always @(posedge clk or posedge reset) begin
        if (reset) begin
            way_bits_test_del[i] <= {BitsPerWay{1'b0}};
        end
        else begin
                reset_del <= reset;
                ber_mode_del[i] <= ber_mode[i];
                ber_count_enable_sync_del[i] <= ber_count_enable_sync[i];
                way_bits_test_del[i] <= way_bits_test[i];
                way_bits_correct_del[i] <= way_bits_correct[i];
                snap_en_sync_del[i] <= snap_en_sync[i];
             end
        end
    end endgenerate


    generate for (i = 0; i < Ways; i = i + 1) begin: gen_ber
        ber         #   (   .InWidth        (BitsPerWay),
                            .CountWidth     (BERCountWidth))                         
            ber_inst    (   .clk            (clk),
                            .reset          (reset_del),                                    
                            .mode           (ber_mode_del[i]),
                            .enable         (ber_count_enable_sync_del[i]),                                    
                            .in_test        (way_bits_test_del[i]),
                            .in_correct     (way_bits_correct_del[i]),                                    
                            .ber_count      (ber_count[BERCountWidth*i +: BERCountWidth]));    
    end endgenerate    
    //-----------------------------------------------------------------------------------

    //-----------------------------------------------------------------------------------
    //  Snapshot For Each Way
    //-----------------------------------------------------------------------------------
    generate for (i = 0; i < Ways; i = i + 1) begin: gen_snap 
        snapshot    #   (   .PWidth         (SnapLength),
                            .SWidth         (BitsPerWay))
                snap    (   .clk            (clk),
                            .reset          (1'b0),
                            .en             (snap_en_sync_del[i]),
                            .data_in        (way_bits_test_del[i]),
                            .data_snap      (snap_out[SnapLength*i +: SnapLength]));    
    end endgenerate
    //-----------------------------------------------------------------------------------
    
    //-----------------------------------------------------------------------------------
    //  Enable Delay Register
    //-----------------------------------------------------------------------------------
    // Enables the total # of bits counter 1 cycle after all the others, since there is a
    // one cycle delay between when BER count enable turns on and when the bits reach the
    // BER tester to get tested and errors counted
    always @(posedge clk or posedge reset) begin
        if (reset) ber_count_enable_sync_d <= 1'b0;
        else ber_count_enable_sync_d <= |ber_count_enable_sync;
    end
    //-----------------------------------------------------------------------------------
    
    //-----------------------------------------------------------------------------------
    //  Total Number of Bits Per Way Counter
    //-----------------------------------------------------------------------------------
    hybrid_counter  #   (   .Width      (BERCountWidth),
                            .SyncWidth  (MWidth))
            bit_counter (   .clk        (clk),
                            .reset      (reset),
                            .step       ((ber_count_enable_sync_d) ? BitsPerWay[MWidth-1:0] : {MWidth{1'b0}}),
                            .count      (bit_count));
    //-----------------------------------------------------------------------------------

    //-----------------------------------------------------------------------------------
    //  Shutoff Selector
    //-----------------------------------------------------------------------------------    
    always @(posedge clk or posedge reset) begin
        if (reset) ber_shutoff <= 1'b0;
        else ber_shutoff <= |( ber_shutoff_sel & 
                                {   bit_count[ShutoffBit3],
                                    bit_count[ShutoffBit2],
                                    bit_count[ShutoffBit1],
                                    bit_count[ShutoffBit0]    });            
    end
    //-----------------------------------------------------------------------------------

    //-----------------------------------------------------------------------------------
    //  Consistency Check
    //-----------------------------------------------------------------------------------
    //-----------------------------------------------------------------------------------
    
endmodule

