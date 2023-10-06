`ifndef TOP_H
`define TOP_H


`include "utils.v"
`include "sample_fetch.v"
`include "coef_buffer.v"
`include "mux_array.v"
`include "compmul_array.v"
`include "accumulator.v"

// ##################################################
// Name        Width   Dir     Comment
// --------------------------------------------------
// Clk         1       In      Rising edge clock
// Reset       1       In      Active high reset signal
// PushIn      1       In      A sample push signal
// SampI       24      In      The real part of the sample in 1.23 format
// SampQ       24      In      The imaginary part of the sample in 1.23 format
// PushCoef    1       In      Indicates loading a coefficient
// CoefAddr    5       In      The coefficient location 0-15 valid 
// CoefI       27      In      The coefficient Real part 3.24 format
// CoefQ       27      In      The coefficient Imaginary part 3.24 format
// StopIn      1       Out     The input cannot accept a sample
// PushOut     1       Out     Data out of the filter.
// FI          32      Out     Real filtered output 8.24 format
// FQ          32      Out     Imaginary filtered output 8.24 format
// ##################################################


// All design parameters/macros are defined in utils.v

module firc(input wire Clk,
            input wire Reset,
            input wire PushIn,
            output wire StopIn,
            input wire [`S_WIDTH-1:0] SampI,
            input wire [`S_WIDTH-1:0] SampQ,
            input wire PushCoef,
            input wire [$clog2(`N_TAPS)-1:0] CoefAddr, 
            input wire [`C_WIDTH-1:0] CoefI, 
            input wire [`C_WIDTH-1:0] CoefQ, 
            output wire PushOut, 
            output wire [`R_WIDTH-1:0] FI, 
            output wire [`R_WIDTH-1:0] FQ
           );

  wire busy_mux;
  wire last_mux_group; // mux gave out the last group 
  wire canShift = last_mux_group;
  reg sampleEmpty;

  // clk 1 -> enters FIFO
  // clk 2 -> enters shiftreg
  wire [(`S_WIDTH*`N_TAPS)-1:0] sampBuffI;
  wire [(`S_WIDTH*`N_TAPS)-1:0] sampBuffQ;
  Sample_Fetch #(.S_WIDTH(`S_WIDTH), .S_DEPTH(`N_TAPS)) sample_fetch(
    .clk(Clk),
    .reset(Reset),
    .incoming(PushIn&~StopIn),
    .sampI(SampI),
    .sampQ(SampQ),
    .canShift(canShift),
    .shiftRegI(sampBuffI),
    .shiftRegQ(sampBuffQ),
    .stopOut(StopIn),
    .empty(sampleEmpty)
  );

  wire [`C_WIDTH*`N_TAPS_HALF-1:0] coefBuffI;
  Coef_Buffer #(.WIDTH(`C_WIDTH), .DEPTH(`N_TAPS_HALF)) coef_buffer_I(
    .clk(Clk),
    .reset(Reset),
    .load(PushCoef),
    .loadidx(CoefAddr),
    .datain(CoefI),
    .dataout(coefBuffI)
  );

  wire [`C_WIDTH*`N_TAPS_HALF-1:0] coefBuffQ;
  Coef_Buffer #(.WIDTH(`C_WIDTH), .DEPTH(`N_TAPS_HALF)) coef_buffer_Q(
    .clk(Clk),
    .reset(Reset),
    .load(PushCoef),
    .loadidx(CoefAddr),
    .datain(CoefQ),
    .dataout(coefBuffQ)
  );

  wire [(`S_WIDTH*`C_PAIR_SIZE)-1:0] sampMuxI; // intentionally C_PAIR
  wire [(`S_WIDTH*`C_PAIR_SIZE)-1:0] sampMuxQ; // intentionally C_PAIR
  wire [(`C_WIDTH*`C_PAIR_SIZE)-1:0] coefMuxI;
  wire [(`C_WIDTH*`C_PAIR_SIZE)-1:0] coefMuxQ;

  Mux_Controller 
  #(.C_WIDTH(`C_WIDTH),
    .S_WIDTH(`S_WIDTH),
    .C_DEPTH(`N_TAPS_HALF),
    .S_DEPTH(`N_TAPS),
    .S_MUXES(`S_PAIR_SIZE), 
    .C_MUXES(`C_PAIR_SIZE))
  mux_controller(
    .clk(Clk),
    .reset(Reset),
    .empty(sampleEmpty),
    .coef_inI(coefBuffI),
    .coef_inQ(coefBuffQ),
    .samp_inI(sampBuffI),
    .samp_inQ(sampBuffQ),
    .coef_outI(coefMuxI),
    .coef_outQ(coefMuxQ),
    .samp_outI(sampMuxI),
    .samp_outQ(sampMuxQ),
    .busy(busy_mux),
    .last(last_mux_group)
  );

  // clk 3 -> enters cmul
  wire [`S_WIDTH+`C_WIDTH:0] r0I, r1I, r2I, r3I, r4I;
  wire [`S_WIDTH+`C_WIDTH:0] r0Q, r1Q, r2Q, r3Q, r4Q;
  wire busy_cmul;
  CompMul_Array #(.S_WIDTH(`S_WIDTH), .C_WIDTH(`C_WIDTH), .MUXES(`C_PAIR_SIZE)) compmul_array
  (
    .clk(Clk),
    .reset(Reset),
    .busy_in(last_mux_group& PushIn),
    .coef_inI(coefMuxI),
    .coef_inQ(coefMuxQ),
    .samp_inI(sampMuxI),
    .samp_inQ(sampMuxQ),

    .r0I(r0I),
    .r1I(r1I),
    .r2I(r2I),
    .r3I(r3I),
    .r4I(r4I),

    .r0Q(r0Q),
    .r1Q(r1Q),
    .r2Q(r2Q),
    .r3Q(r3Q),
    .r4Q(r4Q),

    .busy_out(busy_cmul)
  );

  // clk 7 -> enters acc 
  wire [55:0] finalOutI, finalOutQ;
  assign FI = finalOutI[55:(55-32)];
  assign FQ = finalOutQ[55:(55-32)];
  Accumulator accmulator(
    .clk(Clk),
    .reset(Reset),
    .valid(busy_cmul),

    .r0I(r0I),
    .r1I(r1I),
    .r2I(r2I),
    .r3I(r3I),
    .r4I(r4I),

    .r0Q(r0Q),
    .r1Q(r1Q),
    .r2Q(r2Q),
    .r3Q(r3Q),
    .r4Q(r4Q),

    .pushOut(PushOut),
    .finalOutI(finalOutI),
    .finalOutQ(finalOutQ)
  );

  // clk 10 -> output


  ////////////////////////////////////////////////////////////////////////////////////////////////////
  //
  //initial begin
  //    $dumpfile("waves.vcd");
  //    $dumpvars(0);
  //end

  //integer poutCount = 0;
  //always@(posedge PushOut) begin
  //    $display("pushout, sample %d  @%t", ++poutCount, $time); 
  //end

  //integer stopCount = 0;
  //always@(negedge StopIn) begin
  //    $display("stopIn, sample %d  @%t", ++stopCount, $time); 
  //end

  ////////////////////////////////////////////////////////////////////////////////////////////////////

endmodule


`endif
