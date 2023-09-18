`ifndef SAMPLE_FETCH_H
`define SAMPLE_FETCH_H

`include "utils.v"
`include "fifo.v"
`include "shift_reg.v"

module Sample_Fetch #(S_WIDTH = 24,
                      S_DEPTH = 29)
                    (input wire clk,
                      input wire reset,
                      input wire incoming,
                      input wire [S_WIDTH-1:0] sampI,
                      input wire [S_WIDTH-1:0] sampQ,
                      input wire canShift,
                      output wire [(S_WIDTH*S_DEPTH)-1:0] shiftRegI, output wire [(S_WIDTH*S_DEPTH)-1:0] shiftRegQ, output wire stopOut, output reg empty);
    
    
    wire fifoI_full, fifoI_empty;
    wire fifoQ_full, fifoQ_empty;
    
    wire doShift = canShift && ~(fifoI_empty | fifoQ_empty); // move sample from fifo to shiftreg
    wire doPopI  = doShift && !fifoI_empty; // pop one sample
    wire doPopQ  = doShift && !fifoQ_empty;
    wire doPushI = incoming && !fifoI_full; // push incoming sample
    wire doPushQ = incoming && !fifoQ_full;
    
    // tell the input side to stop when there's no empty placeholder
    assign stopOut = fifoI_full | fifoQ_full; // actually both will always become full at the same time

    always@(posedge clk) begin
        if(reset)
            empty <= 1'b1;
        else
            empty <= fifoI_empty | fifoQ_empty;
    end
    
    wire [S_WIDTH-1:0] getI;
    wire [S_WIDTH-1:0] getQ;
    
    // samples are in Q1.23 format (1 sign-bit, 0 decimal-bits, 23 fraction-bits)
    // push : can only do that when there's no empty, and...
    // pop : handled by shift register(slow side)
    Fifo #(.WIDTH(S_WIDTH), .DEPTH(4)) fifo_I(
    .clk(clk),
    .reset(reset),
    .push(doPushI),
    .pop(doPopI),
    .datain(sampI),
    .dataout(getI),
    .empty(fifoI_empty),
    .full(fifoI_full)
    );
    
    Fifo #(.WIDTH(S_WIDTH), .DEPTH(4)) fifo_Q(
    .clk(clk),
    .reset(reset),
    .push(doPushQ),
    .pop(doPopQ),
    .datain(sampQ),
    .dataout(getQ),
    .empty(fifoQ_empty),
    .full(fifoQ_full)
    );
    
    Shift_Register #(.DEPTH(S_DEPTH), .WIDTH(S_WIDTH)) shift_register_I(
    .clk(clk),
    .reset(reset),
    .serial_in(getI),
    .shift(doShift),
    .parallel_out(shiftRegI)
    );
    
    Shift_Register #(.DEPTH(S_DEPTH), .WIDTH(S_WIDTH)) shift_register_Q(
    .clk(clk),
    .reset(reset),
    .serial_in(getQ),
    .shift(doShift),
    .parallel_out(shiftRegQ)
    );
    
endmodule
    
    `endif
