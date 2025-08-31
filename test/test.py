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

    # Reset the DUT
    dut.rst_n.value = 0
    dut.ui_in.value = 0
    await ClockCycles(dut.clk, 10)
    dut.rst_n.value = 1
    await ClockCycles(dut.clk, 1)

    # Write operation: MSB=1 (write), address=0x04
    dut.ui_in.value = 0b10000100  # write flag + address 0x04
    await ClockCycles(dut.clk, 2)  # wait longer to ensure write takes effect

    # Read operation: MSB=0 (read), address=0x04
    dut.ui_in.value = 0b00000100   # read flag + address 0x04
    await ClockCycles(dut.clk, 2)

    # Check the output matches lower 8 bits of 0xCAFEBABE (0xBE)
    expected = 0xBE
    actual = int(dut.uo_out.value)
    dut._log.info(f"Read uo_out={actual} expected={expected}")

    assert actual == expected, f"Cache read mismatch: got {actual}, expected {expected}"

    # Additional optional test: Read from address 0x08 (miss) returns 0xEF (from DEADBEEF)
    dut.ui_in.value = 0b00001000   # read flag + address 0x08
    await ClockCycles(dut.clk, 2)

    miss_expected = 0xEF
    miss_actual = int(dut.uo_out.value)
    dut._log.info(f"Miss read uo_out={miss_actual} expected={miss_expected}")

    assert miss_actual == miss_expected, f"Cache miss read mismatch: got {miss_actual}, expected {miss_expected}"
