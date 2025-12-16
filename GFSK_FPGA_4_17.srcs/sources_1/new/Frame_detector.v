module Frame_detector(
    input                    clk,
    input                    rstn,
    input      signed [15:0] GFSK_RX_I,
    input      signed [15:0] GFSK_RX_Q,
    output     signed [63:0] GFSK_cohe_diff,
    output     signed [63:0] GFSK_self_diff,
    output                  demo_data,
    output                  demo_out_valid,
    output     [10:0]       num_demo,
    output     [5:0]        cnt_demo
);

    // Wrapper top-level: instantiate core logic module.
    Frame_detector_core u_core (
        .clk           (clk),
        .rstn          (rstn),
        .GFSK_RX_I     (GFSK_RX_I),
        .GFSK_RX_Q     (GFSK_RX_Q),
        .GFSK_cohe_diff(GFSK_cohe_diff),
        .GFSK_self_diff(GFSK_self_diff),
        .demo_data     (demo_data),
        .demo_out_valid(demo_out_valid),
        .num_demo      (num_demo),
        .cnt_demo      (cnt_demo)
    );

endmodule
