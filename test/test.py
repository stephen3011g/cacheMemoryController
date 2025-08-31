import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles

@cocotb.test()
async def test_cache(dut):
    clock = Clock(dut.clk, 10, units="us")  # 100 kHz clock
    cocotb.start_soon(clock.start())

    dut.rst_n.value = 0
    dut.ena.value = 0
    dut.ui_in.value = 0
    await ClockCycles(dut.clk, 10)
    dut.rst_n.value = 1
    dut.ena.value = 1
    await ClockCycles(dut.clk, 1)

    # Write to address 0x04 (ui_in[7]=1 for write)
    dut.ui_in.value = 0b10000100
    await ClockCycles(dut.clk, 10)

    # Read from address 0x04 (ui_in[7]=0 for read)
    dut.ui_in.value = 0b00000100
    await ClockCycles(dut.clk, 10)

    expected = 0xBE  # lower 8 bits of 0xCAFEBABE
    actual = int(dut.uo_out.value)
    assert actual == expected, f"Cache read mismatch: got {actual}, expected {expected}"

    # Read from address 0x08 (miss)
    dut.ui_in.value = 0b00001000
    await ClockCycles(dut.clk, 10)

    miss_expected = 0xEF  # lower 8 bits of 0xDEADBEEF
    miss_actual = int(dut.uo_out.value)
    assert miss_actual == miss_expected, f"Cache miss read mismatch: got {miss_actual}, expected {miss_expected}"
