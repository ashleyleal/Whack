module datapath(
    input clk,
    input Reset,
    input [7:0] data_in, //player score
    input state, //state of game
	 input timer_signal, // from timer signal
	 input player_signal,  // player input hit or miss
	 output reg enable_control, // switch back from mole to game screen
	 output reg timer_done,  //switch to end game
	 output reg timer_doneTimer,  //timer end
	 output reg game_start,  // game started
    output reg [7:0] data_result, // result of data
	 output reg wren, // read write
	 output reg [4:0] address // address
    );

    reg [7:0] data_in; 
	 wire flag; // toggle
	 
	 initial begin
		timer_signal <= 8'd0;
		data_result <= 8'd0;
		data_in <= 8'd0;
		enable_control <= 1'd0;
		timer_done <= 1'd0;
		timer_doneTime <= 1'd0;
		flag <= 1'd0;
		game_start <= 1'd0;
		wren <= 1'd0;
		address <=5'd0;
	 end
	 
    always@(posedge clk) begin
        if (Reset) begin
				timer_signal <= 8'd0;
				data_result <= 8'd0;
				data_in <= 8'd0;
				enable_control <= 1'd0;
				timer_done <= 1'd0;
				timer_doneTime <= 1'd0;
				flag <= 1'd0;
				game_start <= 1'd0;
				wren <= 1'd0;
				address <=5'd0;
		  end
		  case (state)
				3'b000:
					timer_signal <= 8'd0;
					data_result <= 8'd0;
					data_in <= 8'd0;
					enable_control <= 1'd0;
					timer_done <= 1'd0;
					timer_doneTime <= 1'd0;
					flag <= 1'd0;
					game_start <= 1'd0;
					wren <= 1'd0;
				3'b001:
					game_start <= 1'd1;
					
					if (flag <= 1'd1) begin
						enable_control <= 1'd1;
						flag <= 1'd0;
					end
					else begin
						enable_control <= 1'd0;
						flag <= 1'd1;
					end
				3'b010:
					if (player_signal) begin
						data_in <= data_in + 1;
					end
					if (flag <= 1'd1) begin
						enable_control <= 1'd1;
						wren <= 1'd0
						flag <= 1'd0;
					end
					else begin
						enable_control <= 1'd0;
						wren <= 1'd1;
						flag <= 1'd1;
					end
				
				3'b011:
					if (player_signal) begin
						data_in <= data_in + 1;
					end
					if (flag <= 1'd1) begin
						enable_control <= 1'd1;
						wren <= 1'd0
						flag <= 1'd0;
					end
					else begin
						enable_control <= 1'd0;
						wren <= 1'd1;
						flag <= 1'd1;
					end
				
				3'b100:
					if (player_signal) begin
						data_in <= data_in + 1;
					end
					if (flag <= 1'd1) begin
						enable_control <= 1'd1;
						wren <= 1'd0
						flag <= 1'd0;
					end
					else begin
						enable_control <= 1'd0;
						wren <= 1'd1;
						flag <= 1'd1;
					end
				
				3'b101:
					if (player_signal) begin
						data_in <= data_in + 1;
					end
					if (flag <= 1'd1) begin
						enable_control <= 1'd1;
						wren <= 1'd0
						flag <= 1'd0;
					end
					else begin
						enable_control <= 1'd0;
						wren <= 1'd1;
						flag <= 1'd1;
					end
				
				3'b110:
					if (flag <= 1'd1) begin
						timer_doneTime <= 1d'1
						flag <= 1'd0;
					end
					else begin
						timer_doneTime <= 1'd0;
						flag <= 1'd1;
					end
					address <= address + 1;
		  end case
		  
		  if (timer_signal) begin
				timer_done <= 1;
		  end
    end
	 
	 assign data_result = data_in;
endmodule
