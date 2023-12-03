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
            .case1(case4),
            .case2(case5),
	  );

		// Hex Decoder
		HexDecoder HexInst (
            .hex(case4), .hex1(case5), .display(HEX4), 
            .display1(HEX5))
		 );

end module
        
module DisplayCounter (
    input Clock,
    input Reset,
    output reg [3;0] case4,
    output reg [3:0] case5,
);
    lways @(posedge Clock)
    begin
	  if (reset || enable) begin
			case4 <= 4'd0;
			case5 <= 4'd0;
	  end
    end
    else begin
            if (case4 >= 4'd9) begin
				case4 <= 4'd0;
				case5 <= case5 + 1;
			end
            else if (case4 < 4'd9) begin
				case4 <= case4 + 1;
			end
			
            if (case5 > 4'd9) begin
				case5 <= 4'd0;
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
		
        case(hex5)
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
        default: display1 = 7'b1111111; // Display nothing
		endcase
    end
endmodule
