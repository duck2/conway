/* 1280x1024@60Hz VGA module. */
module vga(clk, in_R, in_G, in_B, out_R, out_G, out_B, Hsync, Vsync, video_on, x, y);

input clk, in_R, in_G, in_B;

output wire out_R, out_G, out_B, Hsync, Vsync, video_on;
output reg[10:0] x, y;

/* counters. increment y at the start of hsync. reset x at the end of front porch. */
always @(posedge clk) begin
	if(x == 1528) y <= y + 1;
	if(x == 1688) x <= 10'b0;
	else x <= x + 1;

	if(y == 1066) y <= 10'b0;
end

assign video_on = (x < 1280 && y < 1024);
assign out_R = video_on ? in_R : 1'b0;
assign out_G = video_on ? in_G : 1'b0;
assign out_B = video_on ? in_B : 1'b0;

assign Hsync = ~(x > 1528 && x < 1641);
assign Vsync = ~(y > 1062 && y < 1066);

endmodule
