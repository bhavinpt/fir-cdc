`ifndef SHIFT_REG_H
`define SHIFT_REG_H

`include "utils.v"

module Shift_Register #(WIDTH = 24,
                        DEPTH = 29)
                       (input wire clk,                               // clock input
                        input wire reset,                             // asynchronous reset input
                        input wire [WIDTH-1:0] serial_in,             // serial data input
                        input wire shift,                             // do the shift
                        output reg [(WIDTH*DEPTH)-1:0] parallel_out); // parallel data output
    
    always @(posedge clk) begin
        if (reset)
        begin
            parallel_out <= 0;
        end
        else
        begin
            if (shift) begin
                parallel_out <= {parallel_out[(WIDTH*(DEPTH-1))-1:0], serial_in};
            end
        end
    end
    
endmodule
    
    `endif
