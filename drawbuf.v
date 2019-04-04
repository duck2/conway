/* read from ram, give color output.
 * needs to know the position of video signal. */
module drawbuf(clk, X, Y, out_R, out_G, out_B, ram_addr, ram_in);

input clk;
input[10:0] X, Y;
output wire out_R, out_G, out_B;

input ram_in;
output wire[11:0] ram_addr;
wire [5:0] ramX, ramY;

/* trying to map a 1280x1024 screen to 64x64 RAM.
 * our original formula to index the RAM is
 * Addr = ramX + 64*ramY
 * where ramX = floor(X * (64 / 1280)) and ramY = floor(Y * (64 / 1024)).
 * which is something like (1/20)*X and (1/16)*Y.
 * where 1/20 ~ (0.0000110011)b.
 * notice the first five bits are zero, which means we cannot
 * use the bottom 5 bits of our puny 11-bit number.
 * so let us replace this by (32/20 * X) >> 5.
 * and 32/20 ~ (1.100110011)b
 * so ramX = ((32/20)*X >> 5) ~= ((X + (X >> 1) + (X >> 4) + ...) >> 5).
 * and ramY = Y >> 4.
 *
 * now about the timing. first we reduce the accuracy to get rid of some adders.
 * then we start adding from the more _shifted_(so less bits) wires and go up
 * to the final values. this way we can replace a 8-bit and a 9-bit adder for
 * two 10-bit adders. finally we simplify X + 64*Y to {Y, X} because we know
 * X is not wider than 6 bits. this reduces critical path to 4.886 ns. */

wire[9:0] tmpX;
assign tmpX = (X >> 1) + (X >> 4);
assign ramX = (X + tmpX) >> 5;
assign ramY = Y >> 4;
assign ram_addr = {ramY, ramX};

assign out_R = ram_in;
assign out_G = ram_in;
assign out_B = ram_in;

endmodule
