// FSM module for game state control logic
module GameFSM (

  input clk, // 50 MHz clock
  input reset, // reset signal
  input input_signal, // input signal from start button
  input control_signal, // input signal from datapath
  input timer_signal, // input signal from datapath
  input delay_done, // input signal from delay module
  output reg [3:0] state // output signal to other modules
);

wire [1:0] random_num; // random number from RNG module
wire [1:0] seed; // seed value for RNG module

wire control, input, timer, delay; // enable signals for FSM

initial begin
  control = 1'b0;
  input = 1'b0;
  timer = 1'b0;
  delay = 1'b0;
end

RandomNumberGenerator RNG(.clock(clk), .Reset(reset), .seed(seed), .random_num(random_num));

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
reg [2:0] current_state, next_state;

// Next state logic
always@(*)
begin: state_table
  case (current_state)

    Start: next_state = input ? Game : Start;
    
    Game: 
      if (timer_signal) begin // timer takes priority over control signal
        next_state = GameOver;
      end
      else if (control) begin
        case (random_num)
          2'b00: next_state = Mole1;
          2'b01: next_state = Mole2;
          2'b10: next_state = Mole3;
          2'b11: next_state = Mole4;
          default: next_state = Game;
        endcase
      end
      else begin 
        next_state = Game;
      end
    
    Mole1: next_state = control ? Game : Mole1; 
    Mole2: next_state = control ? Game : Mole2; 
    Mole3: next_state = control ? Game : Mole3; 
    Mole4: next_state = control ? Game : Mole4; 

    GameOver: next_state = input ? Start : GameOver;
        
    default: next_state = Start;
  endcase
end // state_table

// Initial state assignment
always @(posedge clk or posedge reset)
  if (reset)
    current_state <= Start; // if reset, return to Start state
    control = 1'b0;
    input = 1'b0;
    timer = 1'b0;
    delay = 1'b0;
  else
    current_state <= next_state;

// Output logic
always@(posedge clk)
begin: state_FFS
	state <= current_state;
  control <= control_signal;
  input <= input_signal;
  timer <= timer_signal;
  delay <= delay_done;
  seed <= random_num;
end // state_FFS

endmodule
