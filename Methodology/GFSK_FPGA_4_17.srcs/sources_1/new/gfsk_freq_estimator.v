// Frequency Offset Estimator Module
// Triggered by peak_valid, uses CORDIC for phase estimation
module gfsk_freq_estimator(
    input                    clk,
    input                    rstn,
    
    // Trigger signal (from sync detector, clk_4 domain)
    input                    peak_valid,
    
    // Shared RAM interface (read port, combinational)
    // Note: Addresses are computed internally based on t_pointer_4
    input      signed [15:0] ram_rd_data_I,
    input      signed [15:0] ram_rd_data_Q,
    output reg [7:0]         ram_rd_addr,
    
    // Coefficient ROM interface (combinational)
    input      signed [15:0] head_coeff_I,
    input      signed [15:0] head_coeff_Q,
    output reg [3:0]         head_addr,
    input      [31:0]        l0_coeff,
    output reg [2:0]         l0_addr,
    
    // Inputs from sync detector
    input      [8:0]         t_pointer_4,
    
    // Outputs
    output reg signed [32:0] v_est,
    output reg signed [15:0] v_est_num,
    output reg [11:0]        v_estimation_total,
    
    // Control
    input                    demo_valid,
    input                    demo_out_valid
);

    // Multiplication function
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
    reg [8:0]  f_est_begin;
    reg [8:0]  i, j;
    reg signed [31:0] Z_I[0:15];
    reg signed [31:0] Z_Q[0:15];
    reg signed [31:0] R_I;
    reg signed [31:0] R_Q;
    reg signed [31:0] R_I_tmp;
    reg signed [31:0] R_Q_tmp;
    reg [63:0] v_estimation;
    
    wire               m_axis_dout_tvalid;
    wire signed [11:0] v_est_tmp;
    
    integer idx;
    
    // Initialize Z arrays
    initial begin
        for (idx = 0; idx <= 15; idx = idx + 1) begin
            Z_I[idx] = 32'd0;
            Z_Q[idx] = 32'd0;
        end
        v_estimation = 64'd0;
    end
    
    // Frequency estimation triggered by peak_valid falling edge
    // This is combinational logic that executes once when peak_valid falls
    always @(negedge peak_valid or negedge rstn) begin
        if (!rstn) begin
            f_est_begin <= 9'd0;
            v_estimation <= 64'd0;
            for (idx = 0; idx <= 15; idx = idx + 1) begin
                Z_I[idx] <= 32'd0;
                Z_Q[idx] <= 32'd0;
            end
        end 
        else begin
            f_est_begin = (t_pointer_4 + 1) % 256;
            v_estimation = 64'd0;
            
            // Calculate Z_I and Z_Q (matched filter with head coefficients)
            // Note: This uses combinational reads from shared RAM and ROM
            for (i = 0; i <= 15; i = i + 1) begin
                j = (f_est_begin + i*4) % 256;
                ram_rd_addr = j[7:0];
                head_addr = i[3:0];
                // Combinational read: ram_rd_data and head_coeff are available immediately
                Z_I[i] = Mul(ram_rd_data_I, head_coeff_I) + Mul(ram_rd_data_Q, head_coeff_Q);
                Z_Q[i] = Mul(ram_rd_data_Q, head_coeff_I) - Mul(ram_rd_data_I, head_coeff_Q);
            end
            
            // Calculate autocorrelation R_I and R_Q
            for (i = 1; i <= 8; i = i + 1) begin
                R_I = 32'd0;
                R_Q = 32'd0;
                l0_addr = (i - 1)[2:0];
                for(j = i; j <= 15; j = j + 1) begin
                    R_I_tmp = Mul(Z_I[j], Z_I[j-i]) + Mul(Z_Q[j], Z_Q[j-i]);
                    R_I_tmp = Mul(R_I_tmp, l0_coeff);
                    R_Q_tmp = Mul(Z_Q[j], Z_I[j-i]) - Mul(Z_I[j], Z_Q[j-i]);
                    R_Q_tmp = Mul(R_Q_tmp, l0_coeff);
                    R_I = R_I + R_I_tmp;
                    R_Q = R_Q + R_Q_tmp;
                end
                v_estimation = v_estimation + {R_Q, R_I};
            end
        end
    end
    
    // CORDIC instance for phase estimation
    // Note: v_estimation is 64-bit, but CORDIC expects 32-bit input
    // Using lower 32 bits as in original code
    cordic_0 u_cordic( 
        .s_axis_cartesian_tvalid(1'b1),
        .s_axis_cartesian_tdata(v_estimation[31:0]),
        .m_axis_dout_tvalid(m_axis_dout_tvalid),
        .m_axis_dout_tdata(v_est_tmp)
    );
    
    // Process v_est (clk domain)
    always @(negedge clk or negedge rstn) begin
        if (!rstn)
            v_est <= 33'd0;
        else if (demo_valid > 0 && v_est == 0) begin
            if (v_est_tmp < 0)
                v_est <= ((-v_est_tmp) + 4096) % 4096;
            else
                v_est <= (v_est_tmp + 4096) % 4096;
            v_est <= v_est << 11;
        end
    end
    
    // v_est_num counter (clk domain)
    always @(negedge clk or negedge rstn) begin
        if (!rstn)
            v_est_num <= 16'd640;
        else if (demo_valid == 1'b1)
            v_est_num <= v_est_num + 1'b1;
    end
    
    // v_estimation_total calculation (clk domain)
    always @(negedge clk or negedge rstn) begin
        if (!rstn)
            v_estimation_total <= 12'd0;
        else if (demo_out_valid) begin
            v_estimation_total <= (Mul(v_est, v_est_num) >> 10) % 4096;
        end
    end

endmodule
