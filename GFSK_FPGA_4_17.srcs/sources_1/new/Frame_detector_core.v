// Frame Detector Core Module (Top-level integration)
// Instantiates and connects all submodules
module Frame_detector_core(
    input                    clk,
    input                    rstn,
    input      signed [15:0] GFSK_RX_I,
    input      signed [15:0] GFSK_RX_Q,
    output reg signed [63:0] GFSK_cohe_diff,
    output reg signed [63:0] GFSK_self_diff,
    output reg               demo_data,
    output reg               demo_out_valid,
    output reg [10:0]        num_demo,
    output reg [5:0]         cnt_demo
);

    // Clock dividers
    wire clk_1;
    wire clk_4;
    
    frequency_4 u_freq_4(
    .clk(clk),
	.rstn(rstn),
	.clk_4(clk_4)
);

    frequency_1 u_freq_1(
    .clk(clk),
	.rstn(rstn),
	.clk_1(clk_1)
);

    // Coefficient ROM
    wire signed [15:0] sin_val, cos_val;
    wire signed [63:0] cohe_coeff_I, cohe_coeff_Q;
    wire signed [15:0] head_coeff_I, head_coeff_Q;
    wire [31:0] l0_coeff;
    wire [16:0] crc_std;
    
    wire [11:0] sin_cos_addr;
    wire [4:0]  cohe_addr;
    wire [3:0]  head_addr;
    wire [2:0]  l0_addr;
    
    gfsk_coefficient_rom u_coeff_rom(
        .sin_val(sin_val),
        .cos_val(cos_val),
        .sin_cos_addr(sin_cos_addr),
        .cohe_coeff_I(cohe_coeff_I),
        .cohe_coeff_Q(cohe_coeff_Q),
        .cohe_addr(cohe_addr),
        .head_coeff_I(head_coeff_I),
        .head_coeff_Q(head_coeff_Q),
        .head_addr(head_addr),
        .l0_coeff(l0_coeff),
        .l0_addr(l0_addr),
        .crc_std(crc_std)
    );
    
    // Shared RAM for GFSK_I/Q samples
    wire ram_wr_en;
    wire [7:0] ram_wr_addr;
    wire signed [15:0] ram_wr_data_I, ram_wr_data_Q;
    wire [7:0] ram_rd_addr_1, ram_rd_addr_2;
    wire signed [15:0] ram_rd_data_I_1, ram_rd_data_Q_1;
    wire signed [15:0] ram_rd_data_I_2, ram_rd_data_Q_2;
    wire clear_all;
    
    gfsk_shared_ram u_shared_ram(
        .clk_4(clk_4),
        .rstn(rstn),
        .wr_en(ram_wr_en),
        .wr_addr(ram_wr_addr),
        .wr_data_I(ram_wr_data_I),
        .wr_data_Q(ram_wr_data_Q),
        .rd_addr_1(ram_rd_addr_1),
        .rd_data_I_1(ram_rd_data_I_1),
        .rd_data_Q_1(ram_rd_data_Q_1),
        .rd_addr_2(ram_rd_addr_2),
        .rd_data_I_2(ram_rd_data_I_2),
        .rd_data_Q_2(ram_rd_data_Q_2),
        .clear_all(clear_all)
    );
    
    // Sync Detector Module
    wire demo_valid;
    wire [10:0] frame_begin_4;
    wire peak_valid;
    wire signed [63:0] GFSK_cohe_diff_sync;
    wire signed [63:0] GFSK_self_diff_sync;
    wire [8:0] t_pointer_4;
    
    gfsk_sync_detector u_sync_detector(
        .clk_4(clk_4),
        .rstn(rstn),
        .GFSK_RX_I(GFSK_RX_I),
        .GFSK_RX_Q(GFSK_RX_Q),
        .ram_wr_en(ram_wr_en),
        .ram_wr_addr(ram_wr_addr),
        .ram_wr_data_I(ram_wr_data_I),
        .ram_wr_data_Q(ram_wr_data_Q),
        .ram_rd_data_I(ram_rd_data_I_1),
        .ram_rd_data_Q(ram_rd_data_Q_1),
        .ram_rd_addr(ram_rd_addr_1),
        .cohe_coeff_I(cohe_coeff_I),
        .cohe_coeff_Q(cohe_coeff_Q),
        .cohe_addr(cohe_addr),
        .demo_valid(demo_valid),
        .frame_begin_4(frame_begin_4),
        .peak_valid(peak_valid),
        .GFSK_cohe_diff(GFSK_cohe_diff_sync),
        .GFSK_self_diff(GFSK_self_diff_sync),
        .t_pointer_4(t_pointer_4),
        .demo_valid_inhibit(demo_valid)
    );
    
    // Frequency Estimator Module
    wire signed [32:0] v_est;
    wire signed [15:0] v_est_num;
    wire [11:0] v_estimation_total;
    
    gfsk_freq_estimator u_freq_estimator(
        .clk(clk),
        .rstn(rstn),
        .peak_valid(peak_valid),
        .ram_rd_data_I(ram_rd_data_I_2),
        .ram_rd_data_Q(ram_rd_data_Q_2),
        .ram_rd_addr(ram_rd_addr_2),
        .head_coeff_I(head_coeff_I),
        .head_coeff_Q(head_coeff_Q),
        .head_addr(head_addr),
        .l0_coeff(l0_coeff),
        .l0_addr(l0_addr),
        .t_pointer_4(t_pointer_4),
        .v_est(v_est),
        .v_est_num(v_est_num),
        .v_estimation_total(v_estimation_total),
        .demo_valid(demo_valid),
        .demo_out_valid(demo_out_valid)
    );
    
    // Demodulator Module
    wire CRC_check;
    
    gfsk_demodulator u_demodulator(
        .clk(clk),
        .rstn(rstn),
        .clk_1(clk_1),
        .GFSK_RX_I(GFSK_RX_I),
        .GFSK_RX_Q(GFSK_RX_Q),
        .v_estimation_total(v_estimation_total),
        .sin_val(sin_val),
        .cos_val(cos_val),
        .sin_cos_addr(sin_cos_addr),
        .crc_std(crc_std),
        .demo_valid(demo_valid),
        .demo_data(demo_data),
        .demo_out_valid(demo_out_valid),
        .num_demo(num_demo),
        .cnt_demo(cnt_demo),
        .CRC_check(CRC_check),
        .clear_all(clear_all)
    );
    
    // Output assignments
    always @* begin
        GFSK_cohe_diff = GFSK_cohe_diff_sync;
        GFSK_self_diff = GFSK_self_diff_sync;
end

endmodule
