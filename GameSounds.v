// Play a high-pitched sound when there is a hit, and a low-pitched sound when there is a miss.

module GameSounds (
  input wire clk,    // Clock input
  input wire [1:0] hit_miss, // Hit or miss signal, used to determine whether to go to hit or miss state
  
    output //need to figure out what to output, want to send a sound signal to the speaker and choose frequency based on hit or miss from datapath
);

    case (hit_miss)
        2'b01: output = 1'b1;
        2'b10: output = 1'b0;
        default: output = 1'b0;
    endcase

    DE1_SoC_Audio_Example()

endmodule