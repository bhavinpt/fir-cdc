

module Accumulator (input wire clk,
              input wire valid,                // reset
              input wire reset,
              input wire [51:0] r0I,
              input wire [51:0] r0Q,
              input wire [51:0] r1I,
              input wire [51:0] r1Q,
              input wire [51:0] r2I,
              input wire [51:0] r2Q,
              input wire [51:0] r3I,
              input wire [51:0] r3Q,
              input wire [51:0] r4I,
              input wire [51:0] r4Q,
              output wire pushOut,
              output wire [55:0] finalOutI,
              output wire [55:0] finalOutQ);
   

          reg [51:0] r4bI;
          reg [51:0] r4bbI;
          reg [52:0] r01I, r23I;
          reg [53:0] r0123I;
          reg [54:0] r01234I;
          reg [55:0] r01234AI;

          reg [51:0] r4bQ;
          reg [51:0] r4bbQ;
          reg [52:0] r01Q, r23Q;
          reg [53:0] r0123Q;
          reg [54:0] r01234Q;
          reg [55:0] r01234AQ;

          reg [55:0] accI;
          reg [55:0] accQ;

          reg [4:0] vBuff;

          assign finalOutI = r01234AI;
          assign finalOutQ = r01234AQ;
          assign pushOut = vBuff[4];

    //always @ (posedge clk) begin
    //    if (reset)
    //        vBuff <= 4'b0;

    //    else
    //        vBuff <= {vBuff[3:0], valid};
    //end

    always@(posedge clk) begin
        if(reset) begin
            vBuff <= 'b0;
           r4bI <= 'b0;
           r4bbI <= 'b0;
           r01I <= 'b0;
           r23I <= 'b0;
           r0123I <= 'b0;
           r01234I <= 'b0;
           r01234AI <= 'b0;

           r4bQ <= 'b0;
           r4bbQ <= 'b0;
           r01Q <= 'b0;
           r23Q <= 'b0;
           r0123Q <= 'b0;
           r01234Q <= 'b0;
           r01234AQ <= 'b0;

           accI <= 'b0;
           accQ <= 'b0;
        end
        else begin
            // Real
            
            // stage 0
            vBuff[0] <= valid;
            r01I <= r0I + r1I;
            r23I <= r2I + r3I;
            r4bI <= r4I;

            // stage 1
            vBuff[1] <= vBuff[0];
            r0123I <= r01I + r23I;
            r4bbI <= r4bI;

            // stage 2
            vBuff[2] <= vBuff[1];
            r01234I <= r0123I + r4bbI;

            // stage 3
            vBuff[3] <= vBuff[2];
            r01234AI <= r01234I + accI;
            accI <= vBuff[2] ? 'b0 : r01234AI;

            vBuff[4] <= vBuff[3];


            r01Q <= r0Q + r1Q;
            r23Q <= r2Q + r3Q;
            r4bQ <= r4Q;

            r0123Q <= r01Q + r23Q;
            r4bbQ <= r4bQ;

            r01234Q <= r0123Q + r4bbQ;

            r01234AQ <= r01234Q + accQ;
            accQ <= vBuff[2] ? 'b0 : r01234AQ;

            //if(!vBuff[0]) 
            //r01234AI <= r01234I + r01234AI;
            //else
            //    r01234AI <= r01234I;

            // Ima
            //if(!vBuff[0]) begin 
            //    r01Q <= 0;
            //    r23Q <= 0;
            //    r4bQ <= 0;
            //end
            //else begin
                r01Q <= r0Q + r1Q;
                r23Q <= r2Q + r3Q;
                r4bQ <= r4Q;
            //end

            r0123Q <= r01Q + r23Q;
            r4bbQ <= r4bQ;

            r01234Q <= r0123Q + r4bbQ;


            if(!vBuff[0]) 
            r01234AQ <= r01234Q + r01234AQ;
            else
                r01234AQ <= r01234Q;
        end
    end
   
endmodule
    
