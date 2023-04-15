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

    await ClockCycles(dut.clk, 500)

    # reset
    dut.uart_tx_data.value = 0xFF
    dut.uart_tx_dv.value = 1
    await ClockCycles(dut.clk, 1)
    dut.uart_tx_dv.value = 0
    await FallingEdge(dut.uart_tx_done)
    dut.uart_tx_dv.value = 1
    await ClockCycles(dut.clk, 1)
    dut.uart_tx_dv.value = 0
    await FallingEdge(dut.uart_tx_done)
    # white
    dut.uart_tx_data.value = 0x07
    dut.uart_tx_dv.value = 1
    await ClockCycles(dut.clk, 1)
    dut.uart_tx_dv.value = 0
    await FallingEdge(dut.uart_tx_done)
    # clear display
    dut.uart_tx_data.value = 0x30
    dut.uart_tx_dv.value = 1
    await ClockCycles(dut.clk, 1)
    dut.uart_tx_dv.value = 0
    await FallingEdge(dut.uart_tx_done)
    # bottom left corner (set)
    dut.uart_tx_data.value = 0x10
    dut.uart_tx_dv.value = 1
    await ClockCycles(dut.clk, 1)
    dut.uart_tx_dv.value = 0
    await FallingEdge(dut.uart_tx_done)
    dut.uart_tx_data.value = 0xf7
    dut.uart_tx_dv.value = 1
    await ClockCycles(dut.clk, 1)
    dut.uart_tx_dv.value = 0
    await ClockCycles(dut.clk, 500)


    # bottom left corner (clear)
    dut.uart_tx_data.value = 0x20
    dut.uart_tx_dv.value = 1
    await ClockCycles(dut.clk, 1)
    dut.uart_tx_dv.value = 0
    await FallingEdge(dut.uart_tx_done)
    dut.uart_tx_data.value = 0xf7
    dut.uart_tx_dv.value = 1
    await ClockCycles(dut.clk, 1)
    dut.uart_tx_dv.value = 0
    await FallingEdge(dut.uart_tx_done)
    

    await ClockCycles(dut.clk, 10000)
