`ifndef FIFO_H
`define FIFO_H

`include "utils.v"

module Fifo #(parameter WIDTH = 24,
              DEPTH = 4)
             (input wire clk,
              input wire reset,
              input wire push,
              input wire pop,
              input wire [WIDTH-1:0] datain,
              output reg [WIDTH-1:0] dataout,
              output reg full,
              output reg empty);
    
    // Note if the depth is non-power-of-2, this code needs modification
    // because then read/write pointers won't loop around properly
    
    reg [$clog2(DEPTH)-1:0] w_ptr, r_ptr;
    reg [WIDTH-1:0] fifo_arr[DEPTH];
    
    // Set Default values on reset.
    always@(posedge clk) begin
        if (reset) begin
            w_ptr   <= 0;
            r_ptr   <= 0;
            dataout <= 0;
        end
        else begin
            // To write data to FIFO
            if (push & !full)begin
                fifo_arr[w_ptr] <= datain;
                w_ptr           <= w_ptr + 1;
            end
            
            // To read data from FIFO
            if (pop & !empty) begin
                dataout <= fifo_arr[r_ptr];
                r_ptr   <= r_ptr + 1;
            end
        end
    end
    
    assign full  = ((w_ptr+1'b1) == r_ptr);
    assign empty = (w_ptr == r_ptr);
    
endmodule
    
    `endif
