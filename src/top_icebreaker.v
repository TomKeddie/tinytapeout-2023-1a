module top
  #(parameter DIVIDER=1000, DELAY_BIT=15)
  (
   input  CLK,
   input  BTN_N,
   output P2_1,
   output P2_2,
   output P2_3,
   output P2_4,
   output P2_7,
   output P2_8,
   output P2_9,
   output P2_10,
   input P1A1,
   output P1A2,
   output P1A3,
   output P1A4,
   output P1A7,
   output P1A8,
   output P1A9,
   output P1A10,
   input  P1B1,
   output P1B2,
   output P1B3,
   output P1B4,
   output P1B7,
   output P1B8,
   output P1B9,
   output P1B10
   );

  reg     clk_dut;
  wire    red;
  wire    blue;
  wire    blank;
  wire    green;
  wire    sclk;
  wire    latch;
  wire    a;
  wire    b;

  reg [15:0] clk_divide_counter;
  reg [15:0]   rst_delay_counter;
  wire         rst;
  wire         unused;
  reg          rst_delayed;

  wire         uart_data;
  wire [7:0]   uart_rx_data;
  wire         uart_rx_dv;

  wire         mode;

  // wire up the inputs and outputs
  assign rst = ~BTN_N;
  assign P2_1 = red;
  assign P2_2 = blue;
  assign P2_3 = b;
  assign P2_4 = blank;
  assign P2_7 = green;
  assign P2_8 = a;
  assign P2_9 = sclk;
  assign P2_10 = latch;
  assign uart_data = P1B1;
  assign mode = P1A1;

  // clock divider
  always @(posedge CLK) begin
    begin
      if (rst == 1'b1) begin
		clk_dut <= 1'b0;
		clk_divide_counter <= 0;
	  end else if (clk_divide_counter == DIVIDER) begin
        clk_dut     <= !clk_dut;
		clk_divide_counter <= 0;
      end else begin
        clk_divide_counter <= clk_divide_counter + 1;
      end
    end
  end

  // reset delay
  always @(posedge CLK) begin
    begin
      if (rst == 1'b1) begin
		rst_delayed <= 1'b1;
		rst_delay_counter <= 0;
	  end else if (rst_delay_counter[DELAY_BIT] == 1'b1) begin
		rst_delayed <= 1'b0;
      end else begin
		rst_delayed <= 1'b1;
        rst_delay_counter <= rst_delay_counter + 1;
      end
    end
  end

  // instantiate the component
  led_panel_single top(.clk(clk_dut),
                       .reset(rst_delayed),
                       .uart_data(uart_data),
                       .mode(mode),
                       .red_out(red),
                       .blue_out(blue),
                       .blank_out(blank),
                       .green_out(green),
                       .sclk_out(sclk),
                       .latch_out(latch),
                       .a_out(a),
                       .b_out(b),
                       .uart_rx_data_out(uart_rx_data),
                       .uart_rx_dv_out(uart_rx_dv)
                       );

endmodule
