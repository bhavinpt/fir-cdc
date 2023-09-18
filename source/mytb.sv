`include "firc.v"

module firc_tb; reg Clk; reg Reset; reg PushIn; reg [23:0] SampI; reg [23:0] SampQ; reg PushCoef; reg [4:0] CoefAddr; reg [26:0] CoefI; reg [26:0] CoefQ; wire StopIn; wire PushOut; wire [31:0] FI; wire [31:0] FQ; firc dut (.Clk(Clk), .Reset(Reset), .PushIn(PushIn), .SampI(SampI), .SampQ(SampQ), .PushCoef(PushCoef), .CoefAddr(CoefAddr), .CoefI(CoefI), .CoefQ(CoefQ), .StopIn(StopIn), .PushOut(PushOut), .FI(FI), .FQ(FQ));

// Clock generation
always begin
    #5 Clk = ~Clk;
end

int sampCount = 0;

initial begin
    Clk      = 0;
    Reset    = 0;
    PushIn   = 0;
    PushCoef = 0;
    CoefAddr = 0;
    CoefI    = 0;
    CoefQ    = 0;
    SampI    = 0;
    SampQ    = 0;
    
    $dumpfile("waves.vcd");
    $dumpvars(0);
    
    // Check output
    $monitor("Filtered output FI = %d, FQ = %d @%t", FI, FQ, $time);
    
    // Apply reset
    repeat(2) @(posedge Clk);
    Reset = 1;
    repeat(2) @(posedge Clk);
    Reset = 0;
    repeat(2) @(posedge Clk);
    
    
    // Load 1 coefficients for 29 clocks
    PushIn   = 0;
    PushCoef = 1;
    repeat (15) begin
        CoefI    = $random; // Coefficient I value
        CoefQ    = $random; // Coefficient Q value
        CoefAddr = CoefAddr + 1;
        @(posedge Clk);
    end
    
    // Set input sample
    PushCoef = 0;
    for(int i = 1; i <= 30; i++) begin
        if(StopIn) begin
            PushIn   = 0;
            forever begin
                @(posedge Clk);
                if(!StopIn)
                    break;
            end
        end
        PushIn   = 1;
        SampI = i; // Sample I value
        SampQ = i;  // Sample Q value
        @(posedge Clk);
    end

    repeat(100) @(posedge Clk);
    
    // Wait for a few cycles for the filter to process the input
    // Finish simulation
    #10 $finish;
end

endmodule

