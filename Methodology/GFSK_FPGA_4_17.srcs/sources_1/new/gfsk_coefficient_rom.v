// Coefficient ROM module
// Contains all lookup tables: sin/cos, Cohe, Head, L0 coefficients
module gfsk_coefficient_rom(
    // Sin/Cos table outputs (combinational read)
    output reg signed [15:0] sin_val,
    output reg signed [15:0] cos_val,
    input      [11:0]        sin_cos_addr,
    
    // Cohe coefficient outputs
    output reg signed [63:0] cohe_coeff_I,
    output reg signed [63:0] cohe_coeff_Q,
    input      [4:0]         cohe_addr,
    
    // Head coefficient outputs
    output reg signed [15:0] head_coeff_I,
    output reg signed [15:0] head_coeff_Q,
    input      [3:0]         head_addr,
    
    // L0 coefficient output
    output reg [31:0]        l0_coeff,
    input      [2:0]         l0_addr,
    
    // CRC polynomial
    output reg [16:0]        crc_std
);

    // Internal ROM arrays
    reg signed [15:0] sin_table[0:4095];
    reg signed [15:0] cos_table[0:4095];
    reg signed [63:0] Cohe_coeff_I [0:30];
    reg signed [63:0] Cohe_coeff_Q [0:30];
    reg signed [15:0] Head_coeff_I[0:15];
    reg signed [15:0] Head_coeff_Q[0:15];
    reg         [31:0] L0_i_coeff [0:7];

    initial begin
        // Load sin/cos tables from external files
        $readmemh("cos_table.mem", cos_table);
        $readmemh("sin_table.mem", sin_table);
        
        // Cohe coefficients I
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
        Cohe_coeff_I[30] = 64'd17;
        
        // Cohe coefficients Q
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
        
        // Head coefficients I
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
        
        // Head coefficients Q
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
        
        // L0 coefficients
        L0_i_coeff[0] = 32'd68;
        L0_i_coeff[1] = 32'd73;
        L0_i_coeff[2] = 32'd78;
        L0_i_coeff[3] = 32'd85;
        L0_i_coeff[4] = 32'd93;
        L0_i_coeff[5] = 32'd102;
        L0_i_coeff[6] = 32'd113;
        L0_i_coeff[7] = 32'd128;
        
        // CRC polynomial
        crc_std = 17'b1_0001_0000_0010_0001;
    end
    
    // Combinational read outputs (0-cycle latency)
    always @* begin
        sin_val = sin_table[sin_cos_addr];
        cos_val = cos_table[sin_cos_addr];
        cohe_coeff_I = Cohe_coeff_I[cohe_addr];
        cohe_coeff_Q = Cohe_coeff_Q[cohe_addr];
        head_coeff_I = Head_coeff_I[head_addr];
        head_coeff_Q = Head_coeff_Q[head_addr];
        l0_coeff = L0_i_coeff[l0_addr];
    end

endmodule














