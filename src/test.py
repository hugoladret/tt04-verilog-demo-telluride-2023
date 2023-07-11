import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, FallingEdge, Timer, ClockCycles

# Define some test positions for the pong ball and expected states for the paddle
ball_positions = [0, 10, 20, 30, 40, 50, 60]  # y-coordinates for the pong ball
expected_states = [0, 10, 20, 30, 40, 50, 60]  # Expected paddle states (assuming initial state is 0 and paddle follows the ball perfectly)
expected_spikes = [0, 1, 1, 1, 1, 1, 1]  # Neuron should spike when ball's y-coordinate exceeds paddle's y-coordinate

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

        # Check the neuron's state (paddle's y-coordinate)
        assert int(dut.uo_out[1:6].value) == expected_states[i]

        # Check if the neuron spikes when it should
        assert int(dut.uo_out[0].value) == expected_spikes[i]

        # All bidirectionals are set to output
        assert dut.uio_oe.value == 0xFF
