module Scan_reset (reset, reset_value, enable, data_in, out);

parameter WIDTH = 16;
input enable;
input reset;
input [WIDTH-1:0] data_in;
input [WIDTH-1:0] reset_value;
output reg [WIDTH - 1:0] out;


always @(negedge enable or posedge reset) begin
    if (reset) begin
        out <= reset_value;
    end else begin
  	    out <= data_in[WIDTH-1 : 0];
    end
end



endmodule
