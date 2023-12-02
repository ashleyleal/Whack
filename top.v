module Top (CLOCK_50, KEY, SW, LEDR, 		
    VGA_CLK,   						//	VGA Clock
		VGA_HS,							//	VGA H_SYNC
		VGA_VS,							//	VGA V_SYNC
		VGA_BLANK_N,						//	VGA BLANK
		VGA_SYNC_N,						//	VGA SYNC
		VGA_R,   						//	VGA Red[9:0]
		VGA_G,	 						//	VGA Green[9:0]
		VGA_B)   						//	VGA Blue[9:0]);
    
    input  wire         CLOCK_50;   // DE-series 50 MHz clock signal
    input  wire [ 3: 0] KEY;        // DE-series pushbuttons
    input  wire [ 9: 0] SW;         // DE-series SW switches
    output wire [ 9: 0] LEDR;       // DE-series LEDs
	  output			VGA_CLK;   				//	VGA Clock
	  output			VGA_HS;					//	VGA H_SYNC
	  output			VGA_VS;					//	VGA V_SYNC
	  output			VGA_BLANK_N;				//	VGA BLANK
	  output			VGA_SYNC_N;				//	VGA SYNC
	  output	[7:0]	VGA_R;   				//	VGA Red[7:0] Changed from 10 to 8-bit DAC
	  output	[7:0]	VGA_G;	 				//	VGA Green[7:0]
	  output	[7:0]	VGA_B;   				//	VGA Blue[7:0]
    
    // Wires for the draw module
    wire         [ 7: 0] x;
    wire         [ 6: 0] y;
    wire         [ 2: 0] color;

    wire        reset;
    reg [6:0] outputLED; // for testing signals

    // Wires for the FSM module
    wire        [ 2: 0] state;

    assign reset = SW[0];

    // states
    localparam
    Start = 3'b000,
    Game = 3'b001,
    Mole1 = 3'b010,
    Mole2 = 3'b011,
    Mole3 = 3'b100,
    Mole4 = 3'b101,
    GameOver = 3'b110;

    // Module instantiations
    GameFSM gameFSM(.clk(CLOCK_50), .reset(reset), .input_signal(KEY[1]), .control_signal(KEY[2]), .timer_signal(KEY[3]), .state(state));
    drawImage drawImage(.iResetn(reset), .iClock(CLOCK_50), .iState(state), .oX(x), .oY(y), .oColour(color), .oPlot(plot));

    vga_adapter VGA(
			.resetn(reset),
			.clock(CLOCK_50),
			.colour(colour),
			.x(x),
			.y(y),
			.plot(plot),
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

    // Using DESIM VGA Adapter, need to change to one for board later

    assign VGA_X     = x;
    assign VGA_Y     = y;
    assign VGA_COLOR = color;
    assign plot      = 1'b1;

// show state signals on led for now
assign LEDR = outputLED;
always @(posedge CLOCK_50) begin
    if (state == Start) begin
      outputLED[0] <= 1'b1;
      outputLED[1] <= 1'b0;
      outputLED[2] <= 1'b0;
      outputLED[3] <= 1'b0;
      outputLED[4] <= 1'b0;
      outputLED[5] <= 1'b0;
      outputLED[6] <= 1'b0;
    end
    else if (state == Game) begin
      outputLED[0] <= 1'b0;
      outputLED[1] <= 1'b1;
      outputLED[2] <= 1'b0;
      outputLED[3] <= 1'b0;
      outputLED[4] <= 1'b0;
      outputLED[5] <= 1'b0;
      outputLED[6] <= 1'b0;
    end
    else if (state == Mole1) begin
      outputLED[0] <= 1'b0;
      outputLED[1] <= 1'b0;
      outputLED[2] <= 1'b1;
      outputLED[3] <= 1'b0;
      outputLED[4] <= 1'b0;
      outputLED[5] <= 1'b0;
      outputLED[6] <= 1'b0;
    end
    else if (state == Mole2) begin
      outputLED[0] <= 1'b0;
      outputLED[1] <= 1'b0;
      outputLED[2] <= 1'b0;
      outputLED[3] <= 1'b1;
      outputLED[4] <= 1'b0;
      outputLED[5] <= 1'b0;
      outputLED[6] <= 1'b0;
    end
    else if (state == Mole3) begin
      outputLED[0] <= 1'b0;
      outputLED[1] <= 1'b0;
      outputLED[2] <= 1'b0;
      outputLED[3] <= 1'b0;
      outputLED[4] <= 1'b1;
      outputLED[5] <= 1'b0;
      outputLED[6] <= 1'b0;
    end
    else if (state == Mole4) begin
      outputLED[0] <= 1'b0;
      outputLED[1] <= 1'b0;
      outputLED[2] <= 1'b0;
      outputLED[3] <= 1'b0;
      outputLED[4] <= 1'b0;
      outputLED[5] <= 1'b1;
      outputLED[6] <= 1'b0;
    end
    else if (state == GameOver) begin
      outputLED[0] <= 1'b0;
      outputLED[1] <= 1'b0;
      outputLED[2] <= 1'b0;
      outputLED[3] <= 1'b0;
      outputLED[4] <= 1'b0;
      outputLED[5] <= 1'b0;
      outputLED[6] <= 1'b1;
    end
    // else begin
    //   outputLED <= 0;
    // end
  end

endmodule





