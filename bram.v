/* dual port BRAM. both ports are write-first.
 * clk, addr, we: write enable, din: data in, dout: data out */
module bram(clka, addra, wea, dina, douta, clkb, addrb, web, dinb, doutb);

input clka, wea, dina, clkb, web, dinb;
input[11:0] addra, addrb;
output reg douta, doutb;

reg ram[4095:0]; /* synthesis syn_ramstyle=no_rw_check */
initial $readmemb("screen.mem", ram);

always @(posedge clka) begin
	if(wea) begin
		douta <= dina;
		ram[addra] <= dina;
	end else begin
		douta <= ram[addra];
	end
end

always @(posedge clkb) begin
	if(web) begin
		doutb <= dinb;
		ram[addrb] <= dinb;
	end else begin
		doutb <= ram[addrb];
	end
end

endmodule
