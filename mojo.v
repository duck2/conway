module mojo(clk50, rst_n, led, vga_R, vga_G, vga_B, vga_hsync, vga_vsync);

input clk50;
input rst_n;
wire rst = ~rst_n;

/* we try to work at pixel clock which is multiplied to 50->108MHz by the Xilinx DCM.
 * https://www.xilinx.com/support/documentation/user_guides/ug382.pdf
 * https://www.xilinx.com/support/answers/11095.html */
wire clk;
DCM_CLKGEN #(.CLKIN_PERIOD(20), .CLKFX_MULTIPLY(54), .CLKFX_DIVIDE(25)) dcm0(.CLKIN(clk50), .RST(rst), .CLKFX(clk));

output wire vga_R, vga_G, vga_B, vga_hsync, vga_vsync;
output wire[7:0] led;

wire R, G, B;
wire video_on;
wire[10:0] video_x, video_y;
vga vga0(clk, R, G, B, vga_R, vga_G, vga_B, vga_hsync, vga_vsync, video_on, video_x, video_y);

/* bram.v:/^module/ */
wire wea0, dina0, web0, dinb0, wea1, dina1, web1, dinb1;
wire[11:0] addra0, addrb0, addra1, addrb1;
wire douta0, doutb0, douta1, doutb1;
bram bram0(clk, addra0, wea0, dina0, douta0, clk, addrb0, web0, dinb0, doutb0);
bram bram1(clk, addra1, wea1, dina1, douta1, clk, addrb1, web1, dinb1, doutb1);

/* active buffer is the one being read by drawbuf0 and conway0.
 * the passive buffer is written to by conway0 until we decide to swap buffers. */
wire drawbuf_ram_in;
wire[11:0] drawbuf_ram_addr;
drawbuf drawbuf0(clk, video_x, video_y, R, G, B, drawbuf_ram_addr, drawbuf_ram_in);

wire crst, cwe_rd, cdin, cwe_wr, cdout;
wire[11:0] caddr_rd, caddr_wr;
conway conway0(clk, crst, caddr_rd, cwe_rd, cdin, caddr_wr, cwe_wr, cdout);

reg activebuf;
initial activebuf = 1'b0;

assign addra0 = drawbuf_ram_addr;
assign addra1 = drawbuf_ram_addr;
assign drawbuf_ram_in = (activebuf == 0) ? douta0 : douta1;

assign addrb0 = (activebuf == 0) ? caddr_rd : caddr_wr;
assign addrb1 = (activebuf == 0) ? caddr_wr : caddr_rd;
assign web0 = (activebuf == 0) ? cwe_rd : cwe_wr;
assign web1 = (activebuf == 0) ? cwe_wr : cwe_rd;
assign dinb0 = (activebuf == 0) ? 1'b0 : cdout;
assign dinb1 = (activebuf == 0) ? cdout : 1'b0;
assign cdin = (activebuf == 0) ? doutb0 : doutb1;

/* a clock divider to swap buffers every 108M/5.4M cycles -> 20Hz. */
reg[24:0] div;
initial div = 0;
always @(posedge clk) begin
	div <= div + 1'b1;
	if(div == 5400000) begin
		div <= 0;
		activebuf <= ~activebuf;
	end
end
assign crst = (div == 5400000);

assign led = 0;

endmodule
