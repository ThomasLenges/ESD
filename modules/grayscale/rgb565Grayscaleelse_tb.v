 
`timescale 1ns / 1ps

module rgb565Grayscaleelse_tb;

  // Testbench signals
  reg start;
  reg [31:0] valueA;
  reg [7:0] iseld;
  wire done;
  wire [31:0] result;

  // Instantiate the DUT (Device Under Test)
  rgb565Grayscaleelse #(
      .customInstructionID(8'd101)
  ) dut (
      .start (start),
      .valueA(valueA),
      .isId (iseld),
      .done  (done),
      .result(result)
  );

  // Testbench procedure
  initial begin
    // Initialize signals
    start  = 0;
    valueA = 32'h00000000;
    iseld  = 8'd0;

    // Apply test cases
    #10;
    start  = 1;
    valueA = 32'h00007C1F;  // RGB: (31, 0, 31) in RGB565
    iseld  = 8'd101;  // Matching customInstructionId
    #10;

    start = 0;
    #10;

    start  = 1;
    valueA = 32'h0000F800;  // RGB: (31, 0, 0) in RGB565
    iseld  = 8'd101;
    #10;

    start  = 1;
    valueA = 32'h000007E0;  // RGB: (0, 63, 0) in RGB565
    iseld  = 8'd101;
    #10;

    start  = 1;
    valueA = 32'h0000001F;  // RGB: (0, 0, 31) in RGB565
    iseld  = 8'd101;
    #10;

    start  = 1;
    valueA = 32'h0000FFFF;  // White (31, 63, 31) in RGB565
    iseld  = 8'd101;
    #10;

    start  = 1;
    valueA = 32'h00000000;  // Black (0, 0, 0)
    iseld  = 8'd101;
    #10;

    // Test with different iseld (should not activate)
    start  = 1;
    valueA = 32'h00007C1F;
    iseld  = 8'd100;  // Different from customInstructionId
    #10;

    $finish;
  end
  initial begin
    $dumpfile("grayScaler.vcd");
    $dumpvars(1, dut);
  end

endmodule