// HexDecoder and DisplayCounter for Physical Score Counter
// Need BCD in order to display two digit numbers in decimal on the 7-segment display**

module DisplayCounter (
    input Clock,
    input Reset,
    input EnableDC,
    // 4 for hexadecimal
    output reg [3:0] CounterValue
);
    always @(posedge Clock)
    begin
        if (Reset == 1'b1) begin
            CounterValue <= 4'b0;
        end
        else if (EnableDC == 1'b1) begin
            CounterValue <= CounterValue + 1;
        end
    end
endmodule

module HexDecoder(
    input [3:0] hex, 
    output reg [6:0] display
);
always @(*)
    begin
    case(hex)
        4'h0: display = 7'b1000000; // 0
        4'h1: display = 7'b1111001; // 1
        4'h2: display = 7'b0100100; // 2
        4'h3: display = 7'b0110000; // 3
        4'h4: display = 7'b0011001; // 4
        4'h5: display = 7'b0010010; // 5
        4'h6: display = 7'b0000010; // 6
        4'h7: display = 7'b1111000; // 7
        4'h8: display = 7'b0000000; // 8
        4'h9: display = 7'b0010000; // 9
        4'ha: display = 7'b0001000; // A
        4'hb: display = 7'b0000011; // B
        4'hc: display = 7'b1000110; // C
        4'hd: display = 7'b0100001; // D
        4'he: display = 7'b0000110; // E
        4'hf: display = 7'b0001110; // F
        default: display = 7'b1111111; // Display nothing
    endcase
end
endmodule