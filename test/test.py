# SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0
import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles

@cocotb.test()
async def test_cache(dut):
    dut._log.info("Start cache test")
    clock = Clock(dut.clk, 10, units="us")  # 100 KHz clock
    cocotb.start_soon(clock.start())

    # Reset sequence
    dut.rst_n.value = 0
    dut.ui_in.value = 0
    # Remove this if uio_in port is not in design, else keep and set 0
    # dut.uio_in.value = 0  
    await ClockCycles(dut.clk, 10)
    dut.rst_n.value = 1
    await ClockCycles(dut.clk, 1)

    # Write operation - MSB=1 (write), address=0x04
    dut.ui_in.value = 0b10000100  
    await ClockCycles(dut.clk, 1)

    # Read operation - MSB=0 (read), address=0x04
    dut.ui_in.value = 0b00000100
    await ClockCycles(dut.clk, 1)

    # Check result is lower 8 bits of fixed write data 0xCAFEBABE, i.e. 0xBE
    expected = 0xBE
    dut._log.info(f"uo_out={int(dut.uo_out.value)} expected={expected}")
    assert dut.uo_out.value == expected, f"Cache read mismatch: got {int(dut.uo_out.value)}, expected {expected}"
