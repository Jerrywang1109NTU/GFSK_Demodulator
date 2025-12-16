module frequency_4 (
   	input        clk,
	input        rstn,
	output  reg  clk_4
);

reg  [7:0]  cnt_4;
parameter  fs_times_4 = 4; //1024/4=256???

always @(negedge clk  or  negedge rstn) begin
	if (!rstn)
		cnt_4 <= 8'b0;
	else if (cnt_4 < fs_times_4)
        cnt_4 <= cnt_4 + 1;
    else 
        cnt_4 <= 8'b0;
end

always @(negedge clk  or  negedge rstn) begin
    if (!rstn)
        clk_4 <= 0;
    else if (cnt_4 == 2)
        clk_4 <= ~clk_4;
    else if (cnt_4 == fs_times_4)
        clk_4 <= ~clk_4;
end
  
endmodule