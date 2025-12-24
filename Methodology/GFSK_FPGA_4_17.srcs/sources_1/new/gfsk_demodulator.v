// Differential Demodulator Module
// clk domain: carrier rotation, differential demodulation, CRC check
module gfsk_demodulator(
    input                    clk,
    input                    rstn,
    input                    clk_1,
    
    // Input samples
    input      signed [15:0] GFSK_RX_I,
    input      signed [15:0] GFSK_RX_Q,
    
    // Frequency offset compensation
    input      [11:0]        v_estimation_total,
    
    // Coefficient ROM interface (sin/cos)
    input      signed [15:0] sin_val,
    input      signed [15:0] cos_val,
    output reg [11:0]        sin_cos_addr,
    
    // Coefficient ROM interface (CRC)
    input      [16:0]        crc_std,
    
    // Control inputs
    input                    demo_valid,
    
    // Outputs
    output reg               demo_data,
    output reg               demo_out_valid,
    output reg [10:0]        num_demo,
    output reg [5:0]         cnt_demo,
    output reg               CRC_check,
    
    // Clear signal (output to other modules)
    output reg               clear_all
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
    reg [4:0]  t_pointer_20;
    reg [8:0]  demo_length;
    reg [16:0] demo_data_decimal;
    reg signed [31:0] RAM_GFSK_I_demo[0:31];
    reg signed [31:0] RAM_GFSK_Q_demo[0:31];
    reg signed [63:0] demo_data_IQ;
    reg                CRC_valid;
    
    integer i, j, k;
    integer idx;
    
    // Initialize demo RAM
    initial begin
        for (idx = 0; idx <= 31; idx = idx + 1) begin
            RAM_GFSK_I_demo[idx] = 32'd0;
            RAM_GFSK_Q_demo[idx] = 32'd0;
        end
    end
    
    // t_pointer_20 counter
    always @(negedge clk or negedge rstn) begin
        if (!rstn)
            t_pointer_20 <= 5'd0;
        else
            t_pointer_20 <= (t_pointer_20 + 1'b1) % 32;
    end
    
    // Carrier rotation: I channel (using sin/cos table)
    always @(negedge clk or negedge rstn) begin
        if (!rstn) begin
            for (idx = 0; idx <= 31; idx = idx + 1)
                RAM_GFSK_I_demo[idx] <= 32'd0;
        end
        else begin
            sin_cos_addr <= v_estimation_total;
            RAM_GFSK_I_demo[t_pointer_20] <= Mul(GFSK_RX_I, cos_val) + Mul(GFSK_RX_Q, sin_val);
        end
    end
    
    // Carrier rotation: Q channel
    always @(negedge clk or negedge rstn) begin
        if (!rstn) begin
            for (idx = 0; idx <= 31; idx = idx + 1)
                RAM_GFSK_Q_demo[idx] <= 32'd0;
        end
        else begin
            RAM_GFSK_Q_demo[t_pointer_20] <= Mul(GFSK_RX_Q, cos_val) - Mul(GFSK_RX_I, sin_val);
        end
    end
    
    // cnt_demo counter
    always @(negedge clk or negedge rstn) begin
        if (!rstn)
            cnt_demo <= 6'd0;
        else if (demo_valid == 1'b1)
            cnt_demo <= (cnt_demo + 1'b1) % 20;
    end
    
    // num_demo counter
    always @(negedge clk or negedge rstn) begin
        if (!rstn)
            num_demo <= 11'd0;
        else if (cnt_demo == 6'd19)
            num_demo <= num_demo + 1'b1;
    end
    
    // demo_out_valid and CRC_valid generation
    always @(negedge clk or negedge rstn) begin
        if (!rstn) begin
            demo_out_valid <= 1'b0;
            CRC_valid <= 1'b0;
        end
        else begin
            if (cnt_demo == 6'd19)
                demo_out_valid <= 1'b1;
            if (num_demo == 11'd16 && cnt_demo == 6'd19)
                CRC_valid <= 1'b1;
            if (num_demo >= 11'd9 && num_demo == (11'd8 + demo_length + 11'd16) && cnt_demo == 6'd19) begin
                demo_out_valid <= 1'b0;
            end
        end
    end
    
    // demo_length extraction (from first 8 bits)
    always @(negedge clk or negedge rstn) begin
        if (!rstn)
            demo_length <= 9'd0;
        else if (num_demo >= 11'd1 && num_demo <= 11'd8 && cnt_demo == 6'd19) begin
            demo_length = demo_length * 2 + demo_data;
            if (demo_length >= 256)
                demo_length = 255;
        end
    end
    
    // Differential demodulation and CRC calculation
    always @(negedge clk or negedge rstn) begin
        if (!rstn) begin
            demo_data <= 1'b0;
            demo_data_IQ <= 64'd0;
            demo_data_decimal <= 17'd0;
        end
        else if (demo_valid == 1'b0)
            demo_data <= 1'b0;
        else if (cnt_demo == 6'd19 && num_demo < (11'd8 + demo_length + 11'd16)) begin
            demo_data_IQ = 64'd0;
            for (i = 0; i <= 6; i = i + 1) begin
                j = (t_pointer_20 - i + 32) % 32;
                k = (t_pointer_20 - 20 + i + 32) % 32;
                demo_data_IQ = demo_data_IQ + Mul(RAM_GFSK_Q_demo[j], RAM_GFSK_I_demo[k]) - Mul(RAM_GFSK_I_demo[j], RAM_GFSK_Q_demo[k]);
            end
            if (demo_data_IQ > 0)
                demo_data <= 1'b1;
            else
                demo_data <= 1'b0;
            
            // CRC calculation
            if (CRC_valid) begin 
                if (demo_data_decimal[16] == 1)
                    demo_data_decimal[16:0] <= {(demo_data_decimal[15:0] ^ crc_std[15:0]), demo_data};
                else
                    demo_data_decimal[16:0] <= {demo_data_decimal[15:0], demo_data};
            end
            else
                demo_data_decimal[16:0] <= {demo_data_decimal[15:0], demo_data};
        end
    end
    
    // Clear all when demo_out_valid falls
    always @(negedge demo_out_valid) begin
        clear_all <= 1'b1;
        demo_length <= 9'd0;
        num_demo <= 11'd0;
        cnt_demo <= 6'd0;
        v_estimation_total <= 12'd0;
        CRC_valid <= 1'b0;
        demo_data_decimal <= 17'd0;
        for (idx = 0; idx <= 31; idx = idx + 1) begin
            RAM_GFSK_I_demo[idx] <= 32'd0;
            RAM_GFSK_Q_demo[idx] <= 32'd0;
        end
    end
    
    // Clear clear_all signal after one cycle
    always @(posedge clk) begin
        if (clear_all)
            clear_all <= 1'b0;
    end
    
    // CRC_check (clk_1 domain)
    always @(negedge clk_1 or negedge rstn) begin
        if (!rstn)
            CRC_check <= 1'b0;
        else if (!demo_out_valid) 
            CRC_check <= 1'b0;
        else if (demo_data_decimal[15:0] != 16'd0)
            CRC_check <= 1'b1;
    end

endmodule














