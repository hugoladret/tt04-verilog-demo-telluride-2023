import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, FallingEdge, Timer, ClockCycles

ball_positions = [0, 10, 20, 30, 40, 50, 60]  
expected_states = [0, 10, 20, 30, 40, 50, 60]  
expected_spikes = [0, 1, 1, 1, 1, 1, 1]  

@cocotb.test()
async def test_neuron(dut):
    dut._log.info("start")
    clock = Clock(dut.clk, 10, units="us")
    cocotb.start_soon(clock.start())

    dut._log.info("reset")
    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 10)
    dut.rst_n.value = 1

    dut._log.info("check neuron state for different ball positions")
    for i in range(len(ball_positions)):
        dut._log.info("set ball position to {}".format(ball_positions[i]))
        print("set ball position to {}".format(ball_positions[i]))
        dut.ui_in.value = ball_positions[i]
        await ClockCycles(dut.clk, 10)

        # Convert the dut.uo_out.value to an integer and apply bit masking
        uo_out_value = int(dut.uo_out.value)
        uo_out_bits_1_to_6 = (uo_out_value >> 1) & 0x3F
        spike_bit = uo_out_value & 1  # Extract the spike bit

        assert uo_out_bits_1_to_6 == expected_states[i]
        assert spike_bit == expected_spikes[i]

        assert dut.uio_oe.value == 0xFF
