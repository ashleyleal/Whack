module RateDivider #(
    input ClockIn,
    input Reset,
    output Enable
);

  reg [26:0] counter;

  always @(posedge ClockIn) begin
    if (Reset) begin
		counter <= 27d'50000000;
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

// for game input and changing screen
// memory
