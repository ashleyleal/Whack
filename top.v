module Top (CLOCK_50, KEY, SW, LEDR, VGA_X, VGA_Y, VGA_COLOR, plot);
    input  wire         CLOCK_50;   // DE-series 50 MHz clock signal
    input  wire [ 3: 0] KEY;        // DE-series pushbuttons
    input  wire [ 9: 0] SW;         // DE-series SW switches
    output wire [ 9: 0] LEDR;       // DE-series LEDs
    output wire [ 7: 0] VGA_X;      // "VGA" column
    output wire [ 6: 0] VGA_Y;      // "VGA" row
    output wire [ 2: 0] VGA_COLOR;  // "VGA pixel" colour (0-7)
    output wire         plot;       // "Pixel" is drawn when this is pulsed

    // Wires for the VGA module
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





