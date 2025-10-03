module halt_gen (sys_clk, sys_rst_n, dbg_en, halt_req, halt_ack);
	//system
	input wire sys_clk, sys_rst_n;


	//giao tiep voi Register
	input wire dbg_en, halt_req;

	output reg halt_ack;

	
	//logic
	always @(posedge sys_clk or negedge sys_rst_n) begin
		if (!sys_rst_n) begin
			halt_ack 	<= 1'b0;
		end else
			halt_ack	<= dbg_en & halt_req;		
	end
endmodule
