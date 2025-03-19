module profileCi #( parameter [7:0] customId = 8'h00 )
                  ( input wire        start,
                                      clock,
                                      reset,
                                      stall,
                                      busIdle,
                    input wire [31:0] valueA,
                                      valueB,
                    input wire [7:0]  ciN,
                    output reg       done,
                    output reg [31:0] result );

    wire[31:0] counter0_value, counter1_value, counter2_value, counter3_value;
    reg counter0_reset, counter1_reset, counter2_reset, counter3_reset;
    reg counter0_enable, counter1_enable, counter2_enable, counter3_enable;

    wire isMe = (ciN == customId) ? start : 1'b0;
    reg [31:0] profile_result;

  always @(posedge clock or posedge reset) begin
    if (reset) begin

      done <= 1'b0;
      result <= 32'h00000000;
      counter0_enable <= 1'b0;
      counter1_enable <= 1'b0;
      counter2_enable <= 1'b0;
      counter3_enable <= 1'b0;

      counter0_reset <= 1'b0;
      counter1_reset <= 1'b0;
      counter2_reset <= 1'b0;
      counter3_reset <= 1'b0;

    end else begin
      if (isMe) begin
        done <= 1'b1;
        result <= profile_result;
      end else begin
        done   <= 1'b0;
        result <= 32'h00000000;
      end
      counter0_enable <= ((reset) || (valueB[4] && isMe))? 1'b0 : ((valueB[0]&& isMe) ? 1'b1 : counter0_enable);
      counter1_enable <= ((reset) || (valueB[5] && isMe))? 1'b0 : ((valueB[1]&& isMe) ? 1'b1 : counter1_enable);
      counter2_enable <= ((reset) || (valueB[6] && isMe))? 1'b0 : ((valueB[2]&& isMe) ? 1'b1 : counter2_enable);
      counter3_enable <= ((reset) || (valueB[7] && isMe))? 1'b0 : ((valueB[3]&& isMe) ? 1'b1 : counter3_enable);

      counter0_reset <= isMe ? valueB[8] : 1'b0;
      counter1_reset <= isMe ? valueB[9] : 1'b0;
      counter2_reset <= isMe ? valueB[10] : 1'b0;
      counter3_reset <= isMe ? valueB[11] : 1'b0;
    end
  end

  always @(*) begin
    case (valueA[1:0])
      2'b00:   profile_result = counter0_value;
      2'b01:   profile_result = counter1_value;
      2'b10:   profile_result = counter2_value;
      2'b11:   profile_result = counter3_value;
      default: profile_result = 32'h00000000;
    endcase
  end


  counter #(.WIDTH(32)) counter0 (.reset(counter0_reset), .clock(clock), .enable(counter0_enable), .direction(1'b1), .counterValue(counter0_value));
  counter #(.WIDTH(32)) counter1 (.reset(counter1_reset), .clock(clock), .enable(counter1_enable && stall), .direction(1'b1), .counterValue(counter1_value));
  counter #(.WIDTH(32)) counter2 (.reset(counter2_reset), .clock(clock), .enable(counter2_enable && busIdle), .direction(1'b1), .counterValue(counter2_value));
  counter #(.WIDTH(32)) counter3 (.reset(counter3_reset), .clock(clock), .enable(counter3_enable), .direction(1'b1), .counterValue(counter3_value));

endmodule
