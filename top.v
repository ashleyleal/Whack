// Protect against undefined nets
`default_nettype none

// Top Level Module (Main)

module Top (CLOCK_50, KEY, SW, LEDR, VGA_CLK, VGA_HS, VGA_VS, VGA_BLANK_N, VGA_SYNC_N, VGA_R, VGA_G, VGA_B);
    input  wire         CLOCK_50;   // DE-series 50 MHz clock signal
    input  wire [ 3: 0] KEY;        // DE-series pushbuttons
    input  wire [ 9: 0] SW;         // DE-series switches
    output wire [ 9: 0] LEDR;       // DE-series LEDs
	
	output			VGA_CLK;   				//	VGA Clock
	output			VGA_HS;					//	VGA H_SYNC
	output			VGA_VS;					//	VGA V_SYNC
	output			VGA_BLANK_N;			//	VGA BLANK
	output			VGA_SYNC_N;				//	VGA SYNC
	output	[7:0]	VGA_R;   				//	VGA Red[7:0] 
	output	[7:0]	VGA_G;	 				//	VGA Green[7:0]
	output	[7:0]	VGA_B;					//	VGA Blue[7:0]

    reg [11:0] colour;
    wire [7:0] bgx, bgy;
	reg [7:0] x, y;
	reg writeEn;
	wire resetn;
	assign resetn = KEY[0]; // reset everything switch

    wire [11:0] startColour;
    wire [11:0] gameColour;

    reg [11:0] address;
    wire [11:0] outAddress; 

    // Signals from FSM
    wire isStart; isGame, isGameEnd;

    // Signals from datapath
    wire [1:0] hit_miss; 
    wire control_signal, timer_signal;

    // Instantiate memory modules to display frames (need to update)
    start startBG(.address(address), .clock(CLOCK_50), .q(startColour));
    game gameBG(.address(address), .clock(CLOCK_50), .q(gameColour));

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
		defparam VGA.BACKGROUND_IMAGE = "black.mif";

    // Instantiate FSM
    GameFSM MainFSM(.clk(CLOCK_50), .reset(resetn), .input_signal(KEY[1]), .control_signal(control_signal), .hit_miss(hit_miss), .timer_signal(timer_signal), .output_start(isStart), .output_game(isGame), .output_game_end(isGameEnd)); 
    // Control signal will be from the datapath module (logic)
    // Hit_miss signal will be from the datapath module (logic)
    // Timer signal will be from a timer module, need rate divider and clock crossing

    always @(*) begin
        if (isStart) begin
            colour <= startColour;
            x <= bgx
            y <= bgy
            address <= outAddress;
        end
        else if (isGame) begin
            colour <= gameColour;
            x <= bgx
            y <= bgy
            address <= outAddress;
        end 
        else begin
            address <= 0;
            x <= 0;
            y < 0;
        end
        
    end

endmodule

