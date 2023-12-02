// Known Problems:
// 1. The color drawn stays blue for all states

module drawImage (
    iResetn,
    iClock,
    iState,
    oX,
    oY,
    oColour,
    oPlot
);

  parameter X_SCREEN_PIXELS = 8'd160;
  parameter Y_SCREEN_PIXELS = 8'd120;

  input wire iResetn, iClock;
  //input wire [14:0] address;
  input wire [2:0] iState;
  output wire [7:0] oX;
  output wire [6:0] oY;

  output wire [2:0] oColour;
  output wire oPlot;

  reg  [14:0] address;
  reg [ 2:0] color_out;
  assign oPlot = 1'b1;

  reg [7:0] xpos, ypos;
  reg [7:0] xbg, ybg;
  reg done;
  reg enable;

  initial address = 15'b0;
  initial done = 0;
  initial xpos = 8'b0;
  initial ypos = 8'b0;
  initial enable = 1'b1;

  assign oX = xbg;
  assign oY = ybg;

  // Enumerated type for FSM states
  localparam  
  Start = 3'b000,
  Game = 3'b001,
  Mole1 = 3'b010,
  Mole2 = 3'b011,
  Mole3 = 3'b100,
  Mole4 = 3'b101,
  GameOver = 3'b110;

  // instantiate memory rom block here to test; double check rom params
  // whackstartscreen testStart(.address(address), .clock(iClock), .q(color_out));

	assign oColour   = color_out;

  // So far, this module is just a test to see if the memory block works and the VGA prints out the image
  // Need to add conditionals to print out image based on state either here or in FSM

  // Choose image to draw based on state (testing colors for now)
  always @(posedge iState) begin
    case (iState)
      Start: color_out <= Start; // Change color for each state
      Game: color_out <= Game;
      Mole1: color_out <= Mole1;
      Mole2: color_out <= Mole2;
      Mole3: color_out <= Mole3;
      Mole4: color_out <= Mole4;
      GameOver: color_out <= GameOver;
      default: color_out <= 3'b000;
    endcase
//    done <= 0;

	// Reset drawing parameters when the state changes
//    xpos <= 8'b0;
//    ypos <= 8'b0;
//    address <= 15'b0;
//    xbg <= 8'b0;
//    ybg <= 8'b0;
//	enable <= 1'b1;
  end

  // Increment x and y positions to draw image
  always @(posedge iClock) begin

	if (enable) begin
  
      if (ypos < 10'd120 && xpos == 10'd159) begin
        ypos <= ypos + 1'b1;
        xpos <= 0;
      end else if (xpos < 10'd160) begin
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
		enable <= 0;
	  end
      end

  end

endmodule