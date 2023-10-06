`ifndef MUX_CONTROLLER_H
`define MUX_CONTROLLER_H

`include "utils.v"

module Mux_Controller #(S_WIDTH = 24,
                        C_WIDTH = 27,
                        S_DEPTH = 29,
                        C_DEPTH = 15,
                        S_MUXES = 10,
                        C_MUXES = 5)
                       (input wire clk,
                        input wire reset,
                        input wire empty,
                        input wire [(S_WIDTH*S_DEPTH)-1:0] samp_inI, 
                        input wire [(S_WIDTH*S_DEPTH)-1:0] samp_inQ, 
                        input wire [(C_WIDTH*C_DEPTH)-1:0] coef_inI, 
                        input wire [(C_WIDTH*C_DEPTH)-1:0] coef_inQ, 
                        output wire [(S_WIDTH*C_MUXES)-1:0] samp_outI, 
                        output wire [(S_WIDTH*C_MUXES)-1:0] samp_outQ, 
                        output wire [(C_WIDTH*C_MUXES)-1:0] coef_outI, 
                        output wire [(C_WIDTH*C_MUXES)-1:0] coef_outQ, 
                        output wire busy, 
                        output wire last);
    
    
    reg[1:0] group;
    assign busy = ~(&group);
    assign last = (group == 2'b10 || group == 2'b11) ? 1'b1 : 1'b0; // 1x
    always@(posedge clk) begin
        if (reset | empty) begin
            group <= 2'b11;
        end
        else begin
            group <= (group == 2'b10) ? 2'b00 : group + 2'b01;
        end
    end
    
    wire [C_WIDTH-1:0] coefMuxOutI[C_MUXES];
    wire [C_WIDTH-1:0] coefMuxOutQ[C_MUXES];
    wire [S_WIDTH-1:0] sampMuxOutI[S_MUXES];
    wire [S_WIDTH-1:0] sampMuxOutQ[S_MUXES];
    
    genvar c;
    generate
    for(c = 0; c < C_MUXES; c+= 1) begin // 0, 1, 2, 3, 4
        assign coefMuxOutI[c] = 
        (group == 0) ? `SLICE(coef_inI, c,     C_WIDTH):
        (group == 1) ? `SLICE(coef_inI, (c+5) , C_WIDTH):
        (group == 2) ? `SLICE(coef_inI, (c+10), C_WIDTH):
        'b0;
        assign coefMuxOutQ[c] = 
        (group == 0) ? `SLICE(coef_inQ, c,     C_WIDTH):
        (group == 1) ? `SLICE(coef_inQ, (c+5) , C_WIDTH):
        (group == 2) ? `SLICE(coef_inQ, (c+10), C_WIDTH):
        'b0;
        
        assign `SLICE(coef_outI, c, C_WIDTH) = coefMuxOutI[c];
        assign `SLICE(coef_outQ, c, C_WIDTH) = coefMuxOutQ[c];
    end
    endgenerate
    
    
    
    ///////////////////////////////////
    genvar s;
    generate
    // upper half
    for(s = 0; s < S_MUXES/2; s+= 1) begin // 0, 1, 2, 3, 4 : fwd
        assign sampMuxOutI[s] = 
        (group == 0) ? `SLICE(samp_inI, s,     S_WIDTH):
        (group == 1) ? `SLICE(samp_inI, (s+5) , S_WIDTH):
        (group == 2) ? `SLICE(samp_inI, (s+10), S_WIDTH):
        'b0;
        assign sampMuxOutQ[s] = 
        (group == 0) ? `SLICE(samp_inQ, s,     S_WIDTH):
        (group == 1) ? `SLICE(samp_inQ, (s+5) , S_WIDTH):
        (group == 2) ? `SLICE(samp_inQ, (s+10), S_WIDTH):
        'b0;
    end
    endgenerate

    // rest of the lower half
    for(s = S_DEPTH-(S_MUXES/2); s <S_DEPTH; s+= 1) begin // 24, 25, 26, 27, 28: rev
        // one of the middle pair, third input 0
        if (s == S_DEPTH-(S_MUXES/2)) begin
            assign sampMuxOutI[s - (S_DEPTH-S_MUXES)] = 
            (group == 0) ? `SLICE(samp_inI, s,     S_WIDTH):
            (group == 1) ? `SLICE(samp_inI, (s-5) , S_WIDTH):
            'b0;
            assign sampMuxOutQ[s - (S_DEPTH-S_MUXES)] = 
            (group == 0) ? `SLICE(samp_inQ, s,     S_WIDTH):
            (group == 1) ? `SLICE(samp_inQ, (s-5) , S_WIDTH):
            'b0;
        end
        else begin
            assign sampMuxOutI[s - (S_DEPTH-S_MUXES)] = 
            (group == 0) ? `SLICE(samp_inI, s,     S_WIDTH):
            (group == 1) ? `SLICE(samp_inI, (s-5) , S_WIDTH):
            (group == 2) ? `SLICE(samp_inI, (s-10), S_WIDTH):
            'b0;
            assign sampMuxOutQ[s - (S_DEPTH-S_MUXES)] = 
            (group == 0) ? `SLICE(samp_inQ, s,     S_WIDTH):
            (group == 1) ? `SLICE(samp_inQ, (s-5) , S_WIDTH):
            (group == 2) ? `SLICE(samp_inQ, (s-10), S_WIDTH):
            'b0;
        end
    end
    endgenerate
    
    genvar so;
    generate
    for(so = 0; so < C_MUXES; so+= 1) begin // 0, 1, 2, 3, 4
        assign `SLICE(samp_outI, so, S_WIDTH) = sampMuxOutI[so] + sampMuxOutI[S_MUXES-so-1];
        assign `SLICE(samp_outQ, so, S_WIDTH) = sampMuxOutQ[so] + sampMuxOutQ[S_MUXES-so-1];
    end
    endgenerate
    
    
endmodule
    
    
    `endif
