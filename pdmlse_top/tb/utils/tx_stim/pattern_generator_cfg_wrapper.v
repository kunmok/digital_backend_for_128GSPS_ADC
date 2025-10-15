
`timescale 1ns/1ps

// No auto creation of nets
`default_nettype none

// Config wrapper for the pattern generator, including sychronization registers
// This is designed to be backwards compatible with the old PRBS.v configuration scheme
// For each pgen_cfg_unit, the variable X = max(PRBSLength, PattLength)
// pgen_cfg[X+3]    = Output invert
// pgen_cfg[X+2]    = Self-seed enable
// pgen_cfg[X+1]    = Run (1) / Load seed (0)
// pgen_cfg[X]      = Pattern mode (1) / PRBS (0)
// pgen_cfg[X-1:0]  = Starting seed, where X = max(PRBSLength, PattLength)
//
// Only the config registers are resettable
// The PRBS/Pattern registers are not resettable

module pattern_generator_cfg_wrapper(
        clk,
        reset,
        cfg,

        prbs_seed_good,        
        pgen_seed_in,        
        data_out
    );

    
    //-----------------------------------------------------------------------------------
    //  Parameters
    //-----------------------------------------------------------------------------------
    // Number of output bits / cycle
    parameter OutBits =             16;

    // Pattern/PRBS configurations
    parameter PattLength =          32;
    parameter PRBSLength =          31;  
    //-----------------------------------------------------------------------------------
    
    //-----------------------------------------------------------------------------------
    //  Constants
    //-----------------------------------------------------------------------------------
    localparam SeedLength =         `max(PattLength, PRBSLength);
    localparam CfgBits =            4 + SeedLength;
    //-----------------------------------------------------------------------------------
    
    //-----------------------------------------------------------------------------------
    //  I/O
    //-----------------------------------------------------------------------------------
    input wire                      clk;
    input wire                      reset;    
    input wire  [CfgBits-1:0]       cfg;

    output wire                     prbs_seed_good; // Indicates whether PRBS's have self-seeded to a good state
    input wire  [OutBits-1:0]       pgen_seed_in;        
    output wire [OutBits-1:0]       data_out;
    //-----------------------------------------------------------------------------------

    //-----------------------------------------------------------------------------------
    //  Signals
    //-----------------------------------------------------------------------------------
    reg                             out_inv, seed, run, pattern;
    //-----------------------------------------------------------------------------------
    
    //-----------------------------------------------------------------------------------
    //  Assigns
    //-----------------------------------------------------------------------------------    
    //-----------------------------------------------------------------------------------
        
    //-----------------------------------------------------------------------------------
    //  Input Cfg Synchronizers
    //-----------------------------------------------------------------------------------
    always @(posedge clk or posedge reset) begin
        if (reset) {out_inv, seed, run, pattern} <= 4'b000;
        else {out_inv, seed, run, pattern} <= cfg[CfgBits-1:SeedLength];
    end
    //-----------------------------------------------------------------------------------
    
    //-----------------------------------------------------------------------------------
    //  Pattern Generator For Each Way
    //-----------------------------------------------------------------------------------
    pattern_generator       #   (   .OutBits        (OutBits),
                                    .PattLength     (PattLength),
                                    .PRBSLength     (PRBSLength))
                                    
                         pgen    (  .clk            (clk),
                                    .reset          (1'b0),
                                    
                                    .load           (~run),
                                    .load_in        (cfg[SeedLength-1:0]),

                                    .seed           (seed),
                                    .seed_in        (pgen_seed_in),
                                    .seed_inv       (1'b0),
                                    .prbs_seed_good (prbs_seed_good),
                                    
                                    .pattern        (pattern),
                                    .run            (run),
                                    .out            (data_out),
                                    .out_inv        (out_inv));
    //-----------------------------------------------------------------------------------

    //-----------------------------------------------------------------------------------
    //  Consistency Check
    //-----------------------------------------------------------------------------------
    //-----------------------------------------------------------------------------------
        
endmodule

