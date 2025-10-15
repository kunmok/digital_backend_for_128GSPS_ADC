
`timescale 1ns/1ps

// A hybrid synchronous/asychronous counter. The LSB bits are implemented as a sychronous
// addition while all other bits are implemented as an asychronous chained flip-flop counter

// No auto creation of nets
`default_nettype none

module hybrid_counter(
        clk,
        reset,
        step,
        count
    );

    //-----------------------------------------------------------------------------------
    //  Parameters
    //-----------------------------------------------------------------------------------
    parameter Width =           41;
    parameter SyncWidth =       4;      // Number of bits added synchronously, which
                                        // also sets the bit-width of the step port
    //-----------------------------------------------------------------------------------
    
    //-----------------------------------------------------------------------------------
    //  I/O
    //-----------------------------------------------------------------------------------
    input wire                  clk;
    input wire                  reset;
    input wire  [SyncWidth-1:0] step;
    output reg  [Width-1:0]     count;
    //-----------------------------------------------------------------------------------

    //-----------------------------------------------------------------------------------
    //  Variables
    //-----------------------------------------------------------------------------------
    genvar                      i;
    //-----------------------------------------------------------------------------------

    //-----------------------------------------------------------------------------------
    //  Signals
    //-----------------------------------------------------------------------------------
    wire    [SyncWidth:0]       sync_add_sum;
    //-----------------------------------------------------------------------------------
            
    //-----------------------------------------------------------------------------------
    //  Assigns
    //-----------------------------------------------------------------------------------
    assign sync_add_sum =       count[SyncWidth-1:0] + step;
    //-----------------------------------------------------------------------------------

    //-----------------------------------------------------------------------------------
    //  Synchronous Counter
    //-----------------------------------------------------------------------------------
    always @(posedge clk or posedge reset) begin
        if (reset) count[SyncWidth-1:0] <= {SyncWidth{1'b0}};
        else count[SyncWidth-1:0] <= sync_add_sum[SyncWidth-1:0];
    end
    //-----------------------------------------------------------------------------------
    
    //-----------------------------------------------------------------------------------
    //  Asynchronous Counter
    //-----------------------------------------------------------------------------------
    // First bit of the asychronous counter
    always @(posedge clk or posedge reset) begin
        if (reset) count[SyncWidth] <= 1'b0;
        else if (sync_add_sum[SyncWidth]) count[SyncWidth] <= ~count[SyncWidth];
    end
    
    // The rest of the async counter bits
    generate for (i = SyncWidth + 1; i < Width; i = i + 1) begin: gen_async_count
        always @(negedge count[i-1] or posedge reset) begin
            if (reset) count[i] <= 1'b0;
            else count[i] <= ~count[i];
        end
    end endgenerate
    //-----------------------------------------------------------------------------------

endmodule

