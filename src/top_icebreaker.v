module top
  #(parameter DIVIDER=6000, DELAY_BIT=15)
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
   input  P1A1,
   input  P1A2,
   input  P1A3
   );

  reg     clk_dut;
  wire    red; 
  wire    blue;
  wire    aclk;
  wire    blank;
  wire    green;
  wire    arst;
  wire    sclk;
  wire    latch;
  wire    rowmax;
  
  reg [15:0] clk_divide_counter;
  reg [15:0]   rst_delay_counter;
  wire         rst;
  wire         unused;
  reg          rst_delayed;

  // wire up the inputs and outputs
  assign rst = BTN_N;
  assign P2_1 = red;
  assign P2_2 = blue;
  assign P2_3 = aclk;
  assign P2_4 = blank;
  assign P2_7 = green;
  assign P2_8 = arst;
  assign P2_9 = sclk;
  assign P2_10 = latch;
  assign rowmax[0] = P1A1;
  assign rowmax[1] = P1A2;
  assign rowmax[2] = P1A3;
    
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
        rst_delay_counter <= rst_delay_counter + 1;
      end
    end
  end

  // instantiate the component
  led_panel_single top(.clk(CLK),
                       .reset(rst_delayed), 
                       .red_out(red),     
                       .blue_out(blue),    
                       .aclk_out(aclk),    
                       .blank_out(blank),   
                       .green_out(green),  
                       .arst_out(arst),    
                       .sclk_out(sclk),    
                       .latch_out(latch),  
                       .rowmax_in(rowmax)
                       );              

endmodule
