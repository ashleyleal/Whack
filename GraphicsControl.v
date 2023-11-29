// GraphicsControl module for VGA display


module GraphicsControl (
    iResetn,
    iPlotBox,
    iBlack,
    iColour,
    iLoadX,
    iXY_Coord,
    iClock,
    oX,
    oY,
    oColour,
    oPlot,
    oDone
);

// 
  parameter X_SCREEN_PIXELS = 7'd80;
  parameter Y_SCREEN_PIXELS = 6'd60;

  input wire iResetn, iPlotBox, iBlack, iLoadX;
  input wire [2:0] iColour;
  input wire [6:0] iXY_Coord;
  input wire iClock;
  output wire [7:0] oX;  // VGA pixel coordinates
  output wire [6:0] oY;

  output wire [2:0] oColour;  // VGA pixel colour (0-7)
  output wire oPlot;  // Pixel draw enable
  output wire oDone;  // goes high when finished drawing frame

  wire ld_x, ld_y, ld_c, black_en, finish, blackDone;

  control C0 (
      .clk(iClock),
      .Reset(iResetn),
      .black(iBlack),
      .ld_x(ld_x),
      .ld_y(ld_y),
      .draw(iPlotBox),
      .ld(iLoadX),
      .write_en(oPlot),
      .finish(finish),
      .blackDone(blackDone),
      .black_en(black_en),
      .oDone(oDone)
  );

  datapath D0 (
      .clk  (iClock),
      .Reset(iResetn),
      .ld_x (ld_x),
      .ld_y (ld_y),

      .x(oX),
      .y(oY),
      .black_en(iBlack),
      .data_in(iXY_Coord),
      .color(oColour),
      .color_in(iColour),
      .start(oPlot),
      .finish(finish),
      .blackDone(blackDone)
  );




endmodule  // part2

// contains states for each game frame; 
module control (
    input clk,
    input Reset,
    input black,
    input blackDone,
    input finish,
    output reg write_en,
    input ld,
    input draw,
    output reg ld_x,
    ld_y,
    black_en,
    oDone
);

  reg [2:0] current_state, next_state;

  localparam  S_LOAD_x        = 3'd0,
              S_LOAD_x_wait   = 3'd1,
              S_LOAD_y        = 3'd2,
              S_LOAD_y_wait   = 3'd3,
              Drawing		   = 3'd4,
              S_Black         = 3'd5, 
              Done            = 3'd6;

  // Next state logic aka our state table
  always @(*) begin : state_table
    case (current_state)
      S_LOAD_x: next_state = black ? S_Black : (ld ? S_LOAD_x_wait : S_LOAD_x);
      S_LOAD_x_wait: next_state = black ? S_Black : (ld ? S_LOAD_x_wait : S_LOAD_y);
      S_LOAD_y: next_state = black ? S_Black : (draw ? S_LOAD_y_wait : S_LOAD_y);
      S_LOAD_y_wait: next_state = black ? S_Black : (draw ? S_LOAD_y_wait : Drawing);
      Drawing: next_state = black ? S_Black : (finish ? Done : Drawing);
      Done: next_state = black ? S_Black : (ld ? S_LOAD_x : Done);
      S_Black: next_state = blackDone ? Done : S_Black;
    endcase
  end

  // Output logic aka all of our datapath control signals
  always @(*) begin : enable_signals
    // By default make all our signals 0
    ld_x = 1'b0;
    ld_y = 1'b0;
    black_en = 1'b0;
    write_en = 1'b0;
    oDone = 1'b0;

    case (current_state)
      S_LOAD_x: begin
        ld_x = 1'b1;
      end
      S_LOAD_y: begin
        ld_y = 1'b1;
      end
      Drawing: begin
        write_en = 1'b1;
      end
      S_Black: begin
        black_en = 1'b1;
      end
      Done: begin
        oDone = 1'b1;
        write_en = 1'b0;  //disable write on done
      end
    endcase
  end

  // current_state registers
  always @(posedge clk) begin : state_FFs
    if (Reset) begin
      current_state <= next_state;
      oDone <= black ? 1'b0 : oDone;
    end else begin
      current_state <= S_LOAD_x;
      oDone <= 1'b0;
    end
  end  // state_FFS
endmodule

module datapath (
    input clk,
    input Reset,
    input start,
    input [6:0] data_in,
    input ld_x,
    ld_y,
    input [2:0] color_in,
    input black_en,
    output reg [2:0] color,
    output reg [7:0] x,
    output reg [6:0] y,
    output reg blackDone,
    finish
);

  reg [7:0] x_prev;
  reg [6:0] y_prev;
  reg [7:0] x_counter, y_counter;
  reg [4:0] draw_counter;

  // Registers x, y, color, x with respective input logic
  always @(posedge clk) begin
    if (Reset) begin
      if (ld_x) begin
        x <= {1'b0, data_in};
        x_prev <= {1'b0, data_in};
      end
      if (ld_y) begin
        y <= data_in;
        y_prev <= data_in;
        color <= color_in;
      end
    end else if (black_en) begin
      x_prev <= 8'b0;
      y_prev <= 7'b0;
      color  <= 3'b0;
    end else begin
      x_prev <= 8'b0;
      x <= 8'b0;
      y <= 7'b0;
      y_prev <= 7'b0;
      color <= 3'b0;
      finish = 1'b0;
      blackDone = 1'b0;
    end

    if (!Reset) begin
      draw_counter = 5'b0;
      x_counter <= 8'b0;
      y_counter <= 8'b0;
    end else if (black_en) begin
      if (x_counter == 8'b10100000 & y_counter == 7'b1111000) begin
        blackDone = 1'b1;
        x_counter <= 8'b0;
        y_counter <= 8'b0;

      end else if (x_counter == 8'd159) begin
        x_counter <= 8'b0;
        y_counter <= y_counter + 1'b1;

      end else if (x_counter == 8'b0 & y_counter == 8'b0) begin
        blackDone = 1'b0;

      end else x_counter <= x_counter + 1'b1;
    end else if (start) begin
      if (draw_counter == 5'd16) begin
        draw_counter <= 5'b0;
        finish = 1'b1;
      end else begin
        finish <= 1'b0;
        x <= x_prev + {draw_counter[1], draw_counter[0]};  // update x with concatenation
        y <= y_prev + {draw_counter[3], draw_counter[2]};  // update x with concatenation
        draw_counter <= draw_counter + 1'b1;
      end
    end

  end

endmodule

// Nearest neighbour interpolation algorithm to upsample 80 x 60 to 640 x 480
module upsample ()

endmodule