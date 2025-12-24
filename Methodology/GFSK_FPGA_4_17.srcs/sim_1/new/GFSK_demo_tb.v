module GFSK_demo_tb(
);

reg         clk;
reg         rstn;
reg  [31:0] cnt_top;
reg  [15:0] GFSK_TX_I;
reg  [15:0] GFSK_TX_Q;
reg  [15:0] GFSKBaseband_I    [0:20000000];
reg  [15:0] GFSKBaseband_Q    [0:20000000];
reg  [32:0] len_data          [0:2000];
reg         demo_data_std_mem [0:10000000];
wire [63:0] GFSK_cohe_diff;
wire [63:0] GFSK_self_diff;
wire        demo_out_valid;
wire        demo_data;
wire [10:0] num_demo;
wire [5:0]  cnt_demo;
reg         demo_data_std;
reg         bit_err;
reg  [15:0] bit_err_total;
reg  [32:0] idx;
reg  [32:0] idx_tmp;
wire        clk_1;

always  # 100  clk = ~clk;

Frame_detector f1(
    .clk(clk),
    .rstn(rstn),
    .GFSK_RX_I(GFSK_TX_I),
    .GFSK_RX_Q(GFSK_TX_Q),
    .GFSK_cohe_diff(GFSK_cohe_diff),
    .GFSK_self_diff(GFSK_self_diff),
    .demo_data(demo_data),
    .demo_out_valid(demo_out_valid),
    .num_demo(num_demo),
    .cnt_demo(cnt_demo)
);

frequency_1 fre_1_tb(
    .clk(clk),
	.rstn(rstn),
	.clk_1(clk_1)
);

initial begin
//    $readmemh("C:/Users/24248/Desktop/GFSK_MTLB_4_17_fixed_FPGA/raw_data_no_CRC.txt",demo_data_std_mem);
//    $readmemh("C:/Users/24248/Desktop/GFSK_MTLB_4_17_fixed_FPGA/GFSKBaseband_real.txt",GFSKBaseband_I);
//    $readmemh("C:/Users/24248/Desktop/GFSK_MTLB_4_17_fixed_FPGA/GFSKBaseband_imag.txt",GFSKBaseband_Q);
//    $readmemh("C:/Users/24248/Desktop/GFSK_MTLB_4_17_fixed_FPGA/len_data_out.txt",len_data); 
    $readmemh("C:/Users/24248/Desktop/raw_data_no_CRC.txt",demo_data_std_mem);
    $readmemh("C:/Users/24248/Desktop/GFSKBaseband_real.txt",GFSKBaseband_I);
    $readmemh("C:/Users/24248/Desktop/GFSKBaseband_imag.txt",GFSKBaseband_Q);
    $readmemh("C:/Users/24248/Desktop/len_data_out.txt",len_data); 
    clk <= 0;
    rstn <= 1;
    # 100
    rstn <= 0;
    # 1
    rstn <= 1;
end

always @(negedge clk or negedge rstn) begin
    if (!rstn)
        cnt_top <= 32'd0;
    else 
        cnt_top <= cnt_top + 1;
end

always @(negedge clk or negedge rstn) begin
    if (!rstn)
        GFSK_TX_I <= 16'd0;
    else 
        GFSK_TX_I <= GFSKBaseband_I[cnt_top];
end

always @(negedge clk or negedge rstn) begin
    if (!rstn)
        GFSK_TX_Q <= 16'd0;
    else 
        GFSK_TX_Q <= GFSKBaseband_Q[cnt_top];
end

always @(negedge clk or negedge rstn) begin
    if (!rstn)
        demo_data_std <= 16'd0;
    else if (cnt_demo == 6'd19)
        demo_data_std <= demo_data_std_mem[num_demo+idx];
    else if (!demo_out_valid)
        demo_data_std = 0;
end


always @(negedge clk or negedge rstn) begin
    if (!rstn)
        bit_err <= 1'b0;
    else if (demo_out_valid) begin
        if (demo_data_std != demo_data)
            bit_err <= 1'b1;
        else
            bit_err <= 1'b0;
    end
end

always @(negedge clk_1 or negedge rstn) begin
    if (!rstn)
        bit_err_total <= 1'b0;
    else if (bit_err)
        bit_err_total <= bit_err_total + 1'b1;
end

//always @(negedge clk or negedge rstn) begin
//    if (!rstn)
//        idx_tmp = 0;
//    else
//        idx_tmp = num_demo;
//end

always @(posedge demo_out_valid or negedge rstn) begin
    if (!rstn)
        idx_tmp = 0;
    else
        idx_tmp = idx_tmp + 1;
end

always @(negedge demo_out_valid or negedge rstn) begin
    if (!rstn)
        idx = 0;
    else
        idx = len_data[idx_tmp];
end

endmodule
