module hugoladret_tt_um_dishbrain (
    // These are the inputs and outputs to/from the module.
    // It's still better than the actual thing lol 
    input  wire [7:0] ui_in,    // Dedicated inputs - connected to the input switches
    output wire [7:0] uo_out,   // Dedicated outputs - connected to the 7 segment display
    input  wire [7:0] uio_in,   // IOs: Bidirectional Input path
    output wire [7:0] uio_out,  // IOs: Bidirectional Output path
    output wire [7:0] uio_oe,   // IOs: Bidirectional Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // will go high when the design is enabled
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

    // Assign the lower 6 bits of the input ui_in to the in_current wire, this represents the pong ball's y-coordinate
    assign in_current = ui_in[5:0];

    // The spike output (uo_out[0]) indicates when the neuron fires a spike.
    assign uo_out[0] = spike;

    // The state of the neuron (uo_out[1:6]) represents the y-coordinate of the paddle
    assign uo_out[1:6] = state;

    reg  [5:0] threshold; // Threshold value which decides when the neuron should spike
    wire [5:0] state_hist; // The history of the neuron's state
    wire reset = ! rst_n;  // Reset signal. When high, the neuron's state, threshold and spike status will be reset

    // Calculate the new state of the neuron based on the current input and state
    assign state_hist = in_current + (spike ? 0 : (state >> 1)); // scale by 1/2

    // This always block describes what happens on each clock cycle
    always @(posedge clk) begin
        // If reset signal is received, reset the neuron's state, threshold and spike status to initial values
        if (reset) begin
            threshold <= 32; // Initial threshold value, half of the 6 bits range defined here
            state <= 0; // Initial state
            spike <= 0; // Initial spike status
        end else begin
            // The threshold is now set to the y-coordinate of the ball
            threshold <= in_current;

            // Update the neuron's state to the newly calculated state
            state <= state_hist;

            // If the neuron's state exceeds the threshold (paddle's y-coordinate is below the ball's y-coordinate), it will fire a spike
            spike <= (state >= threshold);

            // If the neuron does not fire a spike (paddle's y-coordinate is above the ball's y-coordinate) and the state is above 0, decrement the state by 1 to move the paddle downwards
            if (!spike && state > 0) state <= state - 1;
        end
    end
endmodule
