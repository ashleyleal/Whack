module Datapath(
    input clk, // one sec clock
    input Reset,
    input [7:0] data_in, //player score
    input [2:0] state, //state of game
	 input timer_signal, // from game timer signal
	 input player_signal,  // player input hit or miss
	 output reg enable_control, // switch back from mole to game screen
	 output reg timer_done,  //switch to end game
	 output reg game_start,  // game started
    output reg [7:0] data_result, // result of data
	 output reg wren, // read write
	 output reg [4:0] address // address
    );

	 reg flag; // toggle
	 
	
	 initial begin
		data_result = 8'b0;
		flag = 1'b0;
		enable_control = 1'b0;
		timer_done = 1'b0;
		game_start = 1'b0;
		wren = 1'b0;
		address =5'b0;
	 end
	 
    always@(posedge clk) begin
        if (Reset) begin
				data_result <= 8'b0;
				flag <= 1'b0;
				enable_control <= 1'b0;
				timer_done <= 1'b0;
				game_start <= 1'b0;
				wren <= 1'b0;
				address <=5'b0;
		  end
	  else begin
		  
		  case (state)
				3'b000: begin
					data_result <= 8'b0;
					flag <= 1'b0;
					enable_control <= 1'b0;
					timer_done <= 1'b0;
					game_start <= 1'b0;
					wren <= 1'b0;
				end
				3'b001: begin
					game_start <= 1'b1;
					
					if (flag == 1'b1) begin
						enable_control <= 1'b1;
						flag <= 1'b0;
					end
					else begin
						enable_control <= 1'b0;
						flag <= 1'b1;
					end
				end
				3'b010: begin
					if (player_signal) begin
						data_result <= data_in + 1;
					end
			  		if (flag <= 1'b1) begin
						enable_control <= 1'b1;
						wren <= 1'b0;
						flag <= 1'b0;
					end
					else begin
						enable_control <= 1'b0;
						wren <= 1'b1;
						flag <= 1'b1;
					end
				end
				3'b011: begin
					if (player_signal) begin
						data_result <= data_in + 1;
					end
					if (flag == 1'b1) begin
						enable_control <= 1'b1;
						wren <= 1'b0;
						flag <= 1'b0;
					end
			  		else begin
						enable_control <= 1'b0;
						wren <= 1'b1;
						flag <= 1'b1;
					end
				end
				3'b100: begin
					if (player_signal) begin
						data_result <= data_in + 1;
					end
					if (flag == 1'b1) begin
						enable_control <= 1'b1;
						wren <= 1'b0;
						flag <= 1'b0;
					end
					else begin
						enable_control <= 1'b0;
						wren <= 1'b1;
						flag <= 1'b1;
					end
				end
				3'b101: begin
					if (player_signal) begin
						data_result <= data_in + 1;
					end
					if (flag == 1'b1) begin
						enable_control <= 1'b1;
						wren <= 1'b0;
						flag <= 1'b0;
					end
					else begin
						enable_control <= 1'b0;
						wren <= 1'b1;
						flag <= 1'b1;
					end
				end
				3'b110: begin
					if (flag == 1'b1) begin	
						address <= address + 1;
						flag <= 1'b0;
					end
					else begin
						flag <= 1'b1;
					end
				end
		  endcase
	   end 
		
		  if (timer_signal) begin
				timer_done <= 1;
		  end
    end
endmodule
