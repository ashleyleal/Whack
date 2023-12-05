// HexDecoder and DisplayCounter for Physical Score Counter
// Need BCD in order to display two digit numbers in decimal on the 7-segment display**

// top level module
module hex_display ( 
    input Clck,
    input reset,
    input [7:0] Data_In, // from game memory module
    output [6:0] HEX4,
    output [6:0] HEX5
);
	wire [7:0] case4;
	wire [7:0] case5;

    // Instantiate Display Counter
	  DisplayCounter dc(
	    .Clock(Clck),
	    .Reset(reset),
	    .data(Data_In),
       .case4(case4),
       .case5(case5)
	  );

	// Hex Decoder
	HexPoint hp(
	.hex4(case4), .hex5(case5), 
	.display4(HEX4), 
	.display5(HEX5)		 
	);

endmodule
        
module DisplayCounter (
    input Clock,
    input Reset,
    input [7:0] data,
    output reg [7:0] case4,
    output reg [7:0] case5
);

	 initial begin
		case4 = 8'b0;
		case5 = 8'b0;
	 end
	 
    always @(posedge Clock)
    begin
	  if (Reset) begin
		case4 <= 8'b0;
		case5 <= 8'b0;
	  end
	  else begin
		case4 <= data % 10;
		case5 <= (data - (data % 10)) / 10;
	  end
    end
endmodule

// Hex Display Module
module HexPoint(
    input [7:0] hex4,
    input [7:0] hex5,
    output reg [6:0] display4,
    output reg [6:0] display5
);
always @(*)
    begin
        case(hex4)
        8'b0: display4 = 7'b1000000; // 0
        8'b00000001: display4 = 7'b1111001; // 1
        8'b00000010: display4 = 7'b0100100; // 2
        8'b00000011: display4 = 7'b0110000; // 3
        8'b00000100: display4 = 7'b0011001; // 4
        8'b00000101: display4 = 7'b0010010; // 5
        8'b00000110: display4 = 7'b0000010; // 6
        8'b00000111: display4 = 7'b1111000; // 7
        8'b00001000: display4 = 7'b0000000; // 8
        8'b00001001: display4 = 7'b0010000; // 9
        default: display4 = 7'b1111111; // Display nothing
		endcase
		
        case(hex5)
        8'b0: display5 = 7'b1000000; // 0
        8'b00000001: display5 = 7'b1111001; // 1
        8'b00000010: display5 = 7'b0100100; // 2
        8'b00000011: display5 = 7'b0110000; // 3
        8'b00000100: display5 = 7'b0011001; // 4
        8'b00000101: display5 = 7'b0010010; // 5
        8'b00000110: display5 = 7'b0000010; // 6
        8'b00000111: display5 = 7'b1111000; // 7
        8'b00001000: display5 = 7'b0000000; // 8
        8'b00001001: display5 = 7'b0010000; // 9
        default: display5 = 7'b1111111; // Display nothing
		endcase
    end
endmodule
