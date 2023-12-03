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

  // reg for each frame lol
  reg [14:0] start_address;
  reg [14:0] game_address;
  reg [14:0] mole1_address;
  reg [14:0] mole2_address;
  reg [14:0] mole3_address;
  reg [14:0] mole4_address;
  reg [14:0] gameover_address;

  // color for each frame
  reg [ 2:0] start_color;
  reg [ 2:0] game_color;
  reg [ 2:0] mole1_color;
  reg [ 2:0] mole2_color;
  reg [ 2:0] mole3_color;
  reg [ 2:0] mole4_color;
  reg [ 2:0] gameover_color;

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

  // instantiate memory rom block here to test THIS IS UNTESTED
  whackstartscreen startFrame(.address(start_address), .clock(iClock), .q(start_color));
  whackgamescreen gameFrame(.address(game_address), .clock(iClock), .q(game_color));
  whackmole1 mole1Frame(.address(mole1_address), .clock(iClock), .q(mole1_color));
  whackmole2 mole2Frame(.address(mole2_address), .clock(iClock), .q(mole2_color));
  whackmole3 mole3Frame(.address(mole3_address), .clock(iClock), .q(mole3_color));
  whackmole4 mole4Frame(.address(mole4_address), .clock(iClock), .q(mole4_color));
  whackgameover gameoverFrame(.address(gameover_address), .clock(iClock), .q(gameover_color));

	assign oColour   = color_out;

  // So far, this module is just a test to see if the memory block works and the VGA prints out the image
  // Need to add conditionals to print out image based on state either here or in FSM

  // Choose image to draw based on state (testing colors for now)
  always @(posedge iState) begin
    case (iState)
      Start: 
        color_out <= start_color;
        address <= start_address;
      Game: 
        color_out <= game_color;
        address <= game_address;
      Mole1: 
        color_out <= mole1_color;
        address <= mole1_address;
      Mole2: 
        color_out <= mole2_color;
        address <= mole2_address;
      Mole3:
        color_out <= mole3_color;
        address <= mole3_address;
      Mole4:
        color_out <= mole4_color;
        address <= mole4_address;
      GameOver: 
        color_out <= gameover_color;
        address <= gameover_address;
      default:
        color_out <= 3'b000;
        address <= 15'b0;
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