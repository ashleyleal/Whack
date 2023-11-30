module drawImage (clock, state, done, address, bgposx, bgposy, draw);

	input clock, draw;
	input [2:0] state;
	
	output reg [14:0] address;
	reg [7:0] bgx, bgy;
	
	output reg [7:0] bgposx, bgposy;
	
	initial address = 0;
	initial done = 0;
	
	localparam  
	Start = 3'b000, 
	Start_To_Game = 3'b001, 
	Game = 3'b010,
	Game_To_GameEnd = 3'b011,
	GameEnd = 3'b100,
	// Game substates
	Game_Hit = 3'b101,
	Game_Miss = 3'b110;
	
	always@(posedge clock) begin
		
		if (done) begin
			done <= 0;
		end
	
		else begin
		
			if (bgy < 10'd120 && bgx == 10'd159) begin
				bgy <= bgy + 1;
				bgx <= 0;
			end
			
			else if (bgx < 10'd160) begin
				bgx <= bgx + 1;
			end
			
			if (bgy != 10d'121 && bgx != 10'd160 && !done) begin
				address <= address + 1;
				bgposx <= bgx;
				bgposy <= bgy;
			end
			
			if ((bgy == 10d'120) && (bgx == 10'd0)) begin
				done <= 1;
				address <= 0;
				bgy <= 0;
				bgx <= 0;
			end
			
		end
	end
	

	
endmodule
