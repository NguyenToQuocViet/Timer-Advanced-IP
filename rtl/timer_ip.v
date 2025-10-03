module timer_top (sys_clk, sys_rst_n, tim_psel, tim_pwrite, tim_penable, tim_paddr, tim_pwdata, tim_prdata, tim_pstrb, tim_pready, tim_pslverr, tim_int, dbg_mode); 
	//system
	input wire sys_clk, sys_rst_n;


	//APB interface
	input wire tim_psel, tim_pwrite, tim_penable, dbg_mode;
	input wire [11:0] tim_paddr;
	input wire [31:0] tim_pwdata;
	input wire [3:0] tim_pstrb;

	output wire [31:0] tim_prdata;
	output wire tim_pready, tim_pslverr, tim_int;


	//APB - REGISTER
	wire error_res, wr_en, rd_en;
	wire [11:0] addr;
	wire [31:0] wdata, rdata;
	wire [3:0] strb;
	

	//REGISTER - COUNTER CONTROL
	wire timer_en, div_en;
	wire [3:0] div_val;


	//COUNTER - REGISTER
	wire [63:0] cnt;
	wire cnt_clr, tdr_wr_en;
	wire [63:0] TDR_wr;
	wire load_back;


	//COUNTER CONTROL - COUNTER
	wire cnt_en;
	

	//REGISTER - INTERRUPT
	wire [63:0] TDR, TCMP;
	wire int_en, int_st, int_clr;


	//REGISTER - HALT
	wire halt_req, halt_ack;


	apb_slave apb_1 (
		.sys_clk	(sys_clk),
		.sys_rst_n	(sys_rst_n),
		.dbg_mode	(dbg_mode),
		.tim_psel	(tim_psel),
		.tim_pwrite	(tim_pwrite),
		.tim_penable(tim_penable),
		.tim_paddr	(tim_paddr),
		.tim_pwdata	(tim_pwdata),
		.tim_pstrb	(tim_pstrb),
		.tim_pslverr(tim_pslverr),
		.tim_prdata	(tim_prdata),
		.tim_pready	(tim_pready),
		.error_res	(error_res),
		.addr		(addr),
		.wdata		(wdata),
		.rdata		(rdata),
		.wr_en		(wr_en),
		.rd_en		(rd_en),
		.strb		(strb)
	);

	register_file register_1 (
		.sys_clk	(sys_clk),
		.sys_rst_n	(sys_rst_n),
		.addr		(addr),
		.wdata		(wdata),
		.rdata		(rdata),
		.wr_en		(wr_en),
		.rd_en		(rd_en),
		.div_en		(div_en),
		.div_val	(div_val),
		.timer_en	(timer_en),
		.cnt		(cnt),
		.cnt_clr	(cnt_clr),
		.tdr_wr_en	(tdr_wr_en),
		.TDR_wr		(TDR_wr),
		.error_res	(error_res),
		.TDR		(TDR),
		.TCMP		(TCMP),
		.int_en		(int_en),
		.int_st		(int_st),
		.int_clr	(int_clr),
		.halt_req	(halt_req),
		.halt_ack	(halt_ack),
		.strb		(strb),
		.load_back	(load_back)
	);
	
	counter_control cnt_ctrl_1 (
		.sys_clk	(sys_clk),
		.sys_rst_n	(sys_rst_n),
		.timer_en	(timer_en),
		.halt_req	(halt_ack),
		.div_en		(div_en),
		.div_val	(div_val),
		.cnt_en		(cnt_en)
	);

	counter counter_1 (
		.sys_clk	(sys_clk),
		.sys_rst_n	(sys_rst_n),
		.cnt_en		(cnt_en),
		.cnt		(cnt),
		.cnt_clr	(cnt_clr),
		.tdr_wr_en	(tdr_wr_en),
		.TDR_wr		(TDR_wr),
		.load_back	(load_back)
	);


	interrupt_control int_ctrl_1 (
		.sys_clk	(sys_clk),
		.sys_rst_n	(sys_rst_n),
		.TDR		(TDR),
		.TCMP		(TCMP),
		.int_en		(int_en),
		.int_st		(int_st),
		.int_clr	(int_clr),
		.timer_int	(tim_int)
	);

	halt_gen halt_1 (
		.sys_clk	(sys_clk),
		.sys_rst_n	(sys_rst_n),
		.dbg_en		(dbg_mode),
		.halt_req	(halt_req),
		.halt_ack	(halt_ack)
	);

endmodule
