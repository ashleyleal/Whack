// Generates a psuedorandom two bit binary number to choose a "mole" using LFSR (Linear Feedback Shift Register)
// Needs rate divider (clock control) so that the random number is generated at a reasonable rate and not instantaneously
// At the moment, the random number is generated every clock cycle, which is too fast

module RandomNumberGenerator(
  input wire clock,
  input wire Reset,
  input wire [1:0] seed, // Input for seed value, use SW
  output reg [1:0] random_num // random number output is 2 bits
);

  reg [1:0] lfsr;

  always @(posedge clock or posedge Reset) begin
    if (Reset) begin
      lfsr <= seed; // Initialize with the seed value, manually change
    end else begin
      // LFSR feedback polynomial: x^2 + x + 1
      lfsr[0] <= lfsr[0] ^ lfsr[1];
      lfsr[1] <= lfsr[0] ^ lfsr[1];
    end
  end

  always @(posedge clock) begin
    random_num <= lfsr;
  end

endmodule
