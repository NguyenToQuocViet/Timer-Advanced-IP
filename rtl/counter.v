module counter (sys_clk, sys_rst_n, cnt_en, cnt, load_back, cnt_clr, tdr_wr_en, TDR_wr);
	//system
	input wire sys_clk, sys_rst_n;
		

	//giao tiep voi Counter Control
	input wire cnt_en;
		

	//giao tiep voi Register
	input wire cnt_clr;
	input wire tdr_wr_en;
	input wire [63:0] TDR_wr;

	output reg [63:0] cnt;
	output reg load_back;


	//logic
	always @(posedge sys_clk or negedge sys_rst_n) begin
		if (!sys_rst_n) begin
			cnt 		<= 64'd0;
			load_back	<= 1'b0;
		end else if (cnt_clr == 1'b1 || cnt == 64'hFFFF_FFFF_FFFF_FFFF) begin
			cnt 		<= 64'd0;
			load_back	<= 1'b1;
		end else if (tdr_wr_en == 1'b1) begin	//drive gia tri tu TDR (CPU write)
			cnt			<= TDR_wr;
			load_back	<= 1'b0;
		end else if (cnt_en == 1'b1) begin		//neu khong -> dem bth
			cnt 		<= cnt + 1;
			load_back	<= 1'b1;
		end else begin
			load_back	<= 1'b0;
		end
	end
endmodule
