`ifndef COEF_BUFFER_H
`define COEF_BUFFER_H

`include "utils.v"

module Coef_Buffer #(WIDTH = 27,
                     DEPTH = 4)
                    (input wire clk,
                     input wire reset,
                     input wire load,
                     input wire [$clog2(DEPTH):0] loadidx,
                     input wire [WIDTH-1:0] datain,
                     output reg [(WIDTH*DEPTH)-1:0] dataout);
    
    reg [WIDTH-1:0] buffer [DEPTH-1:0];
    integer i;
    
    genvar j;
    generate
    for(j = 0; j < DEPTH; j++) begin
        assign `SLICE(dataout, j, WIDTH)              = buffer[j];
        //assign dataout[(WIDTH*(j+1))-1 : (WIDTH*j)] = buffer[j]; // this works too
    end
    endgenerate
    
    always @(posedge clk) begin
        if (reset) begin
            for(i = 0; i < DEPTH; i++) begin
                buffer[i] <= 0;
            end
        end
        else begin
            if (load && loadidx != 0) begin
                buffer [loadidx-1] <= datain;
            end
        end
    end
    
endmodule
    
    
    `endif
