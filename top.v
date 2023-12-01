// Protect against undefined nets
`default_nettype none

// Top Level Module (Main)

module Top (
  input wire CLOCK_50,   // DE-series 50 MHz clock signal
  input wire [3:0] KEY,   // DE-series pushbuttons
  input wire [9:0] SW,    // DE-series switches
  output wire [9:0] LEDR,  // DE-series LEDs
  // VGA
  output wire VGA_CLK,     // VGA Clock
  output wire VGA_HS,      // VGA H_SYNC
  output wire VGA_VS,      // VGA V_SYNC
  output wire VGA_BLANK_N, // VGA BLANK
  output wire VGA_SYNC_N,  // VGA SYNC
  output wire [7:0] VGA_R,  // VGA Red[7:0]
  output wire [7:0] VGA_G,  // VGA Green[7:0]
  output wire [7:0] VGA_B   // VGA Blue[7:0]
);

  reg [11:0] colour;
  wire [7:0] bgx, bgy;
  reg [7:0] x, y;
  reg writeEn;
  wire resetn;
  assign resetn = KEY[0]; // reset everything switch

  wire startEnable;
  wire draw;

  assign draw = 1'b1;

  wire [11:0] startColour;
  wire [11:0] gameColour;

  wire done;
  reg [14:0] address;
  wire [14:0] outAddress;

  wire [2:0] outputState;

  // Signals from FSM
  wire isStart, isGame, isGameEnd;

  // Debugging
  assign isStart = KEY[1]; // start enable
  assign isGame = KEY[2];
  assign isGameEnd = KEY[3];

  // Signals from datapath
  wire [1:0] hit_miss;
  wire control_signal, timer_signal;

  // Debugging
  assign control_signal = SW[0];
  assign timer_signal = SW[1];
  assign hit_miss = SW[1:0];

  // Instantiate memory modules to display frames (need to update)
  StartBG startscreen(.address(address), .clock(CLOCK_50), .q(startColour));
  // game gameBG(.address(address), .clock(CLOCK_50), .q(gameColour));

  vga_adapter VGA(
    .resetn(resetn),
    .clock(CLOCK_50),
    .colour(colour),
    .x(x),
    .y(y),
    .plot(writeEn),
    /* Signals for the DAC to drive the monitor. */
    .VGA_R(VGA_R),
    .VGA_G(VGA_G),
    .VGA_B(VGA_B),
    .VGA_HS(VGA_HS),
    .VGA_VS(VGA_VS),
    .VGA_BLANK(VGA_BLANK_N),
    .VGA_SYNC(VGA_SYNC_N),
    .VGA_CLK(VGA_CLK));
  defparam VGA.RESOLUTION = "160x120";
  defparam VGA.MONOCHROME = "FALSE";
  defparam VGA.BITS_PER_COLOUR_CHANNEL = 4;
  defparam VGA.BACKGROUND_IMAGE = "whackstartsceen.mif";

  // Instantiate FSM
  GameFSM MainFSM(
    .clk(CLOCK_50),
    .reset(resetn),
    .input_signal(KEY[1]),
    .control_signal(control_signal),
    .hit_miss(hit_miss),
    .timer_signal(timer_signal),
    .output_start(LEDR[0]),
    .output_game(LEDR[1]),
    .output_game_end(LEDR[2]),
    .output_state(outputState));

	drawImage drawImage(.iResetn(resetn), .iClock(CLOCK_50), .iState(outputState), .oX(x), .oY(y), .oColour(colour), .oPlot(writeEn));

  always @* begin
    if (isStart) begin
      writeEn <= startEnable;
      if (draw) begin
        colour <= startColour;
        x <= bgx;
        y <= bgy;
        address <= outAddress;
      end
      else begin
        address <= 0;
        x <= 0;
        y <= 0;
      end
    end
  end

endmodule