
`timescale 1ns/1ps

// No auto creation of nets
`default_nettype none

// A PRBS implemented using an LFSR with self-seeding and modes featuring parametrized
// number of parallel bit outputs, with the restriction that
// 1. Number of outputs bits cannot be > PRBS Length
// 2. More restrictions as I find them out

// the output corresponds to the parallel output bits
// IMPORTANT NOTE: 
// the order in which the bits should be read, compared to the order a 1-bit PRBS
// outputs the bits is LSB to MSB

// Make sure that the PRBS matrix is defined
`ifndef PRBSMatrix
    //TODO: I want this to cause an error
`endif

module prbs(
	clk,
	reset,
	en,
	
	load,
	load_in,

	seed,
	seed_in,
	seed_inv,
	seed_good,
	
	run,
	out,
	out_inv
);

    //-----------------------------------------------------------------------------------
    //  Parameters
    //-----------------------------------------------------------------------------------
    parameter Length =          31;
    parameter OutBits =         16;
    parameter ResetSeed =       {Length{1'b0}};        // The state the PRBS is reset to
    //-----------------------------------------------------------------------------------
    
    //-----------------------------------------------------------------------------------
    //  Constants
    //-----------------------------------------------------------------------------------
    localparam Matrix =         `PRBSMatrix(Length, OutBits);
    //-----------------------------------------------------------------------------------

    //-----------------------------------------------------------------------------------
    //  I/O
    //-----------------------------------------------------------------------------------
    input wire                  clk;
    input wire                  reset;
	input wire 					en;

    input wire                  load;       // Load a PRBS seed
    input wire  [Length-1:0]    load_in;
    
    input wire                  seed;       // Self-seed the PRBS
    input wire  [OutBits-1:0]   seed_in;    
    input wire                  seed_inv;    
    output wire                 seed_good;  // Is the seed a good PRBS seed
    
    input wire                  run;        // Run the PRBS
    output wire [OutBits-1:0]   out;
    input wire                  out_inv;
    //-----------------------------------------------------------------------------------

    //-----------------------------------------------------------------------------------
    //  Variables
    //-----------------------------------------------------------------------------------
    integer i;
    genvar j;
    //-----------------------------------------------------------------------------------

    //-----------------------------------------------------------------------------------
    //  Signals
    //-----------------------------------------------------------------------------------
    reg         [Length-1:0]    shift_reg; 
    reg         [Length-1:0]    next_shift_reg;
    //-----------------------------------------------------------------------------------
    
    //-----------------------------------------------------------------------------------
    //  Assigns
    //-----------------------------------------------------------------------------------
    assign out =                {OutBits{out_inv}} ^ shift_reg[Length-1:Length-OutBits];
    // Detects whether we have a good seed(at least one 1)
    assign seed_good =          |shift_reg;
    //-----------------------------------------------------------------------------------
        
    //-----------------------------------------------------------------------------------
    //  LFSR Next-state Logic
    //-----------------------------------------------------------------------------------
    always @(*) begin
        next_shift_reg = shift_reg;
        // Load a seed
        if (load) next_shift_reg = load_in;
        // Put PRBS in self-seeding mode
        else if (seed) next_shift_reg = {{OutBits{seed_inv}} ^ seed_in, shift_reg[Length-1:OutBits]};
        // Run the PRBS with the current seed
        else if (run) begin
            for (i = 0; i < Length; i = i + 1) begin
                next_shift_reg[i] = ^(shift_reg & Matrix[i*Length +: Length]);
            end
        end 
    end
    //-----------------------------------------------------------------------------------
    
    //-----------------------------------------------------------------------------------
    //  LFSR
    //-----------------------------------------------------------------------------------
    always @ (posedge clk or posedge reset) begin
        if (reset) shift_reg <= ResetSeed;
        else if (en) shift_reg <= next_shift_reg;
    end
    //-----------------------------------------------------------------------------------

    //-----------------------------------------------------------------------------------
    //  Consistency Check
    //-----------------------------------------------------------------------------------
    `ifdef NCVLOG
    initial begin
        if (OutBits >= Length) begin
            $display("CONSISTENCY ERROR: Current implementation does not support ouput bits (%d) greater than or equal to the PRBS length (%d)",
                OutBits, Length);
            $finish;
        end
    end
    `endif
    //-----------------------------------------------------------------------------------
        
endmodule

