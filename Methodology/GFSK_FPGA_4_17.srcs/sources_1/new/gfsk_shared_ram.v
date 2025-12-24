// Shared RAM module for GFSK_I/Q samples
// Used by sync detector (write) and frequency estimator (read)
// Optimized: single dual-port RAM instead of separate I/Q RAMs
module gfsk_shared_ram(
    input                    clk_4,
    input                    rstn,
    
    // Write port (from sync detector, clk_4 domain)
    input                    wr_en,
    input      [7:0]         wr_addr,
    input      signed [15:0] wr_data_I,
    input      signed [15:0] wr_data_Q,
    
    // Read port 1 (for sync detector diff calculation, clk_4 domain)
    input      [7:0]         rd_addr_1,
    output reg signed [15:0] rd_data_I_1,
    output reg signed [15:0] rd_data_Q_1,
    
    // Read port 2 (for frequency estimator, async/peak_valid triggered)
    input      [7:0]         rd_addr_2,
    output reg signed [15:0] rd_data_I_2,
    output reg signed [15:0] rd_data_Q_2,
    
    // Clear all (triggered by demo_out_valid falling edge)
    input                    clear_all
);

    // Internal RAM arrays
    reg signed [15:0] RAM_GFSK_I [0:255];
    reg signed [15:0] RAM_GFSK_Q [0:255];
    
    integer i;
    
    // Write port (clk_4 domain)
    always @(negedge clk_4 or negedge rstn) begin
        if (!rstn) begin
            for (i = 0; i <= 255; i = i+1) begin
                RAM_GFSK_I[i] <= 16'd0;
                RAM_GFSK_Q[i] <= 16'd0;
            end
        end
        else if (clear_all) begin
            for (i = 0; i <= 255; i = i+1) begin
                RAM_GFSK_I[i] <= 16'd0;
                RAM_GFSK_Q[i] <= 16'd0;
            end
        end
        else if (wr_en) begin
            RAM_GFSK_I[wr_addr] <= wr_data_I;
            RAM_GFSK_Q[wr_addr] <= wr_data_Q;
        end
    end
    
    // Read port 1 (combinational, for sync detector)
    always @* begin
        rd_data_I_1 = RAM_GFSK_I[rd_addr_1];
        rd_data_Q_1 = RAM_GFSK_Q[rd_addr_1];
    end
    
    // Read port 2 (combinational, for frequency estimator)
    always @* begin
        rd_data_I_2 = RAM_GFSK_I[rd_addr_2];
        rd_data_Q_2 = RAM_GFSK_Q[rd_addr_2];
    end

endmodule














