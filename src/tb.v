`default_nettype none
`timescale 1ns/1ps

/*
 this testbench just instantiates the module and makes some convenient wires
 that can be driven / tested by the cocotb test.py
 */

module tb (
           // testbench is controlled by test.py
	        input       clk,
            input       reset,
            input       uart_tx_dv,
            input [7:0] uart_tx_data,
            output      red,
            output      blue,
            output      blank,
            output      green,
            output      sclk,
            output      latch,
            output      a,
            output      b,
            output      uart_tx_done
           );

  // this part dumps the trace to a vcd file that can be viewed with GTKWave
  initial begin
    $dumpfile ("tb.vcd");
    $dumpvars (0, tb);
    $dumpvars (0, tb.top.frame_buffer[0]);
    $dumpvars (0, tb.top.frame_buffer[1]);
    $dumpvars (0, tb.top.frame_buffer[2]);
    $dumpvars (0, tb.top.frame_buffer[3]);
    $dumpvars (0, tb.top.frame_buffer[4]);
    $dumpvars (0, tb.top.frame_buffer[5]);
    $dumpvars (0, tb.top.frame_buffer[6]);
    $dumpvars (0, tb.top.frame_buffer[7]);
    #1;
  end

  // wire up the inputs and outputs
  wire uart_data;

  // instantiate the DUT
  led_panel_single top(.clk(clk),
                       .reset(reset),
                       .red_out(red),     
                       .blue_out(blue),    
                       .blank_out(blank),   
                       .green_out(green),  
                       .a_out(a),
                       .b_out(b),
                       .sclk_out(sclk),    
                       .latch_out(latch),
                       .uart_data(uart_data),
                       .mode(1'b0)
                       );

  // 6000/300 = 20
  uart_tx uart_tx(.i_Clock(clk),
                  .i_Tx_DV(uart_tx_dv),
                  .i_Tx_Byte(uart_tx_data),
                  .o_Tx_Serial(uart_data),
                  .o_Tx_Done(uart_tx_done));
endmodule
