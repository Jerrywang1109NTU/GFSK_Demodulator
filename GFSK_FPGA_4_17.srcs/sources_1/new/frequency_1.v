module frequency_1 (
   	input        clk,
	input        rstn,
	output  reg  clk_1
);
reg  [7:0]  cnt_1;

parameter  fs_times_1 = 8'd9; //1024/64=16???

always @(negedge clk  or  negedge rstn) begin
	if (!rstn)
		cnt_1 <= 8'b0;
	else if (cnt_1 < fs_times_1)
        cnt_1 <= cnt_1 + 1'b1;
    else 
        cnt_1 <= 8'b0;
end

always @(negedge clk  or  negedge rstn) begin
    if (!rstn)
        clk_1 <= 0;
    else if (cnt_1 < fs_times_1)
        clk_1 <= clk_1;
    else
        clk_1 <= ~clk_1;
end
  
endmodule
