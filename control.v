module control(
    input clk,
    input Reset,
    input go,
    input wire game_over,
    output reg valid_whack,
    );

    reg [3:0] current_state, next_state;

    // STATES:
        // S_START
        // S_GAME_ACTIVE
        // S_GAME_MISSED
        // S_GAME_WHACKED
        // S_GAME_OVER


    localparam      
                S_START              = 4'd0,
                S_START_WAIT         = 4'd1,
                S_GAME_ACTIVE        = 4'd2,
                S_GAME_ACTIVE_WAIT   = 4'd3,
                S_GAME_MISSED        = 4'd4,
                S_GAME_MISSED_WAIT   = 4'd5,
                S_GAME_WHACKED       = 4'd6,
                S_GAME_WHACKED_WAIT  = 4'd7,
                S_GAME_OVER          = 4'd8,
                S_GAME_OVER_WAIT     = 4'd9,

    // Next state logic aka our state table
    always@(*)
    begin: state_table
            case (current_state)

                S_START: next_state = go ? S_START_WAIT : S_START;
                S_START_WAIT: next_state = go ? S_GAME_ACTIVE : S_START_WAIT; //start to game
                
                S_GAME_ACTIVE: next_state = go ? S_GAME_ACTIVE_WAIT : S_GAME_ACTIVE;
                S_GAME_ACTIVE_WAIT: 
                    if (~game_over & go) next_state = S_GAME_WHACKED;
                    else if (~game_over & ~go) next_state = S_GAME_MISSED;
                    else next_state = S_GAME_OVER;
                S_GAME_MISSED: next_state = go ? S_GAME_MISSED_WAIT : S_GAME_MISSED;
                S_GAME_MISSED_WAIT: 
                    if (game_over) next_state = S_GAME_OVER;
                    else if (go) next_state = S_GAME_ACTIVE;
                    else next_state = S_GAME_MISSED;
                S_GAME_WHACKED: next_state = go ? S_GAME_WHACKED_WAIT : S_GAME_WHACKED;
                S_GAME_WHACKED_WAIT: 
                    if (game_over) next_state = S_GAME_OVER;
                    else if (go) next_state = S_GAME_ACTIVE;
                    else next_state = S_GAME_WHACKED;
                S_GAME_OVER: next_state = go ? S_GAME_OVER_WAIT : S_GAME_OVER;
                S_GAME_OVER_WAIT:
                    if (go) next_state = S_START;
                    else next_state = S_GAME_OVER;
            default:     next_state = S_START;
        endcase
    end // state_table


    // Output logic aka all of our datapath control signals
    always @(*)
    begin: enable_signals
        // By default make all our signals 0
        game_over = 1'b0;
        valid_whack = 1'b0;


        case (current_state)

            S_START: begin 

            end
            S_GAME_ACTIVE: begin 
                valid_whack = 1'b0;
            end
            S_GAME_MISSED: begin 
                valid_whack = 1'b0;
            end
            S_GAME_WHACKED: begin 
                valid_whack = 1'b1;
            end
            S_GAME_OVER: begin 
                game_over = 1'b1;
            end
            

        // default:    // don't need default since we already made sure all of our outputs were assigned a value at the start of the always block
        endcase
    end // enable_signals

    // current_state registers
    always@(posedge clk)
    begin: state_FFs
        if(Reset)
            current_state <= S_START;
        else
            current_state <= next_state;
    end // state_FFS

endmodule