module counter_control (sys_clk, sys_rst_n, timer_en, halt_req, div_en, div_val, cnt_en);
	//system
	input wire sys_clk, sys_rst_n;


	//giao tiep voi counter
	input wire timer_en, halt_req, div_en;
	input wire [3:0] div_val;

	output reg cnt_en;


	//prescaler timer
	reg [7:0] cnt_div;
	reg timer_en_q;		//trang thai dang chay
	reg warm_up;		//tick o chu ky dau
	reg div_en_q;		//theo doi div_en
	reg [3:0] div_val_q;//theo doi div_val


	//detect canh len
	always @(posedge sys_clk or negedge sys_rst_n) begin
		if (!sys_rst_n) begin
			timer_en_q	<= 1'b0;
		end else begin
			timer_en_q	<= timer_en;
		end
	end

	wire en_rise = timer_en && ~timer_en_q;
	//wire warm_gate	= en_rise || warm_up;
	
	//theo doi div_en va div_val
	always @(posedge sys_clk or negedge sys_rst_n) begin
		if (!sys_rst_n) begin
			div_en_q 	<= 1'b0;
			div_val_q	<= 4'd0;
		end else begin
			div_en_q	<= div_en;
			div_val_q	<= div_val;
		end
	end	

	wire div_en_rise	= div_en && ~div_en_q;
	wire div_val_chg	= (div_val != div_val_q);
	
	//warm_up
	always @(posedge sys_clk or negedge sys_rst_n) begin
		if (!sys_rst_n) begin
			warm_up	<= 1'b0;
		end	else begin
			warm_up	<= en_rise;
		end
	end


	//prescaler timer
	always @(posedge sys_clk or negedge sys_rst_n) begin
		if (!sys_rst_n) begin
			cnt_en	<= 1'b0;
			cnt_div	<= 8'd0;
		end else if (!timer_en) begin
			//disable: reset phase
			cnt_en	<= 1'b0;
			cnt_div	<= 8'd0;
		end else if (halt_req) begin
			//halt: dong bang phase, khong tao tick
			cnt_en	<= 1'b0;
			cnt_div	<= cnt_div;
		end else begin
			//run
			//TH: khong chia 
			if (div_val == 4'd0) begin
				//tick moi chu ky, tru chu ky warm up
				if (en_rise) begin
					cnt_en	<= 1'b0;
					cnt_div	<= 8'd0;
				end else begin 
					cnt_en	<= 1'b1;
					cnt_div	<= cnt_div;
				end
			end else begin
				//TH: co chia
				if (!div_en) begin
					//tick moi chu ky, tru chu ky warm up
					if (en_rise) begin
						cnt_en	<= 1'b0;
						cnt_div	<= 8'd0;
					end else begin
						cnt_en	<= 1'b1;
						cnt_div	<= cnt_div;
					end
					//reset prescaler timer khi:
					//timer_en vua bat
					//div_en vua bat
					//dang chay ma div_val thay doi
				end else if (en_rise || div_en_rise || (div_val_chg && timer_en && div_en)) begin
					cnt_en	<= 1'b0;
					cnt_div	<= 8'd0;
				end else if (cnt_div == (8'd1 << div_val) - 1) begin
					//tick moi chu ky, tru warm up
					if (warm_up) begin
						cnt_en	<= 1'b0;
					end else begin
						cnt_en	<= 1'b1;
					end

					cnt_div	<= 8'd0;
				end else begin
					cnt_div	<= cnt_div + 8'd1;
					cnt_en	<= 1'b0;
				end
			end
		end
	end
endmodule
