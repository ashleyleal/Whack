module Crossing (
  input clk,
  input clk2,
  input reset,
  input [7:0] data_in,
  output reg [7:0] data_out
);
  reg [7:0] data;
  
  always @(posedge clk) begin
    if (reset) begin
      data <= 0;
    end 
	 
	 else begin
		data <= data_in;
    end
  end
  
  always @(posedge clk2) begin
    if (reset) begin
		data_out <= 0;
	 end
	 else begin
		data_out <= data;
	 end
	end
endmodule