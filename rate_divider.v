module rate_divider (
    input Clk,
    input Reset,
    output reg Enable
);
	
  reg [26:0] counter;
  
  initial begin
		counter <= 27'b010111110101111000010000000;
  end
  
  always @(posedge Clk) begin
    if (Reset) begin
		counter <= 27'b010111110101111000010000000;
		Enable <= 1'b0;
    end

    else begin
		if (counter == 27'b0) begin 
			counter <= 27'b010111110101111000010000000;
			Enable <= 1'b1;
		end 
		else begin
			counter <= counter - 1;
			Enable <= 1'b0;
		end
	end
  end

endmodule

// for game input and changing screen
// memory
