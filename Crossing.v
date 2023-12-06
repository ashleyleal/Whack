module Crossing (
  input clk,
  input clk2,
  input reset,
  input [7:0] data_in,
  output reg [7:0] data_out
);
  reg [7:0] data_temp;
  reg [7:0] data_temp1;
  
  always @(posedge clk) begin
    if (reset) begin
      data_temp <= 0;
    end 
	 
	 else begin
		data_temp <= data_in;
    end
  end
  always @(posedge clk2) begin
    if (reset) begin
		data_temp1 <= 0;
	 end
	 else begin
		data_temp1 <= data_temp;
	 end
	end

  always @(posedge clk2) begin
    if (reset) begin
		data_out <= 0;
	 end
	 else begin
		data_out <= data_temp1;
	 end
	end
endmodule
