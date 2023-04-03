import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, FallingEdge, Timer, ClockCycles

@cocotb.test()
async def top(dut):
    dut._log.info("start")
    clock = Clock(dut.clk, 10, units="us")
    cocotb.start_soon(clock.start())
    
    dut._log.info("reset")
    dut.reset.value = 1
    dut.uart_tx_dv.value = 0
    await ClockCycles(dut.clk, 10)
    dut.reset.value = 0

    await ClockCycles(dut.clk, 10)
    dut.uart_tx_data.value = 0x55
    dut.uart_tx_dv.value = 1
    await ClockCycles(dut.clk, 1)
    dut.uart_tx_dv.value = 0
    await FallingEdge(dut.uart_tx_done)
    dut.uart_tx_dv.value = 1
    await ClockCycles(dut.clk, 1)
    dut.uart_tx_dv.value = 0
    await FallingEdge(dut.uart_tx_done)
    dut.uart_tx_dv.value = 1
    await ClockCycles(dut.clk, 1)
    dut.uart_tx_dv.value = 0
    await FallingEdge(dut.uart_tx_done)
    

    await ClockCycles(dut.clk, 10000)
