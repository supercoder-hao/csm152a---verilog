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

    integer i;
    reg [11:0] testcase [0:1023];
	// you need to init the module being tested and link the parameters
	fpcvt UUT (
		.D(D),
        .S(S),
        .E(E),
        .F(F)
	);
    // Start the testbench
	initial begin
//		Modify the input
//        D = 12'b100000000000;
//        #10;
//        $display ("original in_D value is %b", D);
//        #10;
//        $display("Output is %b, %b, %b", S, E, F);
//        #10;
//        D = 12'b100000000001;
//        #10;
//        $display ("original in_D value is %b", D);
//        #10;
//        $display("Output is %b, %b, %b", S, E, F);
//        D = 12'b111111111111;
//        D = 12'b100000000000;
//        D = 12'b011111111111;
//        D = 12'b000000111111;
        $readmemb("test.code", testcase);
        for (i = 1; i <= testcase[0]; i = i+1) begin
            D = testcase[i];
            #10
            $display("D value is %b", D);
            #10
            $display("Output is %b, %b, %b", S, E, F);
        end

        
        #10000
        $finish;
	end
      
endmodule


