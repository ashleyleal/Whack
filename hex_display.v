// HexDecoder and DisplayCounter for Physical Score Counter
// Need BCD in order to display two digit numbers in decimal on the 7-segment display**

// top level module
module PointCounter ( 
    input Clck,
    input reset,
    input [7:0] Data_In, // from game memory module
    output [6:0] HEX4,
    output [6:0] HEX5,
);
    wire case4;
    wire case5;

    initial begin
        case4 = 4'd0;
        case5 = 4'd0;
    end
    
    // Instantiate Display Counter
	  DisplayCounter DCInst (
	    .Clock(Clck),
	    .reset(reset),
	    .data(Data_In),
            .case1(case4),
            .case2(case5)
	  );

	// Hex Decoder
	HexPoint HexInst (
	.hex(case4), .hex1(case5), .display(HEX4), 
	.display1(HEX5)		 
	);

end module
        
module DisplayCounter (
    input Clock,
    input Reset,
    input [7:0] data,
	output reg [3:0] case4,
    output reg [3:0] case5,
);
    always @(posedge Clock)
    begin
	  if (reset) begin
		case4 <= 4'd0;
		case5 <= 4'd0;
	  end
	  else begin
		case4 <= data % 10;
		case5 <= data - (data % 10);
	  end
    end
endmodule

// Hex Display Module
module HexPoint(
    input [3:0] hex4,
    input [3:0] hex5,
    output reg [6:0] display4,
    output reg [6:0] display5,
);
always @(*)
    begin
        case(hex4)
        7'd0: display4 = 7'b1000000; // 0
        7'd1: display4 = 7'b1111001; // 1
        7'd2: display4 = 7'b0100100; // 2
        7'd3: display4 = 7'b0110000; // 3
        7'd4: display4 = 7'b0011001; // 4
        7'd5: display4 = 7'b0010010; // 5
        7'd6: display4 = 7'b0000010; // 6
        7'd7: display4 = 7'b1111000; // 7
        7'd8: display4 = 7'b0000000; // 8
        7'd9: display4 = 7'b0010000; // 9
        default: display4 = 7'b1111111; // Display nothing
		endcase
		
        case(hex5)
        7'd0: display5 = 7'b1000000; // 0
        7'd1: display5 = 7'b1111001; // 1
        7'd2: display5 = 7'b0100100; // 2
        7'd3: display5 = 7'b0110000; // 3
        7'd4: display5 = 7'b0011001; // 4
        7'd5: display5 = 7'b0010010; // 5
        7'd6: display5 = 7'b0000010; // 6
        7'd7: display5 = 7'b1111000; // 7
        7'd8: display5 = 7'b0000000; // 8
        7'd9: display5 = 7'b0010000; // 9
        default: display5 = 7'b1111111; // Display nothing
		endcase
    end
endmodule
