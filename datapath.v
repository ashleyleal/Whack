module datapath(
    input clk, 
    input Reset,
    input [7:0] data_in, //player score
    input state, //state of game
	 input timer_signal, // from game timer signal
	 input player_signal,  // player input hit or miss
	 output reg enable_control, // switch back from mole to game screen
	 output reg timer_done,  //switch to end game
	 output reg timer_doneGame; // game done
	 output reg game_start,  // game started
    output reg [7:0] data_result, // result of data
	 output reg wren, // read write
	 output reg [4:0] address // address
    );

   	 reg [7:0] data_in; 
	 reg [27:0] counter; // toggle

	
	 initial begin
		data_result = 8'd0;
		data_in = 8'd0;
		counter = 27'd0;
		enable_control = 1'b0;
		timer_done = 1'b0;
		timer_doneGame <= 1'b0;
		game_start = 1'b0;
		wren = 1'b0;
		address =5'd0;
	 end
	 
    always@(posedge clk) begin
        if (Reset) begin
				data_result <= 8'd0;
				data_in <= 8'd0;
				counter <= 27'd0;
				enable_control <= 1'b0;
				timer_done <= 1'b0;
				timer_doneGame <= 1'b0;
				game_start <= 1'b0;
				wren <= 1'b0;
				address <=5'd0;
		  end
	  else
		  
		  case (state)
				3'b000:
					data_result <= 8'd0;
					data_in <= 8'd0;
			  		counter <= 27'd0;
					enable_control <= 1'b0;
					timer_done <= 1'b0;
			 		timer_doneGame <= 1'b0;
					game_start <= 1'b0;
					wren <= 1'b0;
				3'b001:
					game_start <= 1'b1;
					
					if (counter <= 27'd50000000) begin
						enable_control <= 1'b1;
						counter <= 27'd0;
					end
					else begin
						enable_control <= 1'b0;
						counter <= counter + 1;
					end
				3'b010:
					if (player_signal) begin
						data_in <= data_in + 1;
					end
			  		if (counter <= 27'd50000000) begin
						enable_control <= 1'b1;
						wren <= 1'b0
						counter <= 27'd0;
					end
					else begin
						enable_control <= 1'b0;
						wren <= 1'b1;
						counter <= counter + 1;
					end
				
				3'b011:
					if (player_signal) begin
						data_in <= data_in + 1;
					end
					if (counter <= 27'd50000000) begin
						enable_control <= 1'b1;
						wren <= 1'b0
						counter <= 27'd0;
					end
			  		else begin
						enable_control <= 1'b0;
						wren <= 1'b1;
						counter <= counter + 1;
					end
				
				3'b100:
					if (player_signal) begin
						data_in <= data_in + 1;
					end
					if (counter <= 27'd50000000) begin
						enable_control <= 1'b1;
						wren <= 1'b0
						counter <= 27'd0;
					end
					else begin
						enable_control <= 1'b0;
						wren <= 1'b1;
						counter <= counter + 1;
					end
				
				3'b101:
					if (player_signal) begin
						data_in <= data_in + 1;
					end
					if (counter <= 27'd50000000) begin
						enable_control <= 1'b1;
						wren <= 1'b0
						counter <= 27'd0;
					end
					else begin
						enable_control <= 1'b0;
						wren <= 1'b1;
						counter <= counter + 1;
					end
				
				3'b110:
					if (counter <= 27'd50000000) begin
						timer_doneGame <= 1'b1
						address <= address + 1;
						counter <= 27'd0;
					end
					else begin
						timer_doneGame <= 1'b0;
						counter <= counter + 1;
					end
		  end case
	   end 
		  if (timer_signal) begin
				timer_done <= 1;
		  end
    end
	 
	 assign data_result = data_in;
endmodule
