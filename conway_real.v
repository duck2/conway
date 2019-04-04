(* opt_level = 2 *)
module conway_real(clk, rst, addr_rd, we_rd, din, addr_wr, we_wr, dout);

input clk, rst;

input din;
output wire[11:0] addr_rd, addr_wr;
output wire we_rd, we_wr;
output reg dout;

/* States. At RDX, we read X.
 * [x][0][1]
 * [2][3][4]
 * [5][6][7] */
parameter RDX = 0;
parameter CKX = 1;
parameter CK0 = 2;
parameter CK1 = 3;
parameter CK2 = 4;
parameter CK3 = 5;
parameter CK4 = 6;
parameter CK5 = 7;
parameter CK6 = 8;
parameter CK7 = 9;
parameter WR3 = 10;
parameter DONE = 11;
reg[3:0] state;
initial state = RDX;

/* The current cell. Using rdX and rdY enables us to implement
 * side wrapping just by the means of overflow and get away
 * with 6-bit adders in the process. N is neighbor count. */
reg[11:0] ptr;
reg d3;

reg[5:0] rdX, rdY;
reg[2:0] N;

/* Use many always blocks to show different sequential and
 * combinatorial components. This is a state machine with output
 * given only at the WR state. Until that time, it checks the neighbor
 * cells and keeps a counter N. When WR is reached, a combinatorial
 * logic stage decides whether to write 0 or 1 to the next state of game. */
always @(posedge clk) begin
	if(rst) begin
		ptr <= 0;
		state <= RD0;
	end
	else if(state == RD0) state <= CK0;
	else if(state == CK0) state <= CK1;
	else if(state == CK1) state <= CK2;
	else if(state == CK2) state <= CK3;
	else if(state == CK3) state <= CK4;
	else if(state == CK4) state <= CK5;
	else if(state == CK5) state <= CK6;
	else if(state == CK6) state <= CK7;
	else if(state == CK7) state <= WR;
	else if(state == WR) begin
		ptr <= ptr + 1;
		if(ptr == 4095) state <= DONE;
		else state <= RD0;
	end else begin
		ptr <= 0;
		state <= DONE;
	end
end

always @(posedge clk) begin
	if(rst) N <= 0;
	else if(state != RD0 && state != WR && state != DONE) begin
		if(din) N <= N + 1;
	end else N <= 0;
end

always @(state) begin
	if(state == RD0) begin
		rdX = ptr[5:0] - 1;
		rdY = ptr[11:6] - 1;
	end else if(state == CK0) begin
		rdX = ptr[5:0];
		rdY = ptr[11:6] - 1;
	end else if(state == CK1) begin
		rdX = ptr[5:0] + 1;
		rdY = ptr[11:6] - 1;
	end else if(state == CK2) begin
		rdX = ptr[5:0] - 1;
		rdY = ptr[11:6];
	end else if(state == CK3) begin
		rdX = ptr[5:0] + 1;
		rdY = ptr[11:6];
	end else if(state == CK4) begin
		rdX = ptr[5:0] - 1;
		rdY = ptr[11:6] + 1;
	end else if(state == CK5) begin
		rdX = ptr[5:0];
		rdY = ptr[11:6] + 1;
	end else if(state == CK6) begin
		rdX = ptr[5:0] + 1;
		rdY = ptr[11:6] + 1;
	end else if(state == CK7) begin
		rdX = ptr[5:0];
		rdY = ptr[11:6];
	end else begin
		rdX = 0;
		rdY = 0;
	end
end

always @(state) begin
	if(N == 3) dout = 1;
	else if(N == 2 && din == 1) dout = 1;
	else dout = 0;
end

/* what to actually send to the RAM */
assign addr_rd = {rdY, rdX};
assign addr_wr = ptr;
assign we_rd = 0; /* duh */
assign we_wr = (state == WR);

endmodule
