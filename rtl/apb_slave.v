module apb_slave (sys_clk, sys_rst_n, dbg_mode, tim_psel, tim_pwrite, tim_penable, tim_paddr, tim_pwdata, tim_pstrb, strb, tim_pslverr, tim_prdata, tim_pready, error_res, addr, wdata, rdata, wr_en, rd_en);
	//system	
	input wire sys_clk, sys_rst_n;
	

	//interface
	input wire dbg_mode, tim_psel, tim_pwrite, tim_penable;
	input wire [11:0] tim_paddr;
	input wire [31:0] tim_pwdata;
	input wire [3:0] tim_pstrb;

	output reg tim_pready, tim_pslverr;
	output wire [31:0] tim_prdata;
	
	
	//giao tiep voi register
	output wire [11:0] addr;
	output wire [31:0] wdata;
	output reg wr_en, rd_en;
	output wire [3:0] strb;

	input wire [31:0] rdata;
	input wire error_res;
	

	//FSM
	reg [1:0] present_state, next_state;

	parameter IDLE		= 2'b00;
	parameter SETUP		= 2'b01;
	parameter ACCESS	= 2'b10;


	//latch bus signals
	reg [11:0] 	addr_t;
	reg [31:0] 	wdata_t;
	reg [3:0]	strb_t;
	reg			pwrite_t;


	//logic reset va load bus signals
	always @(posedge sys_clk or negedge sys_rst_n) begin
		if (!sys_rst_n) begin
			addr_t		<= 12'd0;
			wdata_t		<= 32'd0;
			pwrite_t	<= 1'b0;
			strb_t		<= 4'hF;
		end else if (tim_psel && !tim_penable) begin	//neu dang o state setup
			addr_t		<= tim_paddr;
			wdata_t		<= tim_pwdata;
			pwrite_t	<= tim_pwrite;
			strb_t		<= tim_pstrb;
		end
	end


	//logic state
	always @(posedge sys_clk or negedge sys_rst_n) begin
		if (!sys_rst_n)
			present_state	<= IDLE;
		else
			present_state	<= next_state;
	end

	
	//APB FSM
	always @(*) begin
		tim_pslverr = 1'b0;
		tim_pready 	= 1'b0;
		wr_en		= 1'b0;
		rd_en		= 1'b0;

		next_state	= present_state;
		
		//bam theo so do state cua APB
		case (present_state)
			IDLE: begin
				if (tim_psel && !tim_penable) 
					next_state	= SETUP;
				else
					next_state	= IDLE;
			end

			SETUP: begin
				if (!tim_psel) 
					next_state 	= IDLE;
				else if (tim_penable)
					next_state	= ACCESS;
				else
					next_state	= SETUP;
			end

			ACCESS: begin	
				if (pwrite_t) 
					wr_en	= 1'b1;
				else
					rd_en	= 1'b1;

				tim_pready	= 1'b1;
				tim_pslverr = error_res;
				
				next_state	= IDLE;
			end

			default: tim_pslverr = 1'b1;
		endcase
	end

	//read data khi co read enable
	assign tim_prdata 	= rd_en ? rdata : 32'd0;
	
	//load cac tin hieu dieu khien transaction vao register 
	assign addr 		= addr_t;
	assign wdata		= wdata_t;
	assign strb			= pwrite_t ? strb_t : 4'b0000;
endmodule
