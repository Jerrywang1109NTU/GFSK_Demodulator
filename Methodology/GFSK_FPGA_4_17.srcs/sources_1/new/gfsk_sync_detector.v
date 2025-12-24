// Frame Synchronization Detector Module
// clk_4 domain: sampling, differential calculation, correlation, peak detection
module gfsk_sync_detector(
    input                    clk_4,
    input                    rstn,
    
    // Input samples
    input      signed [15:0] GFSK_RX_I,
    input      signed [15:0] GFSK_RX_Q,
    
    // Shared RAM interface (write port)
    output reg               ram_wr_en,
    output reg [7:0]         ram_wr_addr,
    output reg signed [15:0] ram_wr_data_I,
    output reg signed [15:0] ram_wr_data_Q,
    
    // Shared RAM interface (read port for diff calculation)
    input      signed [15:0] ram_rd_data_I,
    input      signed [15:0] ram_rd_data_Q,
    output reg [7:0]         ram_rd_addr,
    
    // Coefficient ROM interface
    input      signed [63:0] cohe_coeff_I,
    input      signed [63:0] cohe_coeff_Q,
    output reg [4:0]         cohe_addr,
    
    // Outputs
    output reg               demo_valid,
    output reg [10:0]        frame_begin_4,
    output reg               peak_valid,
    output reg signed [63:0] GFSK_cohe_diff,
    output reg signed [63:0] GFSK_self_diff,
    output reg [8:0]         t_pointer_4,  // Expose for frequency estimator
    
    // Control
    input                    demo_valid_inhibit  // When 1, stop writing to RAM
);

    // Multiplication function (same as original)
    function [63:0] Mul;
        input signed [31:0] a, b;
        reg signed [31:0] abs_a, abs_b;
        begin
            abs_a = (a < 0) ? -a : a;
            abs_b = (b < 0) ? -b : b;
            Mul = abs_a * abs_b;
            Mul = Mul >> 10;
            if ((a < 0 && b >= 0) || (a >= 0 && b < 0)) begin
                Mul = -Mul; 
            end
        end
    endfunction
    
    // Internal registers
    reg [8:0]  t_pointer_4;
    reg [8:0]  i, j, k;
    reg signed [31:0] RAM_DIFF_I [0:255];
    reg signed [31:0] RAM_DIFF_Q [0:255];
    reg signed [63:0] GFSK_cohe_diff_I;
    reg signed [63:0] GFSK_cohe_diff_Q;
    reg signed [63:0] GFSK_cohe_diff_lst;
    
    integer idx;
    
    // Initialize RAM_DIFF arrays
    initial begin
        for (idx = 0; idx <= 255; idx = idx + 1) begin
            RAM_DIFF_I[idx] = 32'd0;
            RAM_DIFF_Q[idx] = 32'd0;
        end
    end
    
    // t_pointer_4 counter
    always @(negedge clk_4 or negedge rstn) begin
        if (!rstn)
            t_pointer_4 <= 9'd0;
        else 
            t_pointer_4 <= (t_pointer_4 + 1'b1) % 256;
    end
    
    // Write samples to shared RAM
    always @(negedge clk_4 or negedge rstn) begin
        if (!rstn) begin
            ram_wr_en <= 1'b0;
            ram_wr_addr <= 8'd0;
            ram_wr_data_I <= 16'd0;
            ram_wr_data_Q <= 16'd0;
        end
        else if (!demo_valid_inhibit) begin
            ram_wr_en <= 1'b1;
            ram_wr_addr <= t_pointer_4[7:0];
            ram_wr_data_I <= GFSK_RX_I;
            ram_wr_data_Q <= GFSK_RX_Q;
        end
        else begin
            ram_wr_en <= 1'b0;
        end
    end
    
    // Calculate RAM_DIFF_I (differential I)
    // Note: Uses current sample (GFSK_RX_I/Q) and delayed sample from RAM
    always @(negedge clk_4 or negedge rstn) begin
        if (!rstn) begin
            for (idx = 0; idx <= 255; idx = idx + 1)
                RAM_DIFF_I[idx] <= 32'd0;
        end
        else if (!demo_valid_inhibit) begin
            j = (t_pointer_4 + 254) % 256;
            ram_rd_addr <= j[7:0];
            // Current sample: GFSK_RX_I/Q (being written this cycle)
            // Delayed sample: ram_rd_data_I/Q (read from RAM, combinational)
            RAM_DIFF_I[t_pointer_4] <= Mul(GFSK_RX_I, ram_rd_data_I) + Mul(GFSK_RX_Q, ram_rd_data_Q);
        end
    end
    
    // Calculate RAM_DIFF_Q (differential Q)
    always @(negedge clk_4 or negedge rstn) begin
        if (!rstn) begin
            for (idx = 0; idx <= 255; idx = idx + 1)
                RAM_DIFF_Q[idx] <= 32'd0;
        end
        else if (!demo_valid_inhibit) begin
            j = (t_pointer_4 + 254) % 256;
            RAM_DIFF_Q[t_pointer_4] <= Mul(GFSK_RX_I, ram_rd_data_Q) - Mul(GFSK_RX_Q, ram_rd_data_I);
        end
    end
    
    // Frame synchronization: correlation and peak detection
    always @(negedge clk_4 or negedge rstn) begin
        if (!rstn) begin
            demo_valid <= 1'b0;
            frame_begin_4 <= 11'b0;
            peak_valid <= 1'b0;
            GFSK_self_diff <= 64'd0;
            GFSK_cohe_diff <= 64'd0;
            GFSK_cohe_diff_I <= 64'd0;
            GFSK_cohe_diff_Q <= 64'd0;
            GFSK_cohe_diff_lst <= 64'd0;
        end
        else if (demo_valid == 1'b0) begin
            GFSK_self_diff = 0;
            GFSK_cohe_diff_lst = GFSK_cohe_diff;
            GFSK_cohe_diff = 0;
            GFSK_cohe_diff_I = 0;
            GFSK_cohe_diff_Q = 0;
            for (i = 0; i <= 30; i = i + 1) begin
                j = (t_pointer_4 - i*4 + 256) % 256;
                k = 30 - i;
                cohe_addr <= k[4:0];
                GFSK_self_diff = GFSK_self_diff + Mul(RAM_DIFF_I[j], RAM_DIFF_I[j]) + Mul(RAM_DIFF_Q[j], RAM_DIFF_Q[j]);
                GFSK_cohe_diff_I = GFSK_cohe_diff_I + Mul(RAM_DIFF_I[j], cohe_coeff_I) - Mul(RAM_DIFF_Q[j], cohe_coeff_Q);
                GFSK_cohe_diff_Q = GFSK_cohe_diff_Q + Mul(RAM_DIFF_I[j], cohe_coeff_Q) + Mul(RAM_DIFF_Q[j], cohe_coeff_I);
            end
            GFSK_self_diff = (GFSK_self_diff << 2) + GFSK_self_diff;
            GFSK_cohe_diff = Mul(GFSK_cohe_diff_I, GFSK_cohe_diff_I) + Mul(GFSK_cohe_diff_Q, GFSK_cohe_diff_Q);
            if (GFSK_cohe_diff >= GFSK_self_diff && GFSK_cohe_diff >= 64'd10000 && demo_valid == 1'b0)
                peak_valid <= 1'b1;
            if (peak_valid == 1'b1 && GFSK_cohe_diff < GFSK_cohe_diff_lst && frame_begin_4 == 11'd0) begin
                frame_begin_4 <= t_pointer_4[10:0];
                peak_valid <= 1'b0;
                demo_valid <= 1'b1;
            end
        end
    end
    
    // Clear RAM_DIFF when demo_out_valid falls
    always @(negedge demo_valid or negedge rstn) begin
        if (!rstn) begin
            // Already cleared in initial
        end
        else begin
            for (idx = 0; idx <= 255; idx = idx + 1) begin
                RAM_DIFF_I[idx] <= 32'd0;
                RAM_DIFF_Q[idx] <= 32'd0;
            end
        end
    end

endmodule

