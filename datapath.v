module Datapath(
    input clk, 
    input Reset,
    input [7:0] data_in, //player score
    input [2:0] state, //state of game
	 input player_signal,  // player input hit or miss
	 output reg enable_control, // switch back from mole to game screen
    output reg [7:0] data_result, // result of data
	 output reg wren // read write
    );

	 reg [26:0] counter; // toggle
	 reg change; // allows change of data_result
	 reg flag; // allows increment
	
	 initial begin
		data_result = 8'b0;
		counter = 27'b0;
		change = 1'b0;
		enable_control = 1'b0;
		flag = 1'b1;
		wren = 1'b0;
	 end
	 
    always@(posedge clk) begin
        if (Reset) begin
				data_result <= 8'b0;
				counter <= 27'b0;
				change <= 1'b0;
				enable_control <= 1'b0;
				flag = 1'b1;
				wren <= 1'b0;
		  end
	  else begin
		  
		  case (state)
				3'b000: begin
					data_result <= 8'b0;
					counter <= 27'b0;
					change <= 1'b0;
					enable_control <= 1'b0;
					flag = 1'b1;
					wren <= 1'b0;
				end
				3'b001: begin
					if (counter == 27'b010111110101111000010000000) begin
						enable_control <= 1'b1;
						counter <= 27'b0;
					end
					else begin
						enable_control <= 1'b0;
						counter <= counter + 1;
					end
				end
				3'b010: begin
					if (player_signal && change) begin
						data_result <= data_in + 1;
						change <= 1'b0;
					end
			  		if (counter == 27'b010111110101111000010000000 && flag) begin
						change <= 1'b1;
						flag <= 1'b0;
					end
					else if (counter == 27'b010111110101111000010000000) begin
						enable_control <= 1'b1;
						wren <= 1'b0;
						counter <= 27'b0;
						flag <= 1'b1;
					end
					else begin
						enable_control <= 1'b0;
						wren <= 1'b1;
						counter <= counter + 1;
					end
				end
				3'b011: begin
					if (player_signal && change) begin
						data_result <= data_in + 1;
						change <= 1'b0;
					end
			  		if (counter == 27'b010111110101111000010000000 && flag) begin
						change <= 1'b1;
						flag <= 1'b0;
					end
					else if (counter == 27'b010111110101111000010000000) begin
						enable_control <= 1'b1;
						wren <= 1'b0;
						counter <= 27'b0;
						flag <= 1'b1;
					end
					else begin
						enable_control <= 1'b0;
						wren <= 1'b1;
						counter <= counter + 1;
					end
				end
				3'b100: begin
					if (player_signal && change) begin
						data_result <= data_in + 1;
						change <= 1'b0;
					end
			  		if (counter == 27'b010111110101111000010000000 && flag) begin
						change <= 1'b1;
						flag <= 1'b0;
					end
					else if (counter == 27'b010111110101111000010000000) begin
						enable_control <= 1'b1;
						wren <= 1'b0;
						counter <= 27'b0;
						flag <= 1'b1;
					end
					else begin
						enable_control <= 1'b0;
						wren <= 1'b1;
						counter <= counter + 1;
					end
				end
				3'b101: begin
					if (player_signal && change) begin
						data_result <= data_in + 1;
						change <= 1'b0;
					end
			  		if (counter == 27'b010111110101111000010000000 && flag) begin
						change <= 1'b1;
						flag <= 1'b0;
					end
					else if (counter == 27'b010111110101111000010000000) begin
						enable_control <= 1'b1;
						wren <= 1'b0;
						counter <= 27'b0;
						flag <= 1'b1;
					end
					else begin
						enable_control <= 1'b0;
						wren <= 1'b1;
						counter <= counter + 1;
					end
				end
				3'b110: begin
					wren <= 1'b0;
				end
		  endcase
	   end 
    end
endmodule
