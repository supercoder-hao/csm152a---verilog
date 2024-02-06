//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/30/2024 12:46:02 PM
// Design Name: 
// Module Name: floating_point_conversion_tb
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
`timescale 1ns / 1ps

module floating_point_conversion_tb;

	//craft local parameters
//    reg [3:0] localIn;
//    reg [2:0] localOut;
    reg [11:0] D;
    wire S;
    wire [2:0] E;
    wire [3:0] F;

	// you need to init the module being tested and link the parameters
	fpcvt UUT (
		.D(D),
        .S(S),
        .E(E),
        .F(F)
	);
    // Start the testbench
	initial begin
		//Modify the input
//        D = 12'b111001011010;
//        D = 12'b000000101110;
//        D = 12'b111111111111;
//        D = 12'b100000000000;
//        D = 12'b011111111111;
        D = 12'b111001011010;
        $display ("original in_D value is %b", D);
        //Wait for 10ns
        #10;
        //Print the output
        $display("Output is %b, %b, %b", S, E, F);
        
        #1000
        $finish;
	end
      
endmodule


