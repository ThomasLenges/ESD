`timescale 1ps/1ps

module profileCi_tb;

 reg reset, clock;
  initial 
    begin
      reset = 1'b1;
      clock = 1'b0;                 
      repeat (4) #5 clock = ~clock; 
      reset = 1'b0;                 
      forever #5 clock = ~clock;
    end

reg s_start, s_stall, s_busIdle;
reg [31:0 ]s_valueA, s_valueB;
reg [7:0] s_ciN;
wire s_done;
wire [31:0] s_result;

profileCi #(.customId(8'd8)) DUT
	(.start(s_start),
	.clock(clock),
	.reset(reset),
	.stall(s_stall),
	.busIdle(s_busIdle),
	.valueA(s_valueA),
	.valueB(s_valueB),
	.ciN(s_ciN),
	.done(s_done),
	.result(s_result));

initial
  begin
    s_ciN = 8'h11; // wrong id, output should remain 0
    s_valueA[1:0] = 2'd0; //select counter0 output
    s_valueB[11:0] = 12'b000011100001; // enables counter 0, disable others
    s_start = 1'b1;

    @(negedge reset);            // wait for the reset period to end
    repeat(10) @(negedge clock);  // wait
    
    s_ciN = 8'd8; // right id, profileCi should activate - counter0 should count
    repeat(10) @(negedge clock);  // wait for 10 clock cycles

    s_ciN = 8'h11;// to check if output is forced back to 0 when ciN!=customId
    s_valueB[11:0] = 12'b111111111111;
    repeat(2) @(negedge clock);

    s_ciN = 8'd8;
    s_valueA[1:0] = 2'd1; //select counter1 output
    s_valueB[11:0] = 12'b000011000011; // enables counter 0 / 1, disable others
    s_stall = 1'b1; // counter 1 activates with stall raised
    repeat(5) @(negedge clock);

    s_valueA[1:0] = 2'd00012; //select counter2 output
    s_valueB[11:0] = 12'b000110000111; // enables counter 0 / 1 / 2, disable 4, reset 0
    s_busIdle = 1'b1; // counter 2 activates with busIdle raised
    repeat(5) @(negedge clock);
    // counter0 will remain zero because it's constantly reset

    $finish;	// decomment when using iVerilog
  end


// decomment when using iVerilog
 initial
    begin
      $dumpfile("profileCi_waves.vcd"); /* define the name of the .vcd file that can be viewed by GTKWAVE */
      $dumpvars(1,DUT);             /* dump all signals inside the DUT-component in the .vcd file */
    end


endmodule