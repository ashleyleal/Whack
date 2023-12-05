module drawImage (
    iResetn,  // input reset signal from top level
    iClock,  // input clock from top level
    iState,  // input state from FSM
    iEnable,  // input enable signal from FSM
    oX,  // output x position to vga adapter
    oY,  // output y position to vga adapter
    oColour,  // output color to vga adapter (from ROM)
    oPlot  // output plot signal to vga adapter
);

  input wire iResetn, iClock;
  input wire [2:0] iState;
  input wire iEnable;
  output wire [7:0] oX;
  output wire [6:0] oY;
  output [2:0] oColour;
  output wire oPlot;  // want to plot when done drawing, not when drawing, connect to done signal

  reg  [14:0] address;  // temp address to read from
  reg  [ 2:0] current_state;  // current state of FSM

  // reg for each frame lol
  reg  [14:0] start_address;
  reg  [14:0] game_address;
  reg  [14:0] mole1_address;
  reg  [14:0] mole2_address;
  reg  [14:0] mole3_address;
  reg  [14:0] mole4_address;
  reg  [14:0] gameover_address;

  // color for each frame
  wire [ 2:0] start_color;
  wire [ 2:0] game_color;
  wire [ 2:0] mole1_color;
  wire [ 2:0] mole2_color;
  wire [ 2:0] mole3_color;
  wire [ 2:0] mole4_color;
  wire [ 2:0] gameover_color;

  reg  [ 2:0] color_out;  // temporary color output

  reg [7:0] xpos, ypos;  // counters for tracking x and y positions
  reg [7:0] xbg, ybg;  // background x and y pixels
  reg done; // done signal to indicate when drawing is complete and plot can be asserted, also reset drawing parameters

  initial address = 15'b0;
  initial done = 1'b0;
  // start at top left corner of screen
  initial xpos = 8'b0;
  initial ypos = 8'b0;

  // assign output pixels to drawn image pixels
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

  // Instantiate each frame, passing in the corresponding address and clock and storing color in a reg
  whackstartscreen startFrame (
      .address(start_address),
      .clock(iClock),
      .q(start_color)
  );
  whackgamescreen gameFrame (
      .address(game_address),
      .clock(iClock),
      .q(game_color)
  );
  whackgamemole1 mole1Frame (
      .address(mole1_address),
      .clock(iClock),
      .q(mole1_color)
  );
  whackgamemole2 mole2Frame (
      .address(mole2_address),
      .clock(iClock),
      .q(mole2_color)
  );
  whackgamemole3 mole3Frame (
      .address(mole3_address),
      .clock(iClock),
      .q(mole3_color)
  );
  whackgamemole4 mole4Frame (
      .address(mole4_address),
      .clock(iClock),
      .q(mole4_color)
  );
  whackgameover gameoverFrame (
      .address(gameover_address),
      .clock(iClock),
      .q(gameover_color)
  );

  assign oColour = color_out;
  assign oPlot   = done;

  // Every clock cycle do the following:
  // 1. Choose image to draw based on current state, if enable is high
  // 2. Increment x and y positions to draw image, checking if within bounds
  // 3. While drawing is in bounds, update background x and y positions to draw image via vga adapter
  // 4. If done drawing, assert plot signal and reset drawing parameters


  // Increment x and y positions to draw image
  always @(posedge iClock) begin
    
    if (done) begin  // reset drawing parameters
      xpos <= 8'b0;
      ypos <= 8'b0;
      done <= 1'b0;
    end

    // Choose frame to draw based on current state, when enable is high
    if (iEnable) begin
      case (current_state)
        Start: begin
          color_out <= start_color;
          address   <= start_address;
        end
        Game: begin
          color_out <= game_color;
          address   <= game_address;
        end
        Mole1: begin
          color_out <= mole1_color;
          address   <= mole1_address;
        end
        Mole2: begin
          color_out <= mole2_color;
          address   <= mole2_address;
        end
        Mole3: begin
          color_out <= mole3_color;
          address   <= mole3_address;
        end
        Mole4: begin
          color_out <= mole4_color;
          address   <= mole4_address;
        end
        GameOver: begin
          color_out <= gameover_color;
          address   <= gameover_address;
        end
        default: begin
          color_out <= 3'b000;
          address   <= 15'b0;
        end
      endcase
    end

    // Traversing screen from top left to bottom right using x and y counters
    if (xpos < 10'd159) begin  // if not at end of row, increment x position
      xpos <= xpos + 1'b1;
    end
      else if (ypos < 10'd120 && xpos == 10'd159) begin // if at end of row, but not at the last row, go to next row
      ypos <= ypos + 1'b1;  // increment y position to next row
      xpos <= 8'b0;  // reset x position to start of next row
    end


    // While drawing is in bounds, update background x and y positions to draw image via vga adapter
    if (ypos != 10'd120 && xpos != 10'd160 && !done) begin
      address <= address + 1'b1;  // increment address to read from, need to stay in bounds
      xbg <= xpos;  // update x position to draw
      ybg <= ypos;  // update y position to draw
    end

    // If at end of last row, done drawing
    if (ypos == 10'd119 && xpos == 10'd159) begin  // if at end of last row, done drawing
      done <= 1'b1;
    end

  end


endmodule

