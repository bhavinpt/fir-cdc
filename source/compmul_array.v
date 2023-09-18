`ifndef COMPMUL_ARRAY_H
`define COMPMUL_ARRAY_H

`include "utils.v"
`include "DW02_mult_2_stage.v"

module CompMul #(A_WIDTH = 24,
    B_WIDTH = 27)
    (input clk, reset,
        input signed [A_WIDTH-1:0] aI,   
        input signed [A_WIDTH-1:0] aQ,   
        input signed [B_WIDTH-1:0] bI,   
        input signed [B_WIDTH-1:0] bQ,   
        output reg signed [A_WIDTH+B_WIDTH:0] resI, 
        output reg signed [A_WIDTH+B_WIDTH:0] resQ  
    );

    wire signed [A_WIDTH+B_WIDTH-1:0] temp1, temp2, temp3, temp4;

    //stage1 & 2
    DW02_mult_2_stage #(A_WIDTH,B_WIDTH) ko(aI,bI,1'b1,clk,temp1);
    DW02_mult_2_stage #(A_WIDTH,B_WIDTH) k1(aQ,bQ,1'b1,clk,temp2);
    DW02_mult_2_stage #(A_WIDTH,B_WIDTH) k2(aI,bQ,1'b1,clk,temp3);
    DW02_mult_2_stage #(A_WIDTH,B_WIDTH) k3(aQ,bI,1'b1,clk,temp4);
    
    always@(posedge clk)  begin
		//stage3
        resI <= temp1 - temp2;
		resQ <= temp3 + temp4;
	end
 
 endmodule  



module CompMul_Array #(S_WIDTH = 24,
    C_WIDTH = 27,
    MUXES = 5)
    (input wire clk,
        input wire reset,
        input wire busy_in,
        input wire [(C_WIDTH*MUXES)-1:0] coef_inI,
        input wire [(C_WIDTH*MUXES)-1:0] coef_inQ,
        input wire [(S_WIDTH*MUXES)-1:0] samp_inI,
        input wire [(S_WIDTH*MUXES)-1:0] samp_inQ,

        output wire [C_WIDTH+S_WIDTH:0] r0I,
        output wire [C_WIDTH+S_WIDTH:0] r1I,
        output wire [C_WIDTH+S_WIDTH:0] r2I,
        output wire [C_WIDTH+S_WIDTH:0] r3I,
        output wire [C_WIDTH+S_WIDTH:0] r4I,

        output wire [C_WIDTH+S_WIDTH:0] r0Q,
        output wire [C_WIDTH+S_WIDTH:0] r1Q,
        output wire [C_WIDTH+S_WIDTH:0] r2Q,
        output wire [C_WIDTH+S_WIDTH:0] r3Q,
        output wire [C_WIDTH+S_WIDTH:0] r4Q,
        output wire busy_out
    );

    wire [S_WIDTH-1:0] sampI[MUXES];
    wire [S_WIDTH-1:0] sampQ[MUXES];
    wire [C_WIDTH-1:0] coefI[MUXES];
    wire [C_WIDTH-1:0] coefQ[MUXES];

    genvar i;
    generate
    for(i = 0; i < MUXES; i+= 1) begin // 0, 1, 2, 3, 4
        assign sampI[i] = `SLICE(samp_inI, i, S_WIDTH);
        assign sampQ[i] = `SLICE(samp_inQ, i, S_WIDTH);
        assign coefI[i] = `SLICE(coef_inI, i, C_WIDTH);
        assign coefQ[i] = `SLICE(coef_inQ, i, C_WIDTH);
    end
    endgenerate

    reg [4:0] busy_sr;
    assign busy_out = busy_sr[4];
    always@(posedge clk) begin
        if(reset) begin
            busy_sr <= 'b0;
        end
        else begin
            //busy_sr <= {busy_sr[0], busy_in};
            busy_sr <= (busy_sr << 1) | busy_in;
        end
    end

    CompMul #(.A_WIDTH(S_WIDTH), .B_WIDTH(C_WIDTH)) mul0(.clk(clk), .reset(reset), .aI(sampI[0]), .aQ(sampQ[0]), .bI(coefI[0]), .bQ(coefQ[0]), .resI(r0I), .resQ(r0Q));
    CompMul #(.A_WIDTH(S_WIDTH), .B_WIDTH(C_WIDTH)) mul1(.clk(clk), .reset(reset), .aI(sampI[1]), .aQ(sampQ[1]), .bI(coefI[1]), .bQ(coefQ[1]), .resI(r1I), .resQ(r1Q));
    CompMul #(.A_WIDTH(S_WIDTH), .B_WIDTH(C_WIDTH)) mul2(.clk(clk), .reset(reset), .aI(sampI[2]), .aQ(sampQ[2]), .bI(coefI[2]), .bQ(coefQ[2]), .resI(r2I), .resQ(r2Q));
    CompMul #(.A_WIDTH(S_WIDTH), .B_WIDTH(C_WIDTH)) mul3(.clk(clk), .reset(reset), .aI(sampI[3]), .aQ(sampQ[3]), .bI(coefI[3]), .bQ(coefQ[3]), .resI(r3I), .resQ(r3Q));
    CompMul #(.A_WIDTH(S_WIDTH), .B_WIDTH(C_WIDTH)) mul4(.clk(clk), .reset(reset), .aI(sampI[4]), .aQ(sampQ[4]), .bI(coefI[4]), .bQ(coefQ[4]), .resI(r4I), .resQ(r4Q));

    endmodule


`endif
