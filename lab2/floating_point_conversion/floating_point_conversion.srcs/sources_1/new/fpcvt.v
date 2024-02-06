`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/30/2024 12:54:12 PM
// Design Name: 
// Module Name: fpcvt
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module fpcvt(D, S, E, F, clk);
    input [11:0] D;
    input clk;
    
    output reg S;
    output reg [2:0] E;
    output reg [3:0] F;
    
    reg [11:0] in_D;
    reg [11:0] stored_inD;
    
    integer i = 11;
    integer leading_zeros = 0;
    reg [3:0] significand;
    
    integer exp = 0; 
    integer fp_rep = 0;
    
    always @(D) begin
    // adjust D = -2048
        if (D == 12'b100000000000)
            in_D = 12'b100000000001;
        else
            in_D = D;
    
    // check negativity of D most sig bit
        if (D[11] == 1'b1) begin
            in_D = ~in_D + 1;
            S = 1'b1;
        end else begin
            in_D = D;
            S = 0;
        end
        
        stored_inD = in_D;
            
    // count leading zeros
        if (D != 12'b000000000000) begin
            while(in_D[11] == 1'b0)
                begin
                    leading_zeros = leading_zeros + 1;
                    in_D = in_D << 1;
                end
        end else begin
            leading_zeros = 0;
        end
//        $display("leading zeros: " ,leading_zeros);
//        $display ("in_D value is %b", in_D[11:8]);
        significand = in_D[11:8];
        
    // turn leading_zeros to corresponding exponent
        case(leading_zeros)
            1: exp = 7;
            2: exp = 6;
            3: exp = 5;
            4: exp = 4;
            5: exp = 3;
            6: exp = 2; 
            7: exp = 1;
            8: exp = 0;
            default: exp = 0;
        endcase  
        
        
//        $display("exp: %d", exp);

//        fp_rep = significand * 2 ** exp;
//        $display("fp_rep: %d  binary %b: ", fp_rep, fp_rep);  
        
    // round for significand
        $display ("in_D value is %b", in_D);
        if (in_D[7] == 1'b1 && leading_zeros <= 8) begin
            
            if (significand == 4'b1111) begin
                if (exp == 7) begin
                    exp = 3'b111;
                    significand = 4'b1111;
                end else begin
                    exp = exp + 1;
                    significand = 4'b1000;  
                end
            end else begin
                significand = significand + 1;
            end 
            
        end 
        
        if (leading_zeros >= 8) begin
            significand = stored_inD[3:0];
        end
        
        E = exp;  
        F = significand;  
    end 
     
//    always @(in_D) begin
//        $display ("in_D value is %b", in_D);
        
//    end
endmodule
