
    module subclk ( input reset, 
     input scan_in, input scan_en,
     input scan_clk, output [11:0] addr_out, output[10:0] scan_en_sub, output [10:0] scan_in_sub, output reg [139:0] scan_in_data_reg, input take_scanout_data, input [139:0] scan_out_mux_output);
    parameter ADDR0 = 'd0;
parameter ADDR1 = 'd1;
parameter ADDR2 = 'd2;
parameter ADDR3 = 'd3;
parameter ADDR4 = 'd4;
parameter ADDR5 = 'd5;
parameter ADDR6 = 'd6;
parameter ADDR7 = 'd7;
parameter ADDR8 = 'd8;
parameter ADDR9 = 'd9;
parameter ADDR10 = 'd10;
reg [3:0] count;
reg [2:0] state;
reg [11:0] addr_chain;
reg [11:0] addr;
reg [10:0] scan_en_dec;
assign addr_out = addr;
reg [7:0] bit_counter;
reg first_bit;
assign scan_en_sub = {11{scan_en}} & scan_en_dec;
always @(negedge scan_clk or posedge reset) begin
	if (reset) begin
		scan_en_dec = 0;
	end else begin
	case(addr)
	ADDR0: scan_en_dec = 11'd1;
	ADDR1: scan_en_dec = 11'd2;
	ADDR2: scan_en_dec = 11'd4;
	ADDR3: scan_en_dec = 11'd8;
	ADDR4: scan_en_dec = 11'd16;
	ADDR5: scan_en_dec = 11'd32;
	ADDR6: scan_en_dec = 11'd64;
	ADDR7: scan_en_dec = 11'd128;
	ADDR8: scan_en_dec = 11'd256;
	ADDR9: scan_en_dec = 11'd512;
	ADDR10: scan_en_dec = 11'd1024;
	default: scan_en_dec = 0;
	endcase
end
end

    always @(posedge scan_clk or posedge reset) begin
        
        if (reset) begin
            count <= 0;
            state <= 3'b000;
            addr <= 0;
            addr_chain <= 0;
            scan_in_data_reg <= 0;
            first_bit <= 0;
        end else begin
        
    	case (state)
    		3'b000: begin 
scan_in_data_reg <= {scan_in_data_reg[139:0], scan_in};
 
    			count <= 2'b00;
    			if (scan_en == 1'b0) begin
    				state <= 3'b000;
    				addr <= 12'b0000;
    			end else begin
    				state <= 3'b001;
    				addr_chain <= {addr_chain[11:0], scan_in};
    			end
    		end
    		3'b001 : begin 
scan_in_data_reg <= {scan_in_data_reg[139:0], scan_in};

    			if (scan_en == 1'b0) begin
          	        state <= 3'b000;
                    addr <= 12'b0000;
    			end else if (scan_en && (count == 10)) begin
    				addr_chain <= {addr_chain[11:0], scan_in};
    				addr <= {addr_chain[11:0], scan_in};
                    state <= 3'b010;
                    count <= 2'b00;
                    first_bit <= 0;
    			end else if (scan_en) begin
          	        state <= 3'b001;
                    count <= count + 1;
    				addr_chain <= {addr_chain[11:0], scan_in};
    			end
    		end
    		3'b010: begin
                if (take_scanout_data && (first_bit == 0)) begin
                    scan_in_data_reg <= scan_out_mux_output;
                    first_bit <= 1;
                end else begin
                    scan_in_data_reg <= {scan_in_data_reg[139:0], scan_in};
                end
    			if (scan_en == 1'b0) begin 
scan_in_data_reg <= {scan_in_data_reg[139:0], scan_in};

    				state <= 'b000;
    				addr <= 'b0000;
    			end
    		end
    	default: begin 
scan_in_data_reg <= {scan_in_data_reg[139:0], scan_in};

            state <= 'b000;
        end
    	endcase
        end

    end 

endmodule
