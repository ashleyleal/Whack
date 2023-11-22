module control(
    input clk,
    input go,
    input wire game_over,

    output reg successful_whack,
    output reg  ld_alu_out,
    output reg [1:0]  alu_select_a, alu_select_b,
    output reg alu_op,
    output reg result_valid
    );

    reg [5:0] current_state, next_state;

    // STATES:
        // S_START
        // S_GAME_ACTIVE
        // S_GAME_MISSED
        // S_GAME_WHACKED
        // S_PAUSE
        // S_GAME_OVER


    localparam      
                S_START         = 3'd0,
                S_GAME_ACTIVE   = 3'd1,
                S_GAME_MISSED   = 3'd2,
                S_GAME_WHACKED  = 3'd3,
                S_GAME_OVER     = 3'd4,

    // Next state logic aka our state table
    always@(*)
    begin: state_table
            case (current_state)

                S_START: next_state = go ? S_GAME_ACTIVE : S_START; //start to game
                S_GAME_ACTIVE: 
                    if (~game_over & go) next_state = S_GAME_WHACKED;
                    else if (~game_over & ~go) next_state = S_GAME_MISSED;
                    else next_state = S_GAME_OVER;
                S_GAME_MISSED: 
                    if (game_over) next_state = S_GAME_OVER;
                    else if (go) next_state = S_GAME_ACTIVE;
                    else next_state = S_GAME_MISSED;
                S_GAME_WHACKED: 
                    if (game_over) next_state = S_GAME_OVER;
                    else if (go) next_state = S_GAME_ACTIVE;
                    else next_state = S_GAME_WHACKED;
                S_GAME_OVER:
                    if (go) next_state = S_START;
                    else next_state = S_GAME_OVER;
            default:     next_state = S_START;
        endcase
    end // state_table


    // Output logic aka all of our datapath control signals
    always @(*)
    begin: enable_signals
        // By default make all our signals 0
        ld_alu_out = 1'b0;
        ld_a = 1'b0;
        ld_b = 1'b0;
        ld_c = 1'b0;
        ld_x = 1'b0;
        ld_r = 1'b0;
        alu_select_a = 2'b0;
        alu_select_b = 2'b0;
        alu_op       = 1'b0;
        result_valid = 1'b0; 

        case (current_state)
            S_LOAD_A: begin
                ld_a = 1'b1;
                end
            S_LOAD_B: begin
                ld_b = 1'b1;
                end
            S_LOAD_C: begin
                ld_c = 1'b1;
                end
            S_LOAD_X: begin
                ld_x = 1'b1;
                end
            // Multiplication select a and x
            S_CYCLE_0: begin 
                ld_alu_out = 1'b1; 
                alu_select_a = 2'b00; // Select a
                alu_select_b = 2'b11; 
                ld_a = 1'b1; 
                alu_op = 1'b1; 
            end
            // Multiplication select b and x
            S_CYCLE_1: begin
                ld_alu_out = 1'b1; 
                alu_select_a = 2'b01; 
                alu_select_b = 2'b11; 
                ld_b = 1'b1; 
                alu_op = 1'b1; 
            end
            // Multiplication select a and x
             S_CYCLE_2: begin
                ld_alu_out = 1'b1;
                alu_select_a = 2'b00; // Select a
                alu_select_b = 2'b11; 
                ld_a = 1'b1; 
                alu_op = 1'b1; // Do multiply operation
            end
            // Addition select a and x
            S_CYCLE_3: begin
                ld_alu_out = 1'b1;
                alu_select_a = 2'b00; // Select a
                alu_select_b = 2'b01; 
                ld_a = 1'b1; 
                alu_op = 1'b0; // Do add operation
            end
            // Addition select a and x and store in r
            S_CYCLE_4: begin
                alu_select_a = 2'b00; // Select a
                alu_select_b = 2'b10; 
                ld_r = 1'b1; 
                alu_op = 1'b0; // Do add operation
            end
            S_CYCLE_5: begin
                result_valid = 1'b1; 
                ld_a = 1'b1;
            end
        // default:    // don't need default since we already made sure all of our outputs were assigned a value at the start of the always block
        endcase
    end // enable_signals

    // current_state registers
    always@(posedge clk)
    begin: state_FFs
        if(Reset)
            current_state <= S_LOAD_A;
        else
            current_state <= next_state;
    end // state_FFS
endmodule