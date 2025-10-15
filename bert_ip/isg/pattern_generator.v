
`timescale 1ns/1ps

// No auto creation of nets
`default_nettype none

// A pattern generator, consisting of a PRBS module and a pattern-generating
// shift-register

module pattern_generator(
        clk,
        reset,
        
        load,
        load_in,        

        seed,
        seed_in,
        seed_inv,
        prbs_seed_good,
        
        pattern,
        run,
        out,
        out_inv
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
    localparam PRBSResetSeed =      {PRBSLength{1'b0}}; // The state the PRBS is reset to
    localparam PattResetSeed =      {PattLength{1'b0}}; // The state the Pattern registers resets to
    //-----------------------------------------------------------------------------------

    //-----------------------------------------------------------------------------------
    //  I/O
    //-----------------------------------------------------------------------------------
    input wire                      clk;
    input wire                      reset;
    
    input wire                      load;
    input wire  [SeedLength-1:0]    load_in;

    input wire                      seed;
    input wire  [OutBits-1:0]       seed_in;
    input wire                      seed_inv;
    output wire                     prbs_seed_good; // Indicates whether the PRBS has self-seeded to a good state
    
    input wire                      pattern;  
    input wire                      run;
    output wire [OutBits-1:0]       out;
    input wire                      out_inv;
    //-----------------------------------------------------------------------------------

    //-----------------------------------------------------------------------------------
    //  Signals
    //-----------------------------------------------------------------------------------
    wire        [OutBits-1:0]       out_patt, out_prbs;    
    reg         [PattLength-1:0]    patt_reg, next_patt_reg; 
    //-----------------------------------------------------------------------------------
    
    //-----------------------------------------------------------------------------------
    //  Assigns
    //-----------------------------------------------------------------------------------
    assign out_patt =               patt_reg[PattLength-1:PattLength-OutBits];
    assign out =                    {OutBits{out_inv}} ^ ((pattern) ? out_patt : out_prbs);
    //-----------------------------------------------------------------------------------
        
    //-----------------------------------------------------------------------------------
    //  Pattern Next-State Logic
    //-----------------------------------------------------------------------------------
    always @(*) begin
        next_patt_reg = patt_reg;
        // Load the seed
        if (load) next_patt_reg = load_in;
        // If it is seeding, shift in the seed
        else if (seed) next_patt_reg = {{OutBits{seed_inv}} ^ seed_in, patt_reg[PattLength-1:OutBits]};
        // Run the pattern if pattern mode is enabled and pattern gen is told to run
        else if (pattern & run) next_patt_reg = {patt_reg[OutBits-1:0], patt_reg[PattLength-1:OutBits]};
    end
    //-----------------------------------------------------------------------------------

    //-----------------------------------------------------------------------------------
    //  Pattern Register
    //-----------------------------------------------------------------------------------
    always @(posedge clk or posedge reset) begin
        if (reset) patt_reg <= PattResetSeed;
        else patt_reg <= next_patt_reg;
    end
    //-----------------------------------------------------------------------------------

    //-----------------------------------------------------------------------------------
    //  PRBS
    //-----------------------------------------------------------------------------------
    prbs            #   (   .Length     (PRBSLength),
                            .OutBits    (OutBits),
                            .ResetSeed  (PRBSResetSeed))
                            
            prbs_unit   (   .clk        (clk),
                            .reset      (reset),
        
                            .load       (load),
                            .load_in    (load_in[PRBSLength-1:0]),

                            .seed       (seed),
                            .seed_in    (seed_in),
                            .seed_inv   (seed_inv),
                            .seed_good  (prbs_seed_good),
        
                            .run        (~pattern & run),
                            .out        (out_prbs),
                            .out_inv    (1'b0));
    //-----------------------------------------------------------------------------------

    //-----------------------------------------------------------------------------------
    //  Consistency Check
    //-----------------------------------------------------------------------------------
    //-----------------------------------------------------------------------------------
        
endmodule

