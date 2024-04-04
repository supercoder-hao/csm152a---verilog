`timescale 1ns / 10ps

module memory(
    input clk_100M,
    input rst,
    input str,
    input [7:0] sw,
    input debug,
    input entr,
    input bld,
    output reg [3:0] an,
    output reg [6:0] seg,
    output reg [15:0] led,
    output wire out,
    output o_shutdown_n,
    output o_gain,
    output o_connect_n
    );
    
    assign	o_shutdown_n = 1'b1;
    assign  o_connect_n = 1'b1;
    assign  o_gain = 1'b1;
    
    
    reg [31:0] counter;
    reg [3:0] seconds;
    wire [14:0] random;
    
    wire chk1, chk2, db0;
    wire rst_clean;
    
    wire chk3, chk4, db1;
    wire str_clean;
    
    wire chk5, chk6, db2;
    wire entr_clean;
    
    wire chk7, chk8, db3;
    wire bld_clean;
        
    reg [31:0] pause_counter, pause_counter2;
    reg enable;
    reg enable1, enable2, enable3, enable4, enable5;
    reg [7:0] sound_sel;
    
    //////
    
    reg [2:0] level = 1;
    reg [7:0] sequence_1 = 0;
    reg [15:0] sequence_2 = 0;
    reg [23:0] sequence_3 = 0;
    reg [31:0] sequence_4 = 0;
    reg [39:0] sequence_5 = 0;
    
    reg [7:0] in_sw1 = 0;
    reg [15:0] in_sw2 = 0;
    reg [23:0] in_sw3 = 0;
    reg [31:0] in_sw4 = 0;
    reg [39:0] in_sw5 = 0;

    reg cleared1;
    
    reg [3:0] bld_cnt = 0;
    
    always@(posedge clk_100M) begin
        counter <= counter + 1;
        if (counter == 9999999)
            counter <= 0;
    end

    assign random = {counter[7]^counter[5], counter[6]^counter[4], counter[5]^counter[3], 
                     counter[4]^counter[2], counter[3]^counter[1], counter[2]^counter[0],
                     counter[5]^counter[3], counter[7]^counter[5], counter[6]^counter[4],
                     counter[7]^counter[4], counter[6]^counter[3], counter[5]^counter[2],
                     counter[4]^counter[1], counter[3]^counter[0], counter[2]^counter[7]};
    
    always @(posedge clk_100M) begin
        if (str_clean || rst_clean || regen) begin
            case(random[2:0])
                3'b000: sequence_1 <= 8'b00000001;
                3'b001: sequence_1 <= 8'b00000010;
                3'b010: sequence_1 <= 8'b00000100;
                3'b011: sequence_1 <= 8'b00001000;
                3'b100: sequence_1 <= 8'b00010000;
                3'b101: sequence_1 <= 8'b00100000;
                3'b110: sequence_1 <= 8'b01000000;
                3'b111: sequence_1 <= 8'b10000000;
            endcase
            
            case(random[5:3])
                3'b000: sequence_2 <= {sequence_1, 8'b00000001};
                3'b001: sequence_2 <= {sequence_1, 8'b00000010};
                3'b010: sequence_2 <= {sequence_1, 8'b00000100};
                3'b011: sequence_2 <= {sequence_1, 8'b00001000};
                3'b100: sequence_2 <= {sequence_1, 8'b00010000};
                3'b101: sequence_2 <= {sequence_1, 8'b00100000};
                3'b110: sequence_2 <= {sequence_1, 8'b01000000};
                3'b111: sequence_2 <= {sequence_1, 8'b10000000};
            endcase
            
            case(random[8:6])
                3'b000: sequence_3 <= {sequence_2, 8'b00000001};
                3'b001: sequence_3 <= {sequence_2, 8'b00000010};
                3'b010: sequence_3 <= {sequence_2, 8'b00000100};
                3'b011: sequence_3 <= {sequence_2, 8'b00001000};
                3'b100: sequence_3 <= {sequence_2, 8'b00010000};
                3'b101: sequence_3 <= {sequence_2, 8'b00100000};
                3'b110: sequence_3 <= {sequence_2, 8'b01000000};
                3'b111: sequence_3 <= {sequence_2, 8'b10000000};
            endcase
            
            case(random[11:9])
                3'b000: sequence_4 <= {sequence_3, 8'b00000001};
                3'b001: sequence_4 <= {sequence_3, 8'b00000010};
                3'b010: sequence_4 <= {sequence_3, 8'b00000100};
                3'b011: sequence_4 <= {sequence_3, 8'b00001000};
                3'b100: sequence_4 <= {sequence_3, 8'b00010000};
                3'b101: sequence_4 <= {sequence_3, 8'b00100000};
                3'b110: sequence_4 <= {sequence_3, 8'b01000000};
                3'b111: sequence_4 <= {sequence_3, 8'b10000000};
            endcase
            
            case(random[14:12])
                3'b000: sequence_5 <= {sequence_4, 8'b00000001};
                3'b001: sequence_5 <= {sequence_4, 8'b00000010};
                3'b010: sequence_5 <= {sequence_4, 8'b00000100};
                3'b011: sequence_5 <= {sequence_4, 8'b00001000};
                3'b100: sequence_5 <= {sequence_4, 8'b00010000};
                3'b101: sequence_5 <= {sequence_4, 8'b00100000};
                3'b110: sequence_5 <= {sequence_4, 8'b01000000};
                3'b111: sequence_5 <= {sequence_4, 8'b10000000};
            endcase   
        end
    end
    
    
    // generate sound and lights sequence based on level;
    reg stall;
    reg regen;
    
    reg win_counter;
    reg win_enable;
    always @(posedge clk_100M) begin
    
        case(level)
            3'b001: seg = 7'b1001111; // "1"     
            3'b010: seg = 7'b0010010; // "2" 
            3'b011: seg = 7'b0000110; // "3" 
            3'b100: seg = 7'b1001100; // "4" 
            3'b101: seg = 7'b0100100; // "5" 
            3'b110: seg = 7'b0100000; // "6" 
        endcase
        an <= 4'b1110;
    
        if (enable1 == 1) begin
            pause_counter <= pause_counter + 1;
            if (pause_counter == 59999994) begin
                pause_counter <= 0;
                enable <= 0;
                enable1 <= 0;
                led <= 16'b0;
            end
        end  
        
        if (enable2 == 1) begin
            pause_counter <= pause_counter + 1;
            if (pause_counter == 59999994) begin
                led <= sequence_2[7:0];
                sound_sel <= sequence_2[7:0];
                enable <= 1;
            end
           
            
            
            if (pause_counter == 119999988) begin
                pause_counter <= 0;
                enable <= 0;
                enable2 <= 0;
                led <= 16'b0;
            end
        end

        if (enable3 == 1) begin
            pause_counter <= pause_counter + 1;
            if (pause_counter == 59999994) begin
                led <= sequence_2[7:0];
                sound_sel <= sequence_2[7:0];
            end
            
            if (pause_counter == 119999988) begin
                led <= sequence_3[7:0];
                sound_sel <= sequence_3[7:0];
                enable <= 1;
            end
            
            if (pause_counter == 179999982) begin
                pause_counter <= 0;
                enable <= 0;
                enable3 <= 0;
                led <= 16'b0;
            end
                    
        end
        
        if (enable4 == 1) begin
            pause_counter <= pause_counter + 1;
            if (pause_counter == 59999994) begin
                led <= sequence_2[7:0];
                sound_sel <= sequence_2[7:0];
            end
            
            if (pause_counter == 119999988) begin
                led <= sequence_3[7:0];
                sound_sel <= sequence_3[7:0];
            end
            
            if (pause_counter == 179999982) begin
                led <= sequence_4[7:0];
                sound_sel <= sequence_4[7:0];
                enable <= 1;
            end
            
            if (pause_counter == 239999976) begin
                pause_counter <= 0;
                enable <= 0;
                enable4 <= 0;
                led <= 16'b0;
            end
        end
        
        
        
        if (enable5 == 1) begin
            pause_counter <= pause_counter + 1;
            if (pause_counter == 59999994) begin
                led <= sequence_2[7:0];
                sound_sel <= sequence_2[7:0];
            end
            
            if (pause_counter == 119999988) begin
                led <= sequence_3[7:0];
                sound_sel <= sequence_3[7:0];
            end
            
            if (pause_counter == 179999982) begin
                led <= sequence_4[7:0];
                sound_sel <= sequence_4[7:0];
            end
            
            if (pause_counter == 239999976) begin
                led <= sequence_5[7:0];
                sound_sel <= sequence_5[7:0];
                enable <= 1;
            end
            
            if (pause_counter == 299999970) begin
                pause_counter <= 0;
                enable <= 0;
                enable5 <= 0;
                led <= 16'b0;
            end
            
        end
        
        if (win_enable) begin
            win_counter <= win_counter + 1;
            if (win_counter == 119999988) begin
                win_counter <= 0;
                win_enable <= 0;
                led <= 16'b0;
                level <= 1;
            end
        end
        
        if (bld_clean) begin
            case(level)
            3'b001: in_sw1 <= sw;
            3'b010: bld_cnt <= bld_cnt + 1;
            3'b011: bld_cnt <= bld_cnt + 1;
            3'b100: bld_cnt <= bld_cnt + 1;
            3'b101: bld_cnt <= bld_cnt + 1;
            endcase

        end
    
        if (entr_clean || rst_clean) begin
            bld_cnt <= 1;
            case(level)
            3'b001: begin
                regen <= 0;
                if (!rst_clean) begin
                    sound_sel <= sequence_1;
                    led <= sequence_1;
                    enable <= 1;    
                    enable1 <= 1; 
                end         
                
                if (in_sw1 == sequence_1) begin
                    level <= level + 1;
                    stall <= 1;
                end 
                else begin
                    level <= 1;
                end

                
                if (rst_clean) begin
                    level <= 1;
                end
            end
            3'b010: begin
                if (!rst_clean) begin
                    sound_sel <= sequence_1;
                    led <= sequence_1;
                    enable <= 1;
                    enable2 <= 1;
                end
                
                if (in_sw2 == {sequence_2[7:0], sequence_1}) begin
                    level <= level + 1;
                end 
                
                if (rst_clean) begin
                    level <= 1;
                end
            end
            3'b011: begin
                if (!rst_clean) begin
                    sound_sel <= sequence_1;
                    led <= sequence_1;
                    enable <= 1;
                    enable3 <= 1;
                end
                
                if (in_sw3 == {sequence_3[7:0], sequence_2[7:0], sequence_1}) begin
                    level <= level + 1;
                end 

                if (rst_clean) begin
                    level <= 1;
                end
            end
            3'b100: begin
                if (!rst_clean) begin
                    sound_sel <= sequence_1;
                    led <= sequence_1;
                    enable <= 1;
                    enable4 <= 1;
                end
                
                if (in_sw4 == {sequence_4[7:0], sequence_3[7:0], sequence_2[7:0], sequence_1}) begin
                    level <= level + 1;
                end

                if (rst_clean) begin
                    level <= 1;
                end
            end
            3'b101: begin
                
                if (in_sw5 == {sequence_5[7:0], sequence_4[7:0], sequence_3[7:0], sequence_2[7:0], sequence_1}) begin
                    led <= 16'b1111111111111111;
                    win_enable <= 1;
                    
                    
                end
                else begin
                    sound_sel <= sequence_1;
                    led <= sequence_1;
                    enable <= 1;
                    enable5 <= 1;
                end
            end
            endcase
        end
    end
    
    // build sequence
    always@ (posedge clk_100M) begin
        case (bld_cnt)
            4'b0001: begin
                in_sw2[7:0] <= sw;
                in_sw3[7:0] <= sw;
                in_sw4[7:0] <= sw;
                in_sw5[7:0] <= sw;
            end
            4'b0011: begin
                in_sw2[15:8] <= sw;
                in_sw3[15:8] <= sw;
                in_sw4[15:8] <= sw;
                in_sw5[15:8] <= sw;
            end
            4'b0101: begin 
                in_sw3[23:16] <= sw;
                in_sw4[23:16] <= sw;
                in_sw5[23:16] <= sw;
            end
            4'b0111: begin
                in_sw4[31:24] <= sw;
                in_sw5[31:24] <= sw;
            end
            4'b1001: begin
                in_sw5[39:32] <= sw;
            end
        endcase 
    end

    
    delay_chk d0(clk_100M, counter, rst, db0);
    delay_chk d2(clk_100M, counter, db0, chk1);
    delay_chk d3(clk_100M, counter, chk1, chk2);
    assign rst_clean = chk1 & ~chk2;
    
    delay_chk d4(clk_100M, counter, str, db1);
    delay_chk d5(clk_100M, counter, db1, chk3);
    delay_chk d6(clk_100M, counter, chk3, chk4);
    assign str_clean = chk3 & ~chk4;    
    
    delay_chk d7(clk_100M, counter, entr, db2);
    delay_chk d8(clk_100M, counter, db2, chk5);
    delay_chk d9(clk_100M, counter, chk5, chk6);
    assign entr_clean = chk5 & ~chk6; 
    
    delay_chk d10(clk_100M, counter, bld, db3);
    delay_chk d11(clk_100M, counter, db3, chk7);
    delay_chk d12(clk_100M, counter, chk7, chk8);
    assign bld_clean = chk7 & ~chk8; 

    fpgaudio_oscillator fo0(clk_100M, sound_sel, enable , out);
    
endmodule


module delay_chk (input D_clock, slow_clk, D, output reg Q=0);
    always@(posedge D_clock) begin
        if (slow_clk == 1)
            Q <= D;
    end
endmodule

module fpgaudio_oscillator(
  input wire clk,
  input wire [7:0] sound_sel,
  input wire enable,
  output wire out
);
    reg [7:0] track;

    reg [7:0] midi;
    wire [6:0] small_midi;
    wire [31:0] cursor0;

    assign small_midi = midi[6:0];

    reg [383:0] octave;
    // midi lowest octave value frequency divider periods
    always@ (posedge clk) begin
        midi <= {track[cursor0+7],track[cursor0+6],track[cursor0+5],track[cursor0+4],track[cursor0+3],track[cursor0+2],track[cursor0+1],track[cursor0+0]};
        case(sound_sel)
        8'b00000001: begin
            // do low
            track <= 8'h40;
            octave <= 384'h00278bd90029e5d8002c63a3002f075a0031d3400034c9b80037ed49003b40a2003ec69c00428237004676a6004aa748;
        end
        8'b00000010: begin
            // re 
            track <= 8'h42;
            octave <= 384'h00278bd90029e5d8002c63a3002f075a0031d3400034c9b80037ed49003b40a2003ec69c00428237004676a6004aa748;
        end   
        8'b00000100: begin
            // mi 
            track <= 8'h44;
            octave <= 384'h00278bd90029e5d8002c63a3002f075a0031d3400034c9b80037ed49003b40a2003ec69c00428237004676a6004aa748;
        end     
        8'b00001000: begin
            // fa
            track <= 8'h46;
            octave <= 384'h00278bd90029e5d8002c63a3002f075a0031d3400034c9b80037ed49003b40a2003ec69c00428237004676a6004aa748;
        end
        8'b00010000: begin
            // so 
            track <= 8'h48;
            octave <= 384'h00278bd90029e5d8002c63a3002f075a0031d3400034c9b80037ed49003b40a2003ec69c00428237004676a6004aa748;
        end
        8'b00100000: begin
            // la
            track <= 8'h4A;
            octave <= 384'h00278bd90029e5d8002c63a3002f075a0031d3400034c9b80037ed49003b40a2003ec69c00428237004676a6004aa748;
        end 
        8'b01000000: begin
            // ti
            track <= 8'h4C;
            octave <= 384'h00278bd90029e5d8002c63a3002f075a0031d3400034c9b80037ed49003b40a2003ec69c00428237004676a6004aa748;
        end
        8'b10000000: begin
            //do high
            track <= 8'h4E;
            octave <= 384'h00278bd90029e5d8002c63a3002f075a0031d3400034c9b80037ed49003b40a2003ec69c00428237004676a6004aa748;
        end                                       
        endcase
    end
    
    wire [8:0] i = (small_midi % 12) << 5;
    wire [31:0] base_period = {octave[i+31],octave[i+30],octave[i+29],octave[i+28],octave[i+27],octave[i+26],octave[i+25],octave[i+24],octave[i+23],octave[i+22],octave[i+21],octave[i+20],octave[i+19],octave[i+18],octave[i+17],octave[i+16],octave[i+15],octave[i+14],octave[i+13],octave[i+12],octave[i+11],octave[i+10],octave[i+9],octave[i+8],octave[i+7],octave[i+6],octave[i+5],octave[i+4],octave[i+3],octave[i+2],octave[i+1],octave[i+0]};
    wire [31:0] period = base_period >> (small_midi / 12);
    wire [15:0] internal_out;
    fpgaudio_divider fd_midi(clk, period, internal_out);
    assign out = enable ? internal_out : 1'b0;
endmodule

module fpgaudio_divider(
  input wire clk,
  input wire [31:0] period_t,
  output reg dclk
);

integer t = 0;
always @(posedge clk) begin
  t = t + 1;
  if (t >= period_t) begin
    t = 0;
    dclk = ~dclk;
  end
end

endmodule