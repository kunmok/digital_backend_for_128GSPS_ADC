
`timescale 1ns/1ps

// Snapshot, which is really just a simple shift register

// No auto creation of nets
`default_nettype none

module snapshot(
        clk,
        reset,
        en,
        data_in,
        data_snap
    );

    //-----------------------------------------------------------------------------------
    //  Parameters
    //-----------------------------------------------------------------------------------
    parameter PWidth =          32;
    parameter SWidth =          1;
    //-----------------------------------------------------------------------------------
    
    //-----------------------------------------------------------------------------------
    //    I/O
    //-----------------------------------------------------------------------------------
    input wire                  clk;
    input wire                  reset;
    input wire                  en;
    input wire  [SWidth-1:0]    data_in;
    output reg  [PWidth-1:0]    data_snap;
    //-----------------------------------------------------------------------------------
    
    //-----------------------------------------------------------------------------------
    //  Data Snapshot shift Register
    //-----------------------------------------------------------------------------------
    always @(posedge clk or posedge reset) begin
        if (reset) data_snap <= {PWidth{1'b0}};
        else if (en) data_snap <= {data_in, data_snap[PWidth-1:SWidth]};
    end
    //-----------------------------------------------------------------------------------
endmodule
