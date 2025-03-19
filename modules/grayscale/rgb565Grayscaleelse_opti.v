 module rgb565Grayscaleelse_opti #(parameter [7:0] customInstructionID = 8'd0)
                            (input wire         start,
                             input wire [31:0]  valueA,
                             input wire [31:0]  valueB,
                             input wire [7:0]   isId,
                             output wire        done,
                             output wire [31:0] result);

    wire isMe = (isId == customInstructionID) ? start : 1'b0;

    // Pixel0
    wire [7:0] red0 = {valueA[15:11], 3'b0};
    wire [7:0] green0 = {valueA[10: 5], 2'b0};
    wire [7:0] blue0 = {valueA[4:0], 3'b0};
    wire [15:0] grayscale_result0 = (red0*54+green0*183+blue0*19) >> 8;

    // Pixel1
    wire [7:0] red1 = {valueA[31:27], 3'b0};
    wire [7:0] green1 = {valueA[26: 21], 2'b0};
    wire [7:0] blue1 = {valueA[20:16], 3'b0};
    wire [15:0] grayscale_result1 = (red1*54+green1*183+blue1*19) >> 8;

    // Pixel2
    wire [7:0] red2 = {valueB[15:11], 3'b0};
    wire [7:0] green2 = {valueB[10: 5], 2'b0};
    wire [7:0] blue2 = {valueB[4:0], 3'b0};
    wire [15:0] grayscale_result2 = (red2*54+green2*183+blue2*19) >> 8;

    // Pixel3
    wire [7:0] red3 = {valueB[31:27], 3'b0};
    wire [7:0] green3 = {valueB[26: 21], 2'b0};
    wire [7:0] blue3 = {valueB[20:16], 3'b0};
    wire [15:0] grayscale_result3 = (red3*54+green3*183+blue3*19) >> 8;

    assign result = isMe ? {grayscale_result3[7:0], grayscale_result2[7:0], grayscale_result1[7:0], grayscale_result0[7:0]} : 32'b0;


    assign done = isMe ? start : 1'b0;


endmodule

/* 
In RGB565, red = 5'b11111 (max intensity)
If we don't shift, we keep 31 in decimal
In RGB888, red max intensity is 255, not 31 !

Shift (normalize) grayscale result as a pixel contains 8 bits per color channel (to express grayscale)
*/
