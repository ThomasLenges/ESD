module rgb565Grayscaleelse #(parameter [7:0] customInstructionID = 8'd0)
                            (input wire         start,
                             input wire [31:0]  valueA,
                             input wire [7:0]   isId,
                             output wire        done,
                             output wire [31:0] result);

    wire isMe = (isId == customInstructionID) ? start : 1'b0;

    wire [7:0] red = {valueA[15:11], 3'b0};
    wire [7:0] green = {valueA[10: 5], 2'b0};
    wire [7:0] blue = {valueA[4:0], 3'b0};
    wire [15:0] grayscale_result = (red*54+green*183+blue*19) >> 8;

    assign done = isMe ? start : 1'b0;
    assign result = isMe ? {24'b0, grayscale_result[7:0]} : 32'b0;


endmodule

/* 
In RGB565, red = 5'b11111 (max intensity)
If we don't shift, we keep 31 in decimal
In RGB888, red max intensity is 255, not 31 !

Shift (normalize) grayscale result as a pixel contains 8 bits per color channel (to express grayscale)
*/
