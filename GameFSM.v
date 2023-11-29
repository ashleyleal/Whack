// FSM module for game state control logic
module GameFSM (
  input wire clk,    // Clock input
  input wire reset,  // Reset input - KEY[0]
  input wire input_signal,  // Single input signal - KEY[1]
  input wire control_signal, // Control signal, used to exit transition states, signal for when loading data is done and ready to move on to next state
  input wire [1:0] hit_miss, // Hit or miss signal, used to determine whether to go to hit or miss state
    // 2'b00: no hit or miss
    // 2'b01: hit
    // 2'b10: miss
  input wire timer_signal, // Game Timer signal, used to exit game state
  
  output reg output_start, // Output signal for start state
  output reg output_game, // Output signal for game state
  output reg output_game_end // Output signal for game end state  
);

// Enumerated type for FSM states
  localparam  
  Start = 3'b000, 
  Start_To_Game = 3'b001, 
  Game = 3'b010,
  Game_To_GameEnd = 3'b011,
  GameEnd = 3'b100,
  // Game substates
  Game_Hit = 3'b101,
  Game_Miss = 3'b110;

// FSM state register
reg [2:0] current_state, next_state;

// Next state logic
always@(*)
begin: state_table
  case (current_state)
    Start: next_state = input_signal ? Start_To_Game : Start;
    Start_To_Game: next_state = control_signal ? Game : Start_To_Game;
    Game:
      timer_signal ? next_state = Game_To_GameEnd: Game; // Always check for timer signal first, if it's high while in game state, go to game end state
      case (hit_miss)
        2'b01: next_state = Game_Hit;
        2'b10: next_state = Game_Miss;
        default: next_state = Game;
      endcase
    Game_Hit: next_state = control_signal ? Game : Game_Hit;
    Game_Miss: next_state = control_signal ? Game : Game_Miss;
    Game_To_GameEnd: next_state = control_signal ? GameEnd : Game_To_GameEnd;
    GameEnd: next_state = input_signal ? Start : GameEnd;

    default: next_state = Start;
  endcase
end // state_table

// Initial state assignment
always @(posedge clk or posedge reset)
  if (reset)
    current_state <= Start; // if reset, return to Start state
  else
    current_state <= next_state;

// Output logic
always@(posedge clk)
begin: state_FFS
  output_start = (current_state == Start);
  output_game = (current_state == Game);
  output_game_end = (current_state == GameEnd);
end // state_FFS

endmodule
