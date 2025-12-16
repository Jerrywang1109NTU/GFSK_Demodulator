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

wire               clk_1;
wire               clk_4;
reg         [8:0]  i;
reg         [8:0]  j;
reg         [8:0]  k;
//reg         [5:0]  cnt_demo;
//reg         [10:0] num_demo;
reg         [8:0]  demo_length;
reg         [8:0]  t_pointer_4;
reg         [4:0]  t_pointer_20;
reg         [10:0] frame_begin_4;
reg         [16:0] demo_data_decimal;
reg         [16:0] CRC_std;
reg        [199:0] raw_data_std;
reg  signed [63:0] GFSK_cohe_diff_I;
reg  signed [63:0] GFSK_cohe_diff_Q;
reg  signed [63:0] demo_data_IQ;
reg  signed [63:0] demo_data_IQ_1;
reg  signed [63:0] demo_data_IQ_2;
reg  signed [63:0] GFSK_cohe_diff_lst;
reg  signed [15:0] RAM_GFSK_I [0:255];
reg  signed [15:0] RAM_GFSK_Q [0:255];
reg  signed [31:0] RAM_DIFF_I [0:255];
reg  signed [31:0] RAM_DIFF_Q [0:255];
reg  signed [31:0] RAM_GFSK_I_demo[0:31];
reg  signed [31:0] RAM_GFSK_Q_demo[0:31];
reg  signed [31:0] RAM_GFSK_I_demo_tmp;
reg  signed [31:0] RAM_GFSK_Q_demo_tmp;
reg  signed [63:0] Cohe_coeff_I [0:30];
reg  signed [63:0] Cohe_coeff_Q [0:30];
reg         [31:0] L0_i_coeff [0:7];
reg  signed [15:0] sin_table[0:4095];
reg  signed [15:0] cos_table[0:4095];
reg  signed [15:0] Head_coeff_I[0:15];
reg  signed [15:0] Head_coeff_Q[0:15];
reg  signed [31:0] Z_I[0:15];
reg  signed [31:0] Z_Q[0:15];
//reg         [63:0] v_estimation_tmp;
reg         [63:0] v_estimation;
reg         [63:0] v_estimation_total;
reg                peak_valid;
//reg                demo_out_valid;
reg                demo_valid;
reg         [8:0]  f_est_begin;
reg  signed [31:0] R_I;
reg  signed [31:0] R_Q;
reg  signed [31:0] R_I_tmp;
reg  signed [31:0] R_Q_tmp;
reg  signed [11:0] sin_2_phi_neg_cos[0:4095];
reg  signed [11:0] sin_2_phi_pos_cos[0:4095];
wire               m_axis_dout_tvalid;
wire signed [11:0] v_est_tmp;
reg  signed [32:0] v_est;
reg  signed [15:0] v_est_num;
reg                CRC_valid;
reg                CRC_check;

initial begin
    // sin/cos tables moved to external mem files
    $readmemh("cos_table.mem", cos_table);
    $readmemh("sin_table.mem", sin_table);

    
    Cohe_coeff_I[0]  = -64'd403;
    Cohe_coeff_I[1]  = 64'd150;
    Cohe_coeff_I[2]  = 64'd372;
    Cohe_coeff_I[3]  = -64'd401;
    Cohe_coeff_I[4]  = 64'd149;
    Cohe_coeff_I[5]  = -64'd402;
    Cohe_coeff_I[6]  = 64'd150;
    Cohe_coeff_I[7]  = -64'd401;
    Cohe_coeff_I[8]  = -64'd602;
    Cohe_coeff_I[9]  = -64'd603;
    Cohe_coeff_I[10] = 64'd150;
    Cohe_coeff_I[11] = 64'd372;
    Cohe_coeff_I[12] = 64'd372;
    Cohe_coeff_I[13] = -64'd402;
    Cohe_coeff_I[14] = 64'd148;
    Cohe_coeff_I[15] = 64'd370;
    Cohe_coeff_I[16] = 64'd370;
    Cohe_coeff_I[17] = 64'd370;
    Cohe_coeff_I[18] = 64'd370;
    Cohe_coeff_I[19] = -64'd402;
    Cohe_coeff_I[20] = -64'd602;
    Cohe_coeff_I[21] = 64'd148;
    Cohe_coeff_I[22] = -64'd403;
    Cohe_coeff_I[23] = -64'd601;
    Cohe_coeff_I[24] = 64'd148;
    Cohe_coeff_I[25] = 64'd370;
    Cohe_coeff_I[26] = -64'd403;
    Cohe_coeff_I[27] = -64'd602;
    Cohe_coeff_I[28] = -64'd601;
    Cohe_coeff_I[29] = 64'd148;
    Cohe_coeff_I[30] = 64'd17;  // ?????????17
    
    Cohe_coeff_Q[0]  = -64'd942;
    Cohe_coeff_Q[1]  = -64'd1015;
    Cohe_coeff_Q[2]  = 64'd954;
    Cohe_coeff_Q[3]  = -64'd943;
    Cohe_coeff_Q[4]  = -64'd1013;
    Cohe_coeff_Q[5]  = 64'd941;
    Cohe_coeff_Q[6]  = 64'd1013;
    Cohe_coeff_Q[7]  = -64'd943;
    Cohe_coeff_Q[8]  = -64'd828;
    Cohe_coeff_Q[9]  = -64'd828;
    Cohe_coeff_Q[10] = -64'd1014;
    Cohe_coeff_Q[11] = 64'd954;
    Cohe_coeff_Q[12] = -64'd955;
    Cohe_coeff_Q[13] = 64'd942;
    Cohe_coeff_Q[14] = 64'd1012;
    Cohe_coeff_Q[15] = -64'd954;
    Cohe_coeff_Q[16] = 64'd953;
    Cohe_coeff_Q[17] = -64'd954;
    Cohe_coeff_Q[18] = 64'd953;
    Cohe_coeff_Q[19] = -64'd942;
    Cohe_coeff_Q[20] = -64'd830;
    Cohe_coeff_Q[21] = -64'd1013;
    Cohe_coeff_Q[22] = 64'd941;
    Cohe_coeff_Q[23] = 64'd829;
    Cohe_coeff_Q[24] = 64'd1012;
    Cohe_coeff_Q[25] = -64'd954;
    Cohe_coeff_Q[26] = 64'd940;
    Cohe_coeff_Q[27] = 64'd828;
    Cohe_coeff_Q[28] = 64'd829;
    Cohe_coeff_Q[29] = 64'd1012;
    Cohe_coeff_Q[30] = -64'd1024;
    
    Head_coeff_I[0] = 16'd668;
    Head_coeff_I[1] = 16'd965;
    Head_coeff_I[2] = 16'd668;
    Head_coeff_I[3] = 16'd965;
    Head_coeff_I[4] = 16'd668;
    Head_coeff_I[5] = 16'd965;
    Head_coeff_I[6] = 16'd668;
    Head_coeff_I[7] = 16'd965;
    Head_coeff_I[8] = 16'd668;
    Head_coeff_I[9] = 16'd965;
    Head_coeff_I[10] = 16'd668;
    Head_coeff_I[11] = 16'd965;
    Head_coeff_I[12] = 16'd668;
    Head_coeff_I[13] = 16'd965;
    Head_coeff_I[14] = 16'd668;
    Head_coeff_I[15] = 16'd965;
    
    Head_coeff_Q[0] = 16'd775;
    Head_coeff_Q[1] = -16'd342;
    Head_coeff_Q[2] = 16'd775;
    Head_coeff_Q[3] = -16'd342;
    Head_coeff_Q[4] = 16'd775;
    Head_coeff_Q[5] = -16'd342;
    Head_coeff_Q[6] = 16'd775;
    Head_coeff_Q[7] = -16'd342;
    Head_coeff_Q[8] = 16'd775;
    Head_coeff_Q[9] = -16'd342;
    Head_coeff_Q[10] = 16'd775;
    Head_coeff_Q[11] = -16'd342;
    Head_coeff_Q[12] = 16'd775;
    Head_coeff_Q[13] = -16'd342;
    Head_coeff_Q[14] = 16'd775;
    Head_coeff_Q[15] = -16'd342;
    
    L0_i_coeff[0] = 32'd68;
    L0_i_coeff[1] = 32'd73;
    L0_i_coeff[2] = 32'd78;
    L0_i_coeff[3] = 32'd85;
    L0_i_coeff[4] = 32'd93;
    L0_i_coeff[5] = 32'd102;
    L0_i_coeff[6] = 32'd113;
    L0_i_coeff[7] = 32'd128;
    
    CRC_std = 17'b1_0001_0000_0010_0001;
//    raw_data_std = 199'd43673149607181975721059584348839596841336;
end


frequency_4 fre_4_f(
    .clk(clk),
	.rstn(rstn),
	.clk_4(clk_4)
);

frequency_1 fre_1_f(
    .clk(clk),
	.rstn(rstn),
	.clk_1(clk_1)
);

// 
always @(negedge clk_4 or negedge rstn) begin
    if (!rstn)
        t_pointer_4 <= 9'd0;
    else 
        t_pointer_4 = (t_pointer_4 + 1'b1)%256;
end

//
always @(negedge clk_4 or negedge rstn) begin
    if (!rstn) begin
        for (i = 0; i <= 255; i = i+1)
            RAM_GFSK_I [i] = 32'd0;
//        RAM_GFSK_I [i] = 32'd0;
    end
    else if (demo_valid == 1'b0)
        RAM_GFSK_I [t_pointer_4] = GFSK_RX_I;
end

//
always @(negedge clk_4 or negedge rstn) begin
    if (!rstn) begin
        for (i = 0; i <= 255; i = i+1)
            RAM_GFSK_Q [i] = 32'd0;
//        RAM_GFSK_Q [i] = 32'd0;
    end
    else if (demo_valid == 1'b0)
        RAM_GFSK_Q [t_pointer_4] = GFSK_RX_Q;
end

//
always @(negedge clk_4 or negedge rstn) begin
    if (!rstn) begin
        for (i = 0; i <= 255; i = i+1)
            RAM_DIFF_I [i] = 32'd0;
//        RAM_DIFF_I [i] = 32'd0;
    end
    else if (demo_valid == 1'b0) begin
        j = (t_pointer_4 + 254)%256;
        RAM_DIFF_I [t_pointer_4] = Mul(RAM_GFSK_I [t_pointer_4], RAM_GFSK_I [j]) + Mul(RAM_GFSK_Q [t_pointer_4], RAM_GFSK_Q [j]);
//        RAM_DIFF_I [t_pointer_4] = RAM_DIFF_I [t_pointer_4] >> 15;
    end 
end

//
always @(negedge clk_4 or negedge rstn) begin
    if (!rstn) begin
        for (i = 0; i <= 255; i = i+1)
            RAM_DIFF_Q [i] = 32'd0;
//        RAM_DIFF_Q [i] = 32'd0;
    end
    else if (demo_valid == 1'b0) begin
        j = (t_pointer_4 + 254)%256;
        RAM_DIFF_Q [t_pointer_4] = Mul(RAM_GFSK_I[t_pointer_4], RAM_GFSK_Q[j]) - Mul(RAM_GFSK_Q [t_pointer_4], RAM_GFSK_I [j]);
//        RAM_DIFF_Q [t_pointer_4] = RAM_DIFF_Q [t_pointer_4] >> 15;
    end
end

//
always @(negedge clk_4 or negedge rstn) begin
    if (!rstn) begin
        demo_valid = 1'b0;
        frame_begin_4 <= 11'b0;
        peak_valid <= 1'b0;
        GFSK_self_diff <= 32'd0;
        GFSK_cohe_diff <= 64'd0;
        GFSK_cohe_diff_I <= 64'd0;
        GFSK_cohe_diff_Q <= 64'd0;
        GFSK_cohe_diff_lst <= 64'd0;
    end
    else if (demo_valid == 1'b0) begin // if (t_pointer_4 >= 11'd130) 
        GFSK_self_diff = 0;
        GFSK_cohe_diff_lst = GFSK_cohe_diff;
        GFSK_cohe_diff = 0;
        GFSK_cohe_diff_I = 0;
        GFSK_cohe_diff_Q = 0;
        for (i = 0; i <= 30; i = i+1) begin
            j = (t_pointer_4 - i*4 + 256)%256;
            k = 30 - i;
            GFSK_self_diff = GFSK_self_diff + Mul(RAM_DIFF_I [j], RAM_DIFF_I [j]) + Mul(RAM_DIFF_Q [j], RAM_DIFF_Q [j]);
            GFSK_cohe_diff_I = GFSK_cohe_diff_I + Mul(RAM_DIFF_I [j], Cohe_coeff_I [k]) - Mul(RAM_DIFF_Q [j], Cohe_coeff_Q [k]);
            GFSK_cohe_diff_Q = GFSK_cohe_diff_Q + Mul(RAM_DIFF_I [j], Cohe_coeff_Q [k]) + Mul(RAM_DIFF_Q [j], Cohe_coeff_I [k]);
        end
        GFSK_self_diff = (GFSK_self_diff << 2)+GFSK_self_diff;
//        GFSK_self_diff = GFSK_self_diff >> 13;
//        GFSK_cohe_diff_I = GFSK_cohe_diff_I >> 15;
//        GFSK_cohe_diff_Q = GFSK_cohe_diff_Q >> 15;
        GFSK_cohe_diff = Mul(GFSK_cohe_diff_I, GFSK_cohe_diff_I) + Mul(GFSK_cohe_diff_Q, GFSK_cohe_diff_Q);
//        GFSK_cohe_diff = GFSK_cohe_diff >> 15;
        if (GFSK_cohe_diff >= GFSK_self_diff && GFSK_cohe_diff >= 64'd10000 && demo_valid == 1'b0)
            peak_valid = 1'b1;
        if (peak_valid == 1'b1 && GFSK_cohe_diff < GFSK_cohe_diff_lst && frame_begin_4 == 11'd0) begin
            frame_begin_4 = t_pointer_4;
            peak_valid = 1'b0;
            demo_valid = 1'b1;
        end  
    end
end

// ??????
always @(negedge peak_valid or negedge rstn) begin
    if (!rstn) begin
        f_est_begin = 1'b0;
        v_estimation = 1'b0;
        for (i = 0; i <= 15; i = i+1) begin
            Z_I[i] = 32'd0;
            Z_Q[i] = 32'd0;
        end 
    end 
    else begin
        f_est_begin = (t_pointer_4 + 1)%256;
        v_estimation = 1'b0;
        for (i = 0; i <= 15; i = i+1) begin
            j = (f_est_begin + i*4)%256;
            Z_I[i] = Mul(RAM_GFSK_I[j], Head_coeff_I[i]) + Mul(RAM_GFSK_Q[j], Head_coeff_Q[i]);
//            Z_I[i] = Z_I[i] >> 15;
            Z_Q[i] = Mul(RAM_GFSK_Q[j], Head_coeff_I[i]) - Mul(RAM_GFSK_I[j], Head_coeff_Q[i]);
//            Z_Q[i] = Z_Q[i] >> 15;
        end
        for (i = 1; i <= 8; i = i+1) begin
            R_I = 32'd0;
            R_Q = 32'd0;
            for(j = i; j <= 15; j = j+1) begin
                R_I_tmp = Mul(Z_I[j], Z_I[j-i]) + Mul(Z_Q[j], Z_Q[j-i]);
//                R_I_tmp = R_I_tmp >> 15;
                R_I_tmp = Mul(R_I_tmp, L0_i_coeff[i-1]);
//                R_I_tmp = R_I_tmp >> 15;
                R_Q_tmp = Mul(Z_Q[j], Z_I[j-i]) - Mul(Z_I[j], Z_Q[j-i]);
//                R_Q_tmp = R_Q_tmp >> 15;
                R_Q_tmp = Mul(R_Q_tmp, L0_i_coeff[i-1]);
//                R_Q_tmp = R_Q_tmp >> 15;
                R_I = R_I + R_I_tmp;
                R_Q = R_Q + R_Q_tmp;
            end
            v_estimation = v_estimation + {R_Q, R_I};
        end
    end
end

cordic_0 p1( 
    .s_axis_cartesian_tvalid(1),  // input wire s_axis_cartesian_tvalid
    .s_axis_cartesian_tdata(v_estimation),    // input wire [31 : 0] s_axis_cartesian_tdata
    .m_axis_dout_tvalid(m_axis_dout_tvalid),            // output wire m_axis_dout_tvalid
    .m_axis_dout_tdata(v_est_tmp)              // output wire [15 : 0] m_axis_dout_tdata
);

always @(negedge clk or negedge rstn) begin
    if (!rstn)
        v_est = 0;
    else if (demo_valid > 0 && v_est == 0) begin
        if (v_est_tmp < 0)
            v_est = (-v_est_tmp + 4096)%4096;
        else
            v_est = (v_est_tmp + 4096)%4096;
        v_est = v_est << 11;
//        v_est = v_est >> 9;
        
    end
end

always @(negedge clk or negedge rstn) begin
    if (!rstn)
        v_estimation_total <= 0;
    else if (demo_out_valid) begin
        v_estimation_total = Mul(v_est, v_est_num);
        v_estimation_total = v_estimation_total >> 10;
        v_estimation_total = v_estimation_total % 4096;
    end
end
// ???????

always @(negedge clk or negedge rstn) begin
    if (!rstn)
        cnt_demo = 6'd0;
    else if (demo_valid == 1'b1)
        cnt_demo <= (cnt_demo + 1'b1)%20;
end

always @(negedge clk or negedge rstn) begin
    if (!rstn)
        v_est_num = 16'd640;
    else if (demo_valid == 1'b1)
        v_est_num <= v_est_num + 1'b1;
end

always @(negedge clk or negedge rstn) begin
    if (!rstn)
        t_pointer_20 = 5'd0;
    else
        t_pointer_20 <= t_pointer_20 + 1'b1;
end

always @(negedge clk or negedge rstn) begin
    if (!rstn) begin
        for (i = 0; i <= 31; i = i+1)
            RAM_GFSK_I_demo [i] = 32'd0;
//        RAM_GFSK_I_demo [i] = 32'd0;
    end
    else begin
        RAM_GFSK_I_demo[t_pointer_20] = Mul(GFSK_RX_I, cos_table[v_estimation_total]) + Mul(GFSK_RX_Q, sin_table[v_estimation_total]);
//        RAM_GFSK_I_demo[t_pointer_20] = GFSK_RX_I;
    end
end

// Q??????RAM
always @(negedge clk or negedge rstn) begin
    if (!rstn) begin
        for (i = 0; i <= 31; i = i+1)
            RAM_GFSK_Q_demo [i] = 32'd0;
//        RAM_GFSK_Q_demo [i] = 32'd0;
    end
    else begin
        RAM_GFSK_Q_demo[t_pointer_20] = Mul(GFSK_RX_Q, cos_table[v_estimation_total]) - Mul(GFSK_RX_I, sin_table[v_estimation_total]);
//        RAM_GFSK_Q_demo[t_pointer_20] = GFSK_RX_Q;
    end
end

always @(negedge clk or negedge rstn) begin
    if (!rstn)
        num_demo <= 11'd0;
    else if (cnt_demo == 6'd19)
        num_demo <= num_demo + 1'b1;
end

always @(negedge clk or negedge rstn) begin
    if (!rstn)
        demo_out_valid <= 1'b0;
    else begin
        if (cnt_demo == 6'd19)
            demo_out_valid <= 1'b1;
        if (num_demo == 16 && cnt_demo == 19)
            CRC_valid <= 1'b1;
        if (num_demo >= 9 && num_demo == (11'd8 + demo_length + 11'd16) && cnt_demo == 19) begin
            demo_out_valid <= 1'b0;
//            CRC_valid <= 1'b1;
        end
    end
end

always @(negedge clk or negedge rstn) begin
    if (!rstn)
        demo_length <= 8'b0;
    else if (num_demo >= 11'd1 && num_demo <= 11'd8 && cnt_demo == 6'd19) begin
        demo_length = demo_length*2 + demo_data;
        if (demo_length>=256)
            demo_length = 255;
    end
end

always @(negedge clk or negedge rstn) begin
    if (!rstn) begin
        demo_data = 1'b0;
        demo_data_IQ = 31'd0;
        demo_data_decimal = 17'd0;
    end
    else if (demo_valid == 0)
        demo_data = 1'b0;
    else if (cnt_demo == 6'd19 && num_demo < (11'd8 + demo_length + 11'd16)) begin
        demo_data_IQ = 0;
        for (i = 0; i <= 6 ; i = i+1) begin
            j = (t_pointer_20 - i + 32)%32;
            k = (t_pointer_20 - 20 + i + 32)%32;
            demo_data_IQ = demo_data_IQ + Mul(RAM_GFSK_Q_demo[j], RAM_GFSK_I_demo[k]) - Mul(RAM_GFSK_I_demo[j], RAM_GFSK_Q_demo[k]);
        end
        if (demo_data_IQ > 0)
            demo_data = 1'b1;
        else
            demo_data = 1'b0;
        if (CRC_valid) begin 
            if (demo_data_decimal[16] == 1)
                demo_data_decimal[16:0] <= {(demo_data_decimal[15:0]^CRC_std[15:0]), demo_data};
            else
                demo_data_decimal[16:0] <= {demo_data_decimal[15:0], demo_data};
        end
        else
            demo_data_decimal[16:0] <= {demo_data_decimal[15:0], demo_data};
    end
end

always @(negedge demo_out_valid) begin
    demo_valid <= 1'b0;
    for (i = 0; i <= 255; i = i+1)
        RAM_DIFF_Q [i] = 32'd0;
    for (i = 0; i <= 255; i = i+1)
        RAM_DIFF_I [i] = 32'd0;
    for (i = 0; i <= 255; i = i+1)
        RAM_GFSK_I [i] = 32'd0;
    for (i = 0; i <= 255; i = i+1)
        RAM_GFSK_Q [i] = 32'd0;
    for (i = 0; i <= 31; i = i+1)
        RAM_GFSK_I_demo [i] = 32'd0;
    for (i = 0; i <= 31; i = i+1)
        RAM_GFSK_Q_demo [i] = 32'd0;
    demo_length <= 11'b0;
    v_est = 0;
    num_demo = 0;
    cnt_demo = 0;
    frame_begin_4 = 0;
    v_est_num = 16'd0;
    v_estimation_total = 0;
    CRC_valid = 0;
    if (demo_data_decimal[15:0] != 16'd0)
        CRC_check = 1'b1;
    demo_data_decimal = 17'd0;
end

always @(negedge clk_1 or negedge rstn) begin
    if (!rstn)
        CRC_check = 1'b0;
    else if (!demo_out_valid) 
        CRC_check = 1'b0;
end

endmodule
