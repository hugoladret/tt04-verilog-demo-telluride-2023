module tt_um_dishbrain_hugoladret (
    input  wire [7:0] ui_in,
    output reg [7:0] uo_out,   // Updated to 'reg' to allow direct assignments
    input  wire [7:0] uio_in,
    output wire [7:0] uio_out,
    output wire [7:0] uio_oe,
    input  wire       ena,
    input  wire       clk,
    input  wire       rst_n
);

    assign in_current = ui_in[5:0];

    reg  [5:0] threshold; 
    wire [5:0] state_hist;
    wire reset = ! rst_n;
    reg  [5:0] state;  // State declaration was missing, added here.
    reg  spike;  // Spike declaration was missing, added here.

    assign state_hist = in_current + (spike ? 0 : (state >> 1));

    always @(posedge clk) begin
        if (reset) begin
            threshold <= 32;
            state <= 0;
            spike <= 0;
            uo_out <= 8'b0; // Initialized uo_out
        end else begin
            threshold <= in_current;
            state <= state_hist;
            spike <= (state >= threshold);

            if (!spike && state > 0) state <= state - 1;

            // Assignments to uo_out bits. It's required since uo_out is now declared as a register
            uo_out[0] <= spike;
            uo_out[6:1] <= state;
            uo_out[7] <= 0;  // Assuming the highest bit is unused
        end
    end
endmodule
