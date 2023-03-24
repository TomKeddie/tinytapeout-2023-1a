// http://legionfonts.com/fonts/alphanumeric-lcd
module font_one(input [2:0] row, output [4:0] data);
  case(row)
    3'b000: assign data = 5'b00100;
    3'b001: assign data = 5'b01100;
    3'b010: assign data = 5'b00100;
    3'b011: assign data = 5'b00100;
    3'b100: assign data = 5'b00100;
    3'b101: assign data = 5'b00100;
    3'b110: assign data = 5'b01110;
  endcase // case (row)
endmodule

module led_panel_single (
	                     input       clk,
                         input       reset,
                         output      red_out,
                         output      blue_out,
                         output      aclk_out,
                         output      blank_out,
                         output      green_out,
                         output      arst_out,
                         output      sclk_out,
                         output      latch_out,
                         input [3:0] rowmax_in
                         );

  // column
  reg                                sclk;
  reg                                blank;
  reg                                latch;
  reg                                red;
  reg                                green;
  reg                                blue;
  reg [7:0]                          col_cnt;

  // row
  reg                                aclk;
  reg                                arst;
  reg [5:0]                          row_cnt;

  reg [2:0]                          state;
  localparam       FIRSTCOL = 3'b000;
  localparam       CLOCK1 = 3'b001;
  localparam       CLOCK2 = 3'b010;
  localparam       LATCH = 3'b011;
  localparam       UNBLANK = 3'b100;
  localparam       PAUSE = 3'b101;
  localparam       NEXTROW = 3'b110;
  
  // Columns
  always @(posedge clk) begin
    if (reset == 1'b1) begin
      state   <= FIRSTCOL;
      red     <= 1'b0;
      green   <= 1'b0;
      blue    <= 1'b0;
      blank   <= 1'b1;
      latch   <= 1'b1;
      sclk    <= 1'b1;
      col_cnt <= 8'b0000000;
      row_cnt <= 6'b00000;
      arst    <= 1'b1;
      aclk    <= 1'b0;
    end else begin
      case(state)
        FIRSTCOL: begin
          state <= CLOCK1;
          // blank on, other off
          blank     <= 1'b1;
          latch     <= 1'b1;
          arst      <= 1'b0;
          aclk      <= 1'b0;
          col_cnt   <= 8'b00100000;
        end
        CLOCK1: begin
          // fixed at 32 horizontal pixels
          if (col_cnt == 0) begin
            state <= LATCH;
          end else begin
            state <= CLOCK2;
            // clock fall
            sclk <= 1'b0;
          end
          // lower half data on falling edge
          if (col_cnt < 32) begin
            red   <= 1'b0;
            green <= 1'b1;
            blue  <= 1'b0;
          end else begin
            red   <= 1'b0;
            green <= 1'b1;
            blue  <= 1'b1;
          end
        end
        CLOCK2: begin
          state   <= CLOCK1;
          col_cnt <= col_cnt - 1;
          // clock rise
          sclk    <= 1'b1;
          // upper half data on rising edge
          if (col_cnt < 32) begin
            red   <= 1'b1;
            green <= 1'b0;
            blue  <= 1'b0;
          end else begin
            red   <= 1'b0;
            green <= 1'b0;
            blue  <= 1'b1;
          end
        end
        LATCH: begin
          state             <= UNBLANK;
          // latch on
          latch                 <= 1'b0;
        end
        UNBLANK: begin
          state <= PAUSE;
          // blank off, latch off
          blank     <= 1'b0;
          latch     <= 1'b1;
          col_cnt <= 8'b0000000;
        end
        PAUSE: begin
          // reuse col_cnt counter for delay
          if (col_cnt == 8'b00000010) begin
            state <= NEXTROW;
          end else begin
            col_cnt <= col_cnt + 1;
          end
        end
        NEXTROW: begin
          state <= FIRSTCOL;
          if (row_cnt[0] == 1'b1 && row_cnt[1] == 1'b1) begin // && row_cnt[2] == rowmax_in[0] && row_cnt[3] == rowmax_in[1] && row_cnt[4] == rowmax_in[2] && row_cnt[5] == rowmax_in[3]) begin
            row_cnt <= 6'b000000;
            arst    <= 1'b1;
          end else begin
            row_cnt <= row_cnt + 1;
            aclk <= 1'b1;
          end
        end
      endcase
    end
  end
  
  assign red_out = red;
  assign blue_out = blue;
  assign blank_out = blank;
  assign green_out = green;
  assign arst_out = arst;
  assign aclk_out = aclk;
  assign sclk_out = sclk;
  assign latch_out = ~latch;
endmodule
