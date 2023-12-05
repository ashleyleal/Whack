// FSM module for game state control logic
module GameFSM (

  input clk, // 50 MHz clock
  input reset, // reset signal
  input input_signal, // input signal from start button
  input control_signal, // input signal from datapath
  input timer_signal, // input signal from datapath
  output reg [3:0] state, // output signal to other modules
	output reg game_start, // output signal to Game Timer (data path updates based on state)
  output reg draw_enable // output signal to VGA draw
);

  wire [1:0] random_num;  // random number from RNG module
  reg  [1:0] seed;  // seed value for RNG module

  reg control, inputS, timer;  // enable signals for FSM

  initial begin
    control = 1'b0;
    inputS = 1'b0;
    timer = 1'b0;
    seed = 2'b00;
  end

  RandomNumberGenerator RNG (
      .clock(clk),
      .Reset(control_signal),
      .seed(seed),
      .random_num(random_num)
  );

  // Enumerated type for FSM states
  localparam  
  Start = 3'b000,
  Game = 3'b001,
  Mole1 = 3'b010,
  Mole2 = 3'b011,
  Mole3 = 3'b100,
  Mole4 = 3'b101,
  GameOver = 3'b110;

  // FSM state register
  reg [3:0] current_state, next_state;

  // Next state logic aka our state tablec
  always @(*) begin : state_table
    case (current_state)
      Start: next_state = inputS ? Game : Start;

      Game: begin
        if (timer) begin  // timer takes priority over control signal
          next_state = GameOver;
        end else if (control) begin
          case (random_num)
            2'b00:   next_state = Mole1;
            2'b01:   next_state = Mole2;
            2'b10:   next_state = Mole3;
            2'b11:   next_state = Mole4;
            default: next_state = Game;
          endcase
        end else begin
          next_state = Game;
        end
      end

      Mole1: next_state = control ? Game : Mole1;
      Mole2: next_state = control ? Game : Mole2;
      Mole3: next_state = control ? Game : Mole3;
      Mole4: next_state = control ? Game : Mole4;

      GameOver: next_state = inputS ? Start : GameOver;
      default:  next_state = Start;
    endcase
  end  // state_table

  // Output logic aka all of our datapath control signals
  always @(*) begin : enable_signals
    // By default make all our signals 0
    draw_enable = 1'b0;
    game_start  = 1'b0;

    case (current_state)
      Start, Game, Mole1, Mole2, Mole3, Mole4, GameOver: draw_enable = 1'b1;
      Start: game_start = 1'b1;
    endcase
  end

  // Output logic
  always @(posedge clk) begin : state_FFS

    if (reset) begin
      current_state <= Start;
      control <= 1'b0;
      inputS <= 1'b0;
      timer <= 1'b0;
      seed <= 2'b00;

    end else begin
      current_state <= next_state;
      state <= current_state;
      control <= control_signal;
      inputS <= input_signal;
      timer <= timer_signal;
      seed <= random_num;
    end

  end  // state_FFS

endmodule

module RandomNumberGenerator (
    input wire clock,
    input wire Reset,
    input wire [1:0] seed,  // Input for seed value, use SW
    output reg [1:0] random_num  // random number output is 2 bits
);

  reg [1:0] lfsr;

  always @(posedge clock or posedge Reset) begin
    if (Reset) begin
      lfsr <= seed;  // Initialize with the seed value, manually change
    end else begin
      // LFSR feedback polynomial: x^2 + x + 1
      lfsr[0] <= lfsr[0] ^ lfsr[1];
      lfsr[1] <= lfsr[0] ^ ~lfsr[1];
    end
  end

  always @(posedge clock) begin
    random_num <= lfsr;
    if (random_num == lfsr) begin
      random_num <= lfsr + 1'b1;
    end
  end

endmodule
