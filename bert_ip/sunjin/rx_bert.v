
`timescale 1ns/1ps

// A Rx-side BERT, using pattern generators for each way
// For DataWidths > Ways (such that a multi-bit PRBS is used), the input bits
// have an LSB->MSB bit ordering

// WARNING: MAKE SURE A SERIALIZER/DESERIALIZER OF THE COMPATIBLE BIT ORDERING IS USED

module rx_bert(
	// clock and reset
	i_clk,
	i_rst,
	i_en,
	
	// data input from deserializer
	i_data_in,

	// prbs generator configs
	i_cfg_prbs_en,
	i_cfg_prbs_load_en,
	i_cfg_prbs_seed_en,
	i_cfg_prbs_run_en,
	i_cfg_prbs_seed_inv,
	i_cfg_prbs_out_inv,
	i_cfg_prbs_load_in,

	// prbs generator flag
	o_prbs_seed_good,        

	// bert config
	i_cfg_ber_mode,
	i_cfg_ber_count_en,
	i_cfg_ber_shutoff_sel,
	i_cfg_ber_data_inv,
	
	// bert output
	o_ber_shutoff,
	o_ber_count,
	o_bit_count        
);

//-----------------------------------------------------------------------------------
//  Parameters
//-----------------------------------------------------------------------------------
parameter DataWidth = 8;
parameter PRBSLength = 31;
//-----------------------------------------------------------------------------------

//-----------------------------------------------------------------------------------
//  Constants
//-----------------------------------------------------------------------------------
// DataWidth=8 corresponds to MWidth 4
localparam MWidth = `log2(DataWidth + 1);

localparam BERCountWidth = 41;
localparam ShutoffSelWidth = 4;
localparam ShutoffBit0 = 10;
localparam ShutoffBit1 = 20;
localparam ShutoffBit2 = 30;
localparam ShutoffBit3 = 40;
//-----------------------------------------------------------------------------------

//-----------------------------------------------------------------------------------
//  I/O
//-----------------------------------------------------------------------------------
input wire i_clk;
input wire i_rst;
input wire i_en;

input wire [DataWidth-1:0] i_data_in;

// prbs generator
input wire i_cfg_prbs_en;
input wire i_cfg_prbs_load_en;
input wire i_cfg_prbs_seed_en;
input wire i_cfg_prbs_run_en;
input wire i_cfg_prbs_seed_inv;
input wire i_cfg_prbs_out_inv;
input wire [PRBSLength-1:0] i_cfg_prbs_load_in;

output wire o_prbs_seed_good;

// bert config
input wire i_cfg_ber_mode;
input wire i_cfg_ber_count_en;
input wire [ShutoffSelWidth-1:0] i_cfg_ber_shutoff_sel;
input wire i_cfg_ber_data_inv;

output reg o_ber_shutoff;
output wire [BERCountWidth-1:0] o_ber_count;
output wire [BERCountWidth-1:0] o_bit_count;
//-----------------------------------------------------------------------------------

//-----------------------------------------------------------------------------------
//  Variables
//-----------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------

//-----------------------------------------------------------------------------------
//  Signals
//-----------------------------------------------------------------------------------
wire [DataWidth-1:0] bert_data_in;
wire [DataWidth-1:0] bert_data_correct;

reg [DataWidth-1:0] bert_data_test_in; 

reg cfg_ber_count_en_sync;
//reg cfg_ber_count_en_sync_d;    
//reg snap_en_sync;

// bit counter
wire [MWidth-1:0] bitcounter_step;
//-----------------------------------------------------------------------------------    

//-----------------------------------------------------------------------------------
//  Assigns
//-----------------------------------------------------------------------------------    
// data inversion by a chicken bit
assign bert_data_in = (i_cfg_ber_data_inv) ? {DataWidth{1'b1}} ^ i_data_in : i_data_in;

// bit counter step should be equal to DataWidth
// TODO: can I assign parameter to wire?
assign bitcounter_step = 1'b1 << `log2(DataWidth);
//-----------------------------------------------------------------------------------
	
//-----------------------------------------------------------------------------------
// Input Cfg Synchronizers
//-----------------------------------------------------------------------------------    
// Keep ber counts off if we shutoff
// So that we can shut off BER and bit counter as it reaches the point selected by
// i_cfg_ber_shutoff_sel
always @(posedge i_clk or posedge i_rst) begin
	if (i_rst) cfg_ber_count_en_sync <= 1'b0;
	else if (i_en) cfg_ber_count_en_sync <= i_cfg_ber_count_en & ~o_ber_shutoff;
end
//-----------------------------------------------------------------------------------
	
//-----------------------------------------------------------------------------------
// Instantiate Pattern Generators
//-----------------------------------------------------------------------------------
//pattern_generator_cfg_wrapper
//			#   (   .OutBits        (DataWidth),
//					.PattLength     (PattLength),
//					.PRBSLength     (PRBSLength))
//	pgen        (   .i_clk          (i_clk),
//					.i_rst          (i_rst),
//					.cfg            (i_cfg_pgen),
//					.pgen_seed_in   (bert_data_in),
//					.prbs_seed_good (o_prbs_seed_good),
//					.data_out       (bert_data_correct);

// feeds datastream into prbs generator for self-seeding mode
prbs 		#  	( 	.OutBits 		(DataWidth),
					.Length 		(PRBSLength))
	prbsgen 	( 	.clk 			(i_clk),
					.reset 			(i_rst),
					.en 			(i_cfg_prbs_en),
					.load 			(i_cfg_prbs_load_en),
					.load_in 		(i_cfg_prbs_load_in),
					.seed 			(i_cfg_prbs_seed_en),
					.seed_inv 		(i_cfg_prbs_seed_inv),
					.seed_in 		(bert_data_in),
					.seed_good 		(o_prbs_seed_good),
					.run 			(i_cfg_prbs_run_en),
					.out_inv 		(i_cfg_prbs_out_inv),
					.out 			(bert_data_correct));
//-----------------------------------------------------------------------------------

//-----------------------------------------------------------------------------------
// Delay matching with self-seeding path
//-----------------------------------------------------------------------------------
// Adds a one cycle delay to the test bits, this just delay matches the self-seeding
// path through the pattern generator with the tested path
always @(posedge i_clk or posedge i_rst) begin
	if (i_rst) bert_data_test_in <= {DataWidth{1'b0}};
	else if (i_en) bert_data_test_in <= bert_data_in;
end
//-----------------------------------------------------------------------------------

//-----------------------------------------------------------------------------------
// Instantiate BERs
//-----------------------------------------------------------------------------------
// Add 1 cycle delay before BER block and snapshot
// TODO : Why do we need this?
//reg rst_del;
//reg cfg_ber_mode_del;
//reg cfg_ber_count_en_sync_del;
reg [DataWidth-1:0] bert_data_test_in_del;
reg [DataWidth-1:0] bert_data_correct_del;

always @(posedge i_clk or posedge i_rst) begin
	if (i_rst) begin
		bert_data_test_in_del <= {DataWidth{1'b0}};
		bert_data_correct_del <= {DataWidth{1'b0}};
	end
	else if (i_en) begin
		bert_data_test_in_del <= bert_data_test_in;
		bert_data_correct_del <= bert_data_correct;
	end
end

ber         #   (   .InWidth        (DataWidth),
					.CountWidth     (BERCountWidth))                         
	ber_inst    (   .clk 			(i_clk),
					.reset 			(i_rst),
					.mode           (i_cfg_ber_mode),
					.enable         (cfg_ber_count_en_sync),
					.in_test        (bert_data_test_in_del),
					.in_correct     (bert_data_correct_del),
					.ber_count      (o_ber_count));
//-----------------------------------------------------------------------------------

// Deprecated - snapshot is instantiated at higher level
////-----------------------------------------------------------------------------------
////  Snapshot For Each Way
////-----------------------------------------------------------------------------------
//generate for (i = 0; i < Ways; i = i + 1) begin: gen_snap 
//    snapshot    #   (   .PWidth         (SnapLength),
//                        .SWidth         (DataWidth))
//            snap    (   .i_clk            (i_clk),
//                        .i_rst          (1'b0),
//                        .en             (snap_en_sync_del[i]),
//                        .i_data_in        (bert_data_test_in_del[i]),
//                        .data_snap      (snap_out[SnapLength*i +: SnapLength]));    
//end endgenerate
////-----------------------------------------------------------------------------------

// Deprecated - You needed this block for multi-way BERT
////-----------------------------------------------------------------------------------
//// Delay match bit counter and error counter
////-----------------------------------------------------------------------------------
//// Enables the total # of bits counter 1 cycle after all the others, since there is a
//// one cycle delay between when BER count enable turns on and when the bits reach the
//// BER tester to get tested and errors counted
//always @(posedge i_clk or posedge i_rst) begin
//	if (i_rst) cfg_ber_count_en_sync_d <= 1'b0;
//	else cfg_ber_count_en_sync_d <= cfg_ber_count_en_sync;
//end
////-----------------------------------------------------------------------------------

//-----------------------------------------------------------------------------------
//  Total Number of Bits Per Way Counter
//-----------------------------------------------------------------------------------
hybrid_counter  #   (   .Width      (BERCountWidth),
						.SyncWidth  (MWidth))
		bit_counter (   .clk 		(i_clk),
						.reset 		(i_rst),
						.step       ((cfg_ber_count_en_sync) ? bitcounter_step : {MWidth{1'b0}}),
						.count      (o_bit_count));
//-----------------------------------------------------------------------------------

//-----------------------------------------------------------------------------------
//  Shutoff Selector
//-----------------------------------------------------------------------------------    
// Decide when to shutoff BER and counter through scan-config bits
always @(posedge i_clk or posedge i_rst) begin
	if (i_rst) o_ber_shutoff <= 1'b0;
	else if (i_en) o_ber_shutoff <= |( i_cfg_ber_shutoff_sel & 
										{   o_bit_count[ShutoffBit3],
											o_bit_count[ShutoffBit2],
											o_bit_count[ShutoffBit1],
											o_bit_count[ShutoffBit0]    });            
end
//-----------------------------------------------------------------------------------

//-----------------------------------------------------------------------------------
//  Consistency Check
//-----------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------

endmodule

