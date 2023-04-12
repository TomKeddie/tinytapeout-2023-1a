// BA=00 | 23 22 21 20 19 18 17 16 07 06 05 04 03 02 01 00
// BA=01 | 23 22 21 20 19 18 17 16 07 06 05 04 03 02 01 00
// BA=10 | 23 22 21 20 19 18 17 16 07 06 05 04 03 02 01 00
// BA=11 | 23 22 21 20 19 18 17 16 07 06 05 04 03 02 01 00
// BA=00 | 31 30 29 28 27 26 25 24 15 14 13 12 11 10 09 08
// BA=01 | 31 30 29 28 27 26 25 24 15 14 13 12 11 10 09 08
// BA=10 | 31 30 29 28 27 26 25 24 15 14 13 12 11 10 09 08
// BA=11 | 31 30 29 28 27 26 25 24 15 14 13 12 11 10 09 08
//
// BA=00 | 23 22 21 20 19 18 17 16 07 06 05 04 03 02 01 00
// BA=01 | 23 22 21 20 19 18 17 16 07 06 05 04 03 02 01 00
// BA=10 | 23 22 21 20 19 18 17 16 07 06 05 04 03 02 01 00
// BA=11 | 23 22 21 20 19 18 17 16 07 06 05 04 03 02 01 00
// BA=00 | 31 30 29 28 27 26 25 24 15 14 13 12 11 10 09 08
// BA=01 | 31 30 29 28 27 26 25 24 15 14 13 12 11 10 09 08
// BA=10 | 31 30 29 28 27 26 25 24 15 14 13 12 11 10 09 08
// BA=11 | 31 30 29 28 27 26 25 24 15 14 13 12 11 10 09 08

module led_panel_single (
                         input        clk,
                         input        reset,
                         input        uart_data,
                         output       red_out,
                         output       blue_out,
                         output       aclk_out,
                         output       blank_out,
                         output       green_out,
                         output       arst_out,
                         output       sclk_out,
                         output       latch_out,
                         output [7:0] uart_rx_data_out,
                         output       uart_rx_dv_out
                         );

  // column
  reg                                 sclk;
  reg                                 blank;
  reg                                 latch;
  reg                                 red;
  reg                                 green;
  reg                                 blue;
  reg [5:0]                           col_cnt;

  // row
  reg                                 aclk;
  reg                                 arst;
  reg [1:0]                           row_cnt;

  reg [2:0]                           led_data_state;
  localparam       LDS_FIRSTCOL = 3'b000;
  localparam       LDS_DATA1 =    3'b001;
  localparam       LDS_DATA2 =    3'b010;
  localparam       LDS_LATCH =    3'b011;
  localparam       LDS_UNBLANK =  3'b100;
  localparam       LDS_PAUSE =    3'b101;
  localparam       LDS_NEXTROW =  3'b110;

  localparam       CLKS_PER_BIT = 20;

  reg [7:0]                           frame_buffer [15:0];
  wire [3:0]                          frame_column;
  wire [3:0]                          frame_row;

  reg [2:0]                           rgb;

  wire                                uart_rx_dv;
  wire [7:0]                          uart_rx_data;

  reg [2:0]                           uart_data_state;
  localparam      UDS_CTRL   = 3'b000;
  localparam      UDS_DATA1  = 3'b001;
  localparam      UDS_DATA2  = 3'b010;


  // Clock
  always @(negedge clk) begin
    if (reset == 1'b1) begin
      sclk                 <= 1'b1;
    end else begin
      case(led_data_state)
        LDS_DATA1: begin
          // clock rise
          sclk <= 1'b1;
        end
        LDS_DATA2: begin
          if (col_cnt[5] != 1'b1) begin
            // clock fall
            sclk    <= 1'b0;
          end
        end
      endcase
    end
  end

  // Data
  always @(posedge clk) begin
    if (reset == 1'b1) begin
      led_data_state                <= LDS_FIRSTCOL;
      red                  <= 1'b0;
      green                <= 1'b0;
      blue                 <= 1'b0;
      blank                <= 1'b1;
      latch                <= 1'b1;
      col_cnt              <= 6'b000000;
      row_cnt              <= 2'b00;
      arst                 <= 1'b1;
      aclk                 <= 1'b0;
    end else begin
      case(led_data_state)
        LDS_FIRSTCOL: begin
          led_data_state   <= LDS_DATA1;
          // blank still on, other off
          latch   <= 1'b1;
          arst    <= 1'b0;
          aclk    <= 1'b0;
          col_cnt <= 6'b011111;
        end
        LDS_DATA1: begin
          if (col_cnt[5] == 1'b1) begin
            led_data_state <= LDS_LATCH;
          end else begin
            led_data_state <= LDS_DATA2;
          end
          // black
          red   <= 1'b0;
          green <= 1'b0;
          blue  <= 1'b0;
        end
        LDS_DATA2: begin
          led_data_state <= LDS_DATA1;
          col_cnt <= col_cnt - 1;
          // default to black
          red   <= 1'b0;
          green <= 1'b0;
          blue  <= 1'b0;
          // upper half data on rising edge
          if (col_cnt < 8) begin
            // upper half: upper right quadrant BLACK
            if (frame_buffer[{1'b0, col_cnt[2:0]}][{1'b0, row_cnt}] == 1'b1) begin
              red   <= rgb[2];
              green <= rgb[1];
              blue  <= rgb[0];
            end
          end else if (col_cnt < 16) begin
            // upper half: lower right quadrant
            if (frame_buffer[{1'b0, col_cnt[2:0]}][{1'b1, row_cnt}] == 1'b1) begin
              red   <= rgb[2];
              green <= rgb[1];
              blue  <= rgb[0];
            end
          end else if (col_cnt < 24) begin
            // upper half: upper left quadrant BLACK
            if (frame_buffer[{1'b1, col_cnt[2:0]}][{1'b0, row_cnt}] == 1'b1) begin
              red   <= rgb[2];
              green <= rgb[1];
              blue  <= rgb[0];
            end
          end else begin
            // upper half: lower left quadrant
            if (frame_buffer[{1'b1, col_cnt[2:0]}][{1'b1, row_cnt}] == 1'b1) begin
              red   <= rgb[2];
              green <= rgb[1];
              blue  <= rgb[0];
            end
          end
        end
        LDS_LATCH: begin
          led_data_state             <= LDS_UNBLANK;
          // latch on
          latch                 <= 1'b0;
          // blank here is brighter but much more flicker
          // blank     <= 1'b1;
        end
        LDS_UNBLANK: begin
          led_data_state <= LDS_PAUSE;
          // blank off, latch off
          blank     <= 1'b0;
          latch     <= 1'b1;
          col_cnt <= 6'b00000;
        end
       LDS_PAUSE: begin
          // reuse col_cnt counter for delay
          if (col_cnt == 6'b000010) begin
            led_data_state <= LDS_NEXTROW;
          end else begin
            col_cnt <= col_cnt + 1;
          end
        end
       LDS_NEXTROW: begin
          // blank on
          blank   <= 1'b1;
          led_data_state <= LDS_FIRSTCOL;
          if (row_cnt == 2'b11) begin
            row_cnt <= 2'b00;
            arst    <= 1'b1;
          end else begin
            row_cnt <= row_cnt + 1;
            aclk <= 1'b1;
          end
        end
      endcase
    end
  end

  // frame buffer writes
  always @(posedge clk) begin
    if (reset == 1'b1) begin
      uart_data_state <= UDS_CTRL;

      rgb                  <= 3'b101;

      frame_buffer[0]     <= 3'b0;
      frame_buffer[1]     <= 3'b0;
      frame_buffer[2]     <= 3'b0;
      frame_buffer[3]     <= 3'b0;
      frame_buffer[4]     <= 3'b0;
      frame_buffer[5]     <= 3'b0;
      frame_buffer[6]     <= 3'b0;
      frame_buffer[7]     <= 3'b0;
      frame_buffer[8]     <= 3'b0;
      frame_buffer[9]     <= 3'b0;
      frame_buffer[10]    <= 3'b0;
      frame_buffer[11]    <= 3'b0;
      frame_buffer[12]    <= 3'b0;
      frame_buffer[13]    <= 3'b0;
      frame_buffer[14]    <= 3'b0;
      frame_buffer[15]    <= 3'b0;

      // T
      frame_buffer[15][1] <= 1'b1;
      frame_buffer[14][1] <= 1'b1;
      frame_buffer[13][1] <= 1'b1;
      frame_buffer[14][2] <= 1'b1;
      frame_buffer[14][3] <= 1'b1;
      frame_buffer[14][4] <= 1'b1;
      frame_buffer[14][5] <= 1'b1;
      // T
      frame_buffer[11][1] <= 1'b1;
      frame_buffer[10][1] <= 1'b1;
      frame_buffer[09][1] <= 1'b1;
      frame_buffer[10][2] <= 1'b1;
      frame_buffer[10][3] <= 1'b1;
      frame_buffer[10][4] <= 1'b1;
      frame_buffer[10][5] <= 1'b1;
      // 0
      frame_buffer[6][1]  <= 1'b1;
      frame_buffer[5][2]  <= 1'b1;
      frame_buffer[7][2]  <= 1'b1;
      frame_buffer[5][3]  <= 1'b1;
      frame_buffer[7][3]  <= 1'b1;
      frame_buffer[5][4]  <= 1'b1;
      frame_buffer[7][4]  <= 1'b1;
      frame_buffer[6][5]  <= 1'b1;
      // 3
      frame_buffer[3][1]  <= 1'b1;
      frame_buffer[2][1]  <= 1'b1;
      frame_buffer[1][2]  <= 1'b1;
      frame_buffer[3][3]  <= 1'b1;
      frame_buffer[2][3]  <= 1'b1;
      frame_buffer[1][4]  <= 1'b1;
      frame_buffer[3][5]  <= 1'b1;
      frame_buffer[2][5]  <= 1'b1;
      end else begin // if (reset == 1'b1)
        case(uart_data_state)
          UDS_CTRL: begin
            if (uart_rx_dv == 1'b1) begin
              case(uart_rx_data[7:4])
                4'hf: begin
                  // reset
                  uart_data_state                  <= UDS_CTRL;
                end
                4'h0: begin
                  // 0x set rgb colour
                  rgb                          <= uart_rx_data[2:0];
                end
                4'h1: begin
                  // 1x set pixel
                  uart_data_state <= UDS_DATA1;
                end
                4'h2: begin
                  // 2x clear pixel
                  uart_data_state <= UDS_DATA1;
                end
                4'h3: begin
                  // 3x clear screen
                  frame_buffer[0]     <= 3'b0;
                  frame_buffer[1]     <= 3'b0;
                  frame_buffer[2]     <= 3'b0;
                  frame_buffer[3]     <= 3'b0;
                  frame_buffer[4]     <= 3'b0;
                  frame_buffer[5]     <= 3'b0;
                  frame_buffer[6]     <= 3'b0;
                  frame_buffer[7]     <= 3'b0;
                  frame_buffer[8]     <= 3'b0;
                  frame_buffer[9]     <= 3'b0;
                  frame_buffer[10]    <= 3'b0;
                  frame_buffer[11]    <= 3'b0;
                  frame_buffer[12]    <= 3'b0;
                  frame_buffer[13]    <= 3'b0;
                  frame_buffer[14]    <= 3'b0;
                  frame_buffer[15]    <= 3'b0;
                end
              endcase
            end
          end
          UDS_DATA1:  begin
            if (uart_rx_dv == 1'b1) begin
              if (uart_rx_data == 8'hf5) begin
                // reset
                uart_data_state <= UDS_CTRL;
              end
            end
          end
          UDS_DATA2:  begin
            if (uart_rx_dv == 1'b1) begin
              if (uart_rx_data == 8'hf5) begin
                // reset
                uart_data_state <= UDS_CTRL;
              end
            end
          end
        endcase
    end
  end

  uart_rx uart_rx(.i_Clock(clk),
                  .i_Rx_Serial(uart_data),
                  .o_Rx_DV(uart_rx_dv),
                  .o_Rx_Byte(uart_rx_data));
  
  assign red_out = red;
  assign blue_out = blue;
  assign blank_out = blank;
  assign green_out = green;
  assign arst_out = arst;
  assign aclk_out = aclk;
  assign sclk_out = sclk;
  assign latch_out = ~latch;
  assign uart_rx_data_out = uart_rx_data;
  assign uart_rx_dv_out = uart_rx_dv;
endmodule
