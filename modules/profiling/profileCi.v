module profileCi #( parameter [7:0] customId = 8'h00 )
                  ( input wire        start,
                                      clock,
                                      reset,
                                      stall,
                                      busIdle,
                    input wire [31:0] valueA,
                                      valueB,
                    input wire [7:0]  ciN,
                    output wire       done,
                    output reg [31:0] result );


    // 32-bit counters
    reg[31:0] counter0, counter1, counter2, counter3;

    // done signal
    assign done = (ciN == customId) && start;

    always @(posedge clock or posedge reset) begin
      if (reset) begin
        // Initialize counters to 0
        counter0 <= 32'b0;
        counter1 <= 32'b0;
        counter2 <= 32'b0;
        counter3 <= 32'b0;

        end
        else begin
            // valueB to control counters
            if (valueB[8]) counter0 <= 32'b0; // Reset counter0
            else if (valueB[4]) counter0 <= counter0; // Disable counter0 (remains unchanged)
            else if (valueB[0]) counter0 <= counter0 + 1; // Enable counter0

            if (valueB[9]) counter1 <= 32'b0; // Reset counter1
            else if (valueB[5]) counter1 <= counter1; // Disable counter1 (remains unchanged)
            else if (valueB[1] && stall) counter1 <= counter1 + 1; // Enable counter1 (µC stall cycles)

            if (valueB[10]) counter2 <= 32'b0; // Reset counter2
            else if (valueB[6]) counter2 <= counter2; // Disable counter2 (remains unchanged)
            else if (valueB[2] && busIdle) counter2 <= counter2 + 1; // Enable counter2 (bus-idle cycles)

            if (valueB[11]) counter3 <= 32'b0; // Reset counter3
            else if (valueB[7]) counter3 <= counter3; // Disable counter3 (remains unchanged)
            else if (valueB[3]) counter3 <= counter3 + 1; // Enable counter3
        end
    end

    // valueA to control output
    always @(*) begin
        if (!done)
            result <= 32'b0;
        else
            case (valueA[1:0])
                2'd0 : result <= counter0;
                2'd1 : result <= counter1;
                2'd2 : result <= counter2;
                2'd3 : result <= counter3;
                default : result <= 32'b0; // Recall RTL course
            endcase
    end

endmodule

