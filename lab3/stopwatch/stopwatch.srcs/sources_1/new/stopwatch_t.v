`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/13/2024 12:24:45 PM
// Design Name: 
// Module Name: stopwatch_t
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


module stopwatch_t(
    input clk_100M,// 100 megahz aka 100 million hz,
    input rst,
    input pause,
    input [1:0] sw,
    output reg [3:0] an,
    output reg [6:0] seg
    );
    
    wire [1:0] an_activation;
    wire [1:0] blink_control;
//    reg [19:0] an_refreshrate;
    reg [29:0] an_refreshrate;
    
    reg [26:0] clk_100M_counter;
    
    // time counters
    reg [3:0] seconds_counter;
    reg [3:0] tens_counter;
    reg [3:0] minutes_counter;
    reg [3:0] tens_minutes_counter;
        
    reg [3:0] sevseg_number; // digit 0-9 that we want to throw on display
    
    wire debounce_clock;
    wire chk1, chk2, db0;
    wire rst_clean;
    
    wire pause_clean;
    reg current_pause = 0;
    wire chk3, chk4, db1;
    
    reg [26:0] clk_100M_counter_fast;
    
    // clock for updating display values (really fast)
    always@(posedge clk_100M) begin 
        an_refreshrate <= an_refreshrate + 1;
    end
    assign an_activation = an_refreshrate[19:18];
    assign blink_control = an_refreshrate[23:22];
    
//    always@(posedge rst_clean) begin
//        seconds_counter <= 0;
//        tens_counter <= 0;
//        minutes_counter <= 0;
//        tens_minutes_counter <= 0;
//    end
    
    // clock for counting seconds for stopwatch
    always@(posedge clk_100M) begin
        
        if (pause_clean)
            current_pause = ~current_pause;
    
        if (rst_clean) begin
            seconds_counter <= 0;
            tens_counter <= 0;
            minutes_counter <= 0;
            tens_minutes_counter <= 0;
        end
    
        if (!current_pause) begin
            clk_100M_counter <= clk_100M_counter + 1;
            
            case(sw)
                2'b11 : begin
                    //seconds speedup, pause minutes
                    if (clk_100M_counter == 9999999) begin
                        seconds_counter <= seconds_counter +1;
                        clk_100M_counter <= 0; // reset the counter so we can count 1 second again
                        if (seconds_counter == 9) begin // if 10 seconds, increment 10s digit
                            tens_counter <= tens_counter + 1;
                            seconds_counter <= 0;
                            
                            if (tens_counter == 5) begin
                                // RESET
                                seconds_counter <= 0;
                                tens_counter <= 0;
                            end    

                        end
                    end
                end
                2'b01 : begin
                    //minutes speedup, pause seconds
                    if (clk_100M_counter == 9999999) begin
                        minutes_counter <= minutes_counter + 1;
                        clk_100M_counter <= 0;
                        if (minutes_counter == 9) begin
                            tens_minutes_counter <= tens_minutes_counter + 1;
                            minutes_counter <= 0;
                            
                            if (tens_minutes_counter == 5) begin
                                minutes_counter <= 0;
                                tens_minutes_counter <= 0;
                            end
                        
                        end  
                    end
                
                end
                default : begin
                    if (clk_100M_counter == 99999999) begin
                        seconds_counter <= seconds_counter +1;
                        clk_100M_counter <= 0; // reset the counter so we can count 1 second again
                        if (seconds_counter == 9) begin // if 10 seconds, increment 10s digit
                            tens_counter <= tens_counter + 1;
                            seconds_counter <= 0;
                            if (tens_counter == 5) begin // if 60 seconds, increment minutes digit
                                minutes_counter <= minutes_counter + 1;
                                tens_counter <= 0;
                                seconds_counter <= 0;
                                if (minutes_counter == 9) begin // if 10 seconds, increment 10s minutes digit
                                    tens_minutes_counter <= tens_minutes_counter + 1;
                                    minutes_counter <= 0;
                                    if (tens_minutes_counter == 5) begin
                                        // RESET
                                        seconds_counter <= 0;
                                        tens_counter <= 0;
                                        minutes_counter <= 0;
                                        tens_minutes_counter <= 0;
                                    end    
                                end
                            end
                        end
                    end
                end
            endcase
            
       
        end
    end
    
    
//    always @(posedge rst_clean) begin
//        seconds_counter <= 0;
//        tens_counter <= 0;
//        minutes_counter <= 0;
//        tens_minutes_counter <= 0;
//    end
    
    //
    
    // refresh display. iterate thru all 4 digits and make needed changes
    
    always@(*) begin
        case (sw)
            2'b11 : begin
                //seconds speedup, pause minutes
                case(blink_control)
                    2'b00: begin
                        an = 4'b0111;
                        sevseg_number = seconds_counter;
                    end
                    2'b01: begin
                        an = 4'b1011;
                        sevseg_number = tens_counter;
                    end
                endcase
                case(an_activation)
                    2'b10: begin
                        an = 4'b1101;
                        sevseg_number = minutes_counter;
                    end
                    2'b11: begin
                        an = 4'b1110;
                        sevseg_number = tens_minutes_counter;
                    end
                endcase
                
                
            end
            2'b01 : begin
                //minutes speedup, pause seconds
                case(blink_control)
                    2'b10: begin
                        an = 4'b1101;
                        sevseg_number = minutes_counter;
                    end
                    2'b11: begin
                        an = 4'b1110;
                        sevseg_number = tens_minutes_counter;
                    end
                endcase
                case(an_activation)
                    2'b00: begin
                        an = 4'b0111;
                        sevseg_number = seconds_counter;
                    end
                    2'b01: begin
                        an = 4'b1011;
                        sevseg_number = tens_counter;
                    end
                endcase
            
            end
            default : begin
                case(an_activation)
                    2'b00: begin
                        an = 4'b0111;
                        sevseg_number = seconds_counter;
                    end
                    2'b01: begin
                        an = 4'b1011;
                        sevseg_number = tens_counter;
                    end
                    2'b10: begin
                        an = 4'b1101;
                        sevseg_number = minutes_counter;
        
                    end
                    2'b11: begin
                        an = 4'b1110;
                        sevseg_number = tens_minutes_counter;
        
                    end
                endcase
            end
        endcase
 
    end
    
    
    always@(*) begin
        case(sevseg_number)
            4'b0000: seg = 7'b0000001; // "0"     
            4'b0001: seg = 7'b1001111; // "1" 
            4'b0010: seg = 7'b0010010; // "2" 
            4'b0011: seg = 7'b0000110; // "3" 
            4'b0100: seg = 7'b1001100; // "4" 
            4'b0101: seg = 7'b0100100; // "5" 
            4'b0110: seg = 7'b0100000; // "6" 
            4'b0111: seg = 7'b0001111; // "7" 
            4'b1000: seg = 7'b0000000; // "8"     
            4'b1001: seg = 7'b0000100; // "9" 
            default: seg = 7'b0000001; // "0" 
        endcase
    end
    
    // debounce encoding
//    assign debounce_clock = (clk_100M_counter == 1) ? 1'b1:1'b0;
//    249999
    
    // debounce
    delay_chk d0(clk_100M, clk_100M_counter, rst, db0);
    delay_chk d1(clk_100M, clk_100M_counter, pause, db1);
    
    // metastablilty
    delay_chk d2(clk_100M, clk_100M_counter, db0, chk1);
    delay_chk d3(clk_100M, clk_100M_counter, chk1, chk2);
    
    delay_chk d4(clk_100M, clk_100M_counter, db1, chk3);
    delay_chk d5(clk_100M, clk_100M_counter, chk3, chk4);
    
    // output clean signal
    assign rst_clean = chk1 & ~chk2;
    
    assign pause_clean = chk3 & ~chk4;
    
//    always@(posedge pause_clean) begin
//        current_pause = ~current_pause;
//    end
    

endmodule

module delay_chk (input D_clock, slow_clk, D, output reg Q=0);
    always@(posedge D_clock) begin
        if (slow_clk == 1)
            Q <= D;
    end
endmodule
