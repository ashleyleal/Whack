module drawImage 
	(iResetn, iClock, iState, oX, oY, oColour, oPlot);

	parameter X_SCREEN_PIXELS = 8'd160;
	parameter Y_SCREEN_PIXELS = 8'd120;

	input wire iResetn, iClock;
	output wire [7:0] oX;
	output wire [6:0] oY;

	output wire [2:0] oColour;
	output wire oPlot;

	reg [14:0] address;
	wire [2:0] color_out;
	assign oPlot = 1'b1;

	reg [7:0] xpos, ypos;
	reg [7:0] xbg, ybg;
	reg done;

	initial address = 0;
	initial done = 0;
	initial xpos = 8'b0;
	initial ypos = 8'b0;
	
	assign oX = xbg;
	assign oY = ybg;
	
	// instantiate memory rom block here to test; double check rom params
	whackstartscreen testStart(.address(address), .clock(iClock), .q(color_out));

	assign oColour = color_out;
	
	// So far, this module is just a test to see if the memory block works and the VGA prints out the image
	// Need to add conditionals to print out image based on state either here or in FSM
	always @(posedge iClock) begin
	
		if (ypos < 10'd120 && xpos == 10'd159) begin
			ypos <= ypos + 1'b1;
			xpos <= 0;
		end
		else if (xpos < 10'd160) begin
			xpos <= xpos + 1'b1;
		end

		if (ypos != 10'd120 && xpos != 10'd160 && !done) begin
			address <= address + 1'b1;
			xbg <= xpos;
			ybg <= ypos;
		end

		if (ypos == 10'd119 && xpos == 10'd159) begin
			done <= 1'b1;
			address <= 0;
			ypos <= 0;
			xpos <= 0;
		end
	end

	
endmodule
