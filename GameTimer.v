// Top Level Module
module GameTimer (
   input Clck,
	input enable, //game_done
	input reset,
	input game_start, //game started
	output [6:0] HEX0,
	output [6:0] HEX1,
	output [6:0] HEX2,
	output timer_signal;
);
  wire time_enable;
  wire [26:0] CounterValue
  wire [3:0] case1;
  wire [3:0] case2;
  wire [3:0] case3;

  initial begin
	case1 = 4'd0;
	case2 = 4'd0;
	case3 = 4'd0;
  end
	
	  // Instantiate Rate Divider
	  RateDivider #(
			.ClockIn(Clck),
			.Counter  (CounterValue),
		  	.Game (game_start),
			.Enable (time_enable)
	  );

	  // Instantiate Display Counter
	  DisplayCounter DCInst (
			.Clock(Clck),
			.enable(enable),
			.time_enable(time_enable),
			.reset(reset),
		  	.Game(game_start),
			.case1(case1),
			.case2(case2),
			.case3(case3),
			.time_signal(time_signal)
	  );

		// Hex Decoder
		HexDecoder HexInst (
			.hex(case1), .hex1(case2), .hex2(case3) .display(HEX0), 
			.display1(HEX1), .display2(HEX2)
		 );

endmodule

// Rate Divider Module takes a fast clock signal and divides its frequency to generate a slower pulse signal, enabling the DisplayCounter to update its value at controlled intervals
module RateDivider #(
    input ClockIn,
    output reg Counter,
    input Game,
    output reg Enable
);


	always @(posedge ClockIn) begin
		if (Reset || !Game) begin
			  counter <= 27d'50000000
			  Enable <= 0;
		  end

		  else begin
			 if (counter == 0) begin 
				counter <= 27'd50000000;
				Enable <= 1;
			 end 
			 else begin
				counter <= counter - 1;
				Enable <= 0;
			 end
		 end
    end
endmodule

// Display Counter Module keeps track of a 4-bit value and increments it when the RateDivider provides EnableDC; provides a continuous stream of hexadecimal values matching the current count state of the counter to show on display
module DisplayCounter (
    input Clock,
	 input enable,
	 input time_enable,
	 input reset,
	 input Game,
	 output reg [3:0] case1,
	 output reg [3:0] case2,
	 output reg [3:0] case3,
	 output reg time_signal
);
    reg flag;
    initial begin
	flag = 1'b0;
    end
	
    always @(posedge Clock)
    begin
	  if (time_enable == 1'b1) begin
		if (case1 == 0 && case2 == 0 && case3 == 0) begin
		  	flag <= 1'b1;
		end
		if (case1 >= 4'd9) begin
			case1 <= 4'd0;
			case2 <= case2 + 1;
			time_signal <= 1'd0;
		end
		else if (case1 < 4'd9 && flag) begin
			case1 <= case1 + 1;
			time_signal <= 1'd0;
		end
		
		if (case2 > 4'd5) begin
			case2 <= 4'd0;
			case3 <= case3 + 1;
			time_signal <= 1'd0;
		end
		
		if (case3 == 4'd1) begin
			time_signal <= 1'd1;
		end
	  end
	 else if (reset || enable || !Game) begin
		case1 <= 4'd0;
		case2 <= 4'd0;
		case3 <= 4'd0;
	  end
    end
endmodule

// Hex Display Module
module HexDecoder(
    input [3:0] hex,
	 input [3:0] hex1,
	 input [3:0] hex2,
    output reg [6:0] display,
	 output reg [6:0] display1,
	 output reg [6:0] display2
);
always @(*)
    begin
		case(hex)
        4'd0: display = 7'b1000000; // 0
        4'd1: display = 7'b1111001; // 1
        4'd2: display = 7'b0100100; // 2
        4'd3: display = 7'b0110000; // 3
        4'd4: display = 7'b0011001; // 4
        4'd5: display = 7'b0010010; // 5
        4'd6: display = 7'b0000010; // 6
        4'd7: display = 7'b1111000; // 7
        4'd8: display = 7'b0000000; // 8
        4'd9: display = 7'b0010000; // 9
        default: display = 7'b1111111; // Display nothing
		endcase
		
		case(hex1)
        4'd0: display1 = 7'b1000000; // 0
        4'd1: display1 = 7'b1111001; // 1
        4'd2: display1 = 7'b0100100; // 2
        4'd3: display1 = 7'b0110000; // 3
        4'd4: display1 = 7'b0011001; // 4
        4'd5: display1 = 7'b0010010; // 5
        default: display1 = 7'b1111111; // Display nothing
		endcase
		
		case(hex2)
        4'd0: display2 = 7'b1000000; // 0
        4'd1: display2 = 7'b1111001; // 1
        default: display2 = 7'b1111111; // Display nothing
		endcase
end
endmodule
