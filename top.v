module top (
    CLOCK_50,
    KEY,
    SW,
    LEDR,
    //VGA
    VGA_CLK,  //	VGA Clock
    VGA_HS,  //	VGA H_SYNC
    VGA_VS,  //	VGA V_SYNC
    VGA_BLANK_N,  //	VGA BLANK
    VGA_SYNC_N,  //	VGA SYNC
    VGA_R,  //	VGA Red[9:0]
    VGA_G,  //	VGA Green[9:0]
    VGA_B,  //	VGA Blue[9:0]   
    // Audio
    AUD_ADCDAT,
    // Bidirectionals
    AUD_BCLK,
    AUD_ADCLRCK,
    AUD_DACLRCK,
    FPGA_I2C_SDAT,
    // Outputs
    AUD_XCK,
    AUD_DACDAT,
    FPGA_I2C_SCLK,
    HEX0,
    HEX1,
    HEX2,
    HEX4,
    HEX5

);

/*****************************************************************************
 *                             Port Declarations                             *
 *****************************************************************************/

  // FPGA Ports
  input wire CLOCK_50;  // DE-series 50 MHz clock signal
  input wire [3:0] KEY;  // DE-series pushbuttons
  input wire [9:0] SW;  // DE-series SW switches
  output wire [9:0] LEDR;  // DE-series LEDs
  // VGA Ports
  output VGA_CLK;  //	VGA Clock
  output VGA_HS;  //	VGA H_SYNC
  output VGA_VS;  //	VGA V_SYNC
  output VGA_BLANK_N;  //	VGA BLANK
  output VGA_SYNC_N;  //	VGA SYNC
  output [7:0] VGA_R;  //	VGA Red[7:0] Changed from 10 to 8-bit DAC
  output [7:0] VGA_G;  //	VGA Green[7:0]
  output [7:0] VGA_B;  //	VGA Blue[7:0]

  // Audio Ports
  input AUD_ADCDAT;
  // Bidirectionals
  inout AUD_BCLK;
  inout AUD_ADCLRCK;
  inout AUD_DACLRCK;
  inout FPGA_I2C_SDAT;
  // Outputs
  output AUD_XCK;
  output AUD_DACDAT;
  output FPGA_I2C_SCLK;
  output 	[6:0] HEX0;
  output 	[6:0] HEX1;
  output 	[6:0] HEX2;
  output 	[6:0] HEX4;
  output 	[6:0] HEX5;
/*****************************************************************************
 *                 Internal Wires and Registers Declarations                 *
 *****************************************************************************/

  // Internal Wires for the audio controller
  wire        audio_in_available;
  wire [31:0] left_channel_audio_in;
  wire [31:0] right_channel_audio_in;
  wire        read_audio_in;

  wire        audio_out_allowed;
  wire [31:0] left_channel_audio_out;
  wire [31:0] right_channel_audio_out;
  wire        write_audio_out;

  // Wires for the draw module
  wire [ 7:0] x;
  wire [ 6:0] y;
  // Difference between draw_enable and plot is that draw_enable is enabled when the state changes and drawImage selects
  // the correct image to draw based on the state, and plot is enabled when the drawing is done and the VGA adapter should
  // plot the pixels to the screen
  wire draw_enable;
  wire        plot;
  wire [ 2:0] color;

  // General 
  wire        reset;
  reg  [ 6:0] outputLED;  // for testing signals
  wire clock_slow;
  wire playerSignal;

  // Wires for the FSM module
  wire [ 2:0] state;
  wire game_start; // from fsm to datapath
  wire time_signal;
  wire enable_control;

  // Memory
  reg [4:0] Address;
  wire [7:0] Data_In;
  wire [7:0] Data_Out;
  wire wren;
  // reg [7:0] Data;
  // reg [7:0] top_score;

  // assign Data_In = Data;
	
  // regs and wires for audio
  reg  [18:0] delay_cnt;
  wire [18:0] delay;
  reg         snd;
  wire [3:0] audio_sw;
  wire hit_sound;
  wire miss_sound;

  // Assign to hit miss sound and button input and timer signal
  assign audio_sw[0] = ~KEY[1];
  assign audio_sw[1] = ~KEY[2];
  assign audio_sw[2] = 1'b0;
  assign audio_sw[3] = 1'b0;

  assign reset = ~SW[0];

  // states
  localparam
    Start = 3'b000,
    Game = 3'b001,
    Mole1 = 3'b010,
    Mole2 = 3'b011,
    Mole3 = 3'b100,
    Mole4 = 3'b101,
    GameOver = 3'b110;

/*****************************************************************************
 *                              Memory Modules                             *
 *****************************************************************************/
//initial begin
//	Address = 5'b0;
//	Data = 8'b0;
//	top_score = 8'b0;
//end
// always @(posedge CLOCK_50) begin
// 	if (reset == 1'b1) begin
// 		Address <= 5'b0;
// 		Data <= 8'b0;
// 		top_score <= 8'b0;
// 	end
// 	else if (state == 3'b0) begin
// 		Address <= 5'b0;
// 		Data <= 8'b0;
// 	end
// 	else if (state == 3'b110) begin
// 		Address <= 5'b00001;
// 		Data <= top_score;
// 	end
// 	else begin
// 		if (top_score < Data) begin
// 			top_score <= Data;
// 		end
// 	end
// end

game_mem gm(
	.address(Address),
	.clock(CLOCK_50),
	.data(Data_In),
	.wren(wren),
	.q(Data_Out)
);

/*****************************************************************************
 *                              Internal Modules                             *
 *****************************************************************************/
hex_display hd( 
    .Clck(CLOCK_50),
	.reset(reset),
	.Data_In(Data_Out), // from game memory module
	.HEX4(HEX4),
	.HEX5(HEX5)
);
	
GameTimer gt(
	.Clck(clock_slow), // 1 sec clock
	.reset(reset),
	.game_start(game_start), //game started from FSM
	.HEX0(HEX0),
	.HEX1(HEX1),
	.HEX2(HEX2),
	.timer_signal(time_signal)
);
	
rate_divider rd(
	.Clk(CLOCK_50),
	.Reset(reset),
	.Enable(clock_slow)
);
	
Datapath Datapath(
    .clk(CLOCK_50), 
    .Reset(reset),
    .data_in(Data_Out), //player score
    .state(state), //state of game
    .player_signal(playerSignal),  // player input hit or miss
    .enable_control(enable_control), // switch back from mole to game screen
	.data_result(Data_In), // result of data
    .wren(wren) // read write
);
	
  GameFSM gameFSM (
      .clk(CLOCK_50),
      .reset(reset),
      .input_signal(~KEY[1]),
      .control_signal(~KEY[2]),
		.timer_signal(~KEY[3]),
      .state(state),
      .game_start(game_start),
      .draw_enable(draw_enable)
  );
 drawImage drawImage (
     .iResetn(reset),
     .iClock(CLOCK_50),
     .iState(state),
      .iEnable(draw_enable),// enable when state changes
     .oX(x),
     .oY(y),
     .oColour(color),
     .oPlot(plot)
 );

  vga_adapter VGA (
      .resetn(reset),
      .clock(CLOCK_50),
      .colour(color),
      .x(x),
      .y(y),
      .plot(plot),// plot when done drawing
      /* Signals for the DAC to drive the monitor. */
      .VGA_R(VGA_R),
      .VGA_G(VGA_G),
      .VGA_B(VGA_B),
      .VGA_HS(VGA_HS),
      .VGA_VS(VGA_VS),
      .VGA_BLANK(VGA_BLANK_N),
      .VGA_SYNC(VGA_SYNC_N),
      .VGA_CLK(VGA_CLK)
  );
  defparam VGA.RESOLUTION = "160x120"; defparam VGA.MONOCHROME = "FALSE";
      defparam VGA.BITS_PER_COLOUR_CHANNEL = 1;
      defparam VGA.BACKGROUND_IMAGE = "whackstartscreen.mif";

  Audio_Controller Audio_Controller (
      // Inputs
      .CLOCK_50(CLOCK_50),
      .reset   (reset),

      .clear_audio_in_memory(),
      .read_audio_in        (read_audio_in),

      .clear_audio_out_memory  (),
      .left_channel_audio_out  (left_channel_audio_out),
      .right_channel_audio_out (right_channel_audio_out),
      .write_audio_out   (write_audio_out),

      .AUD_ADCDAT(AUD_ADCDAT),

      // Bidirectionals
      .AUD_BCLK   (AUD_BCLK),
      .AUD_ADCLRCK(AUD_ADCLRCK),
      .AUD_DACLRCK(AUD_DACLRCK),


      // Outputs
      .audio_in_available   (audio_in_available),
      .left_channel_audio_in  (left_channel_audio_in),
      .right_channel_audio_in  (right_channel_audio_in),

      .audio_out_allowed(audio_out_allowed),

      .AUD_XCK   (AUD_XCK),
      .AUD_DACDAT(AUD_DACDAT)

  );

  avconf #(
      .USE_MIC_INPUT(1)
  ) avc (
      .FPGA_I2C_SCLK(FPGA_I2C_SCLK),
      .FPGA_I2C_SDAT(FPGA_I2C_SDAT),
      .CLOCK_50     (CLOCK_50),
      .reset        (reset)
  );

/*****************************************************************************
 *                            Audio                                          *
 *****************************************************************************/
  always @(posedge CLOCK_50)
    if (delay_cnt == delay) begin
      delay_cnt <= 0;
      snd <= !snd;
    end else delay_cnt <= delay_cnt + 1;

  assign delay = {audio_sw, 15'd3000};

  wire [31:0] sound = (audio_sw == 0) ? 0 : snd ? 32'd10000000 : -32'd10000000;

  assign read_audio_in = audio_in_available & audio_out_allowed;

  assign left_channel_audio_out = left_channel_audio_in + sound;
  assign right_channel_audio_out = right_channel_audio_in + sound;
  assign write_audio_out = audio_in_available & audio_out_allowed;


/*****************************************************************************
 *                         State Machine LED                                 *
 *****************************************************************************/
  assign LEDR[6:0] = outputLED;
  always @(posedge CLOCK_50) begin
    outputLED <= 7'b0;  // Reset all LEDs
    case (state)
      Start:    outputLED[0] <= 1'b1;
      Game:     outputLED[1] <= 1'b1;
      Mole1:    outputLED[2] <= 1'b1;
      Mole2:    outputLED[3] <= 1'b1;
      Mole3:    outputLED[4] <= 1'b1;
      Mole4:    outputLED[5] <= 1'b1;
      GameOver: outputLED[6] <= 1'b1;
    endcase
  end
  
  assign LEDR[7] = draw_enable;
  assign LEDR[8] = plot;

endmodule





