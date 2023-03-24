`default_nettype none
`timescale 1ns/1ps

/*
 this testbench just instantiates the module and makes some convenient wires
 that can be driven / tested by the cocotb test.py
 */

module tb (
           // testbench is controlled by test.py
	        input  clk,
            input  reset,
            output red,
            output blue,
            output aclk,
            output blank,
            output green,
            output arst,
            output sclk,
            output latch
           );

  // this part dumps the trace to a vcd file that can be viewed with GTKWave
  initial begin
    $dumpfile ("tb.vcd");
    $dumpvars (0, tb);
    #1;
  end

  // wire up the inputs and outputs
  wire uart_tx_pin;

  wire [3:0] lcd_data;
  wire       lcd_en;
  wire       lcd_rs;

  // instantiate the DUT
  led_panel_single top(.clk(clk),
                       .reset(reset), 
                       .red_out(red),     
                       .blue_out(blue),    
                       .aclk_out(aclk),    
                       .blank_out(blank),   
                       .green_out(green),  
                       .arst_out(arst),    
                       .sclk_out(sclk),    
                       .latch_out(latch),  
                       .rowmax_in(3'b000)
                       );              
endmodule
