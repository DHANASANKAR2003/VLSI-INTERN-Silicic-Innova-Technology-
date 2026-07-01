3. Write RTL code to design a 3-bit SISO right shift register using only a Non-blocking assignment. (Do not use any operators). 

//Design code  
module shift_reg( input clk,rst,s_in, output reg s_out); 
reg [2:0]shift_r; 
always@(posedge clk or posedge rst)  
if(rst) begin  
shift_r[0] <= 1'b0;  
shift_r[1] <= 1'b0;  
shift_r[2] <= 1'b0;  
s_out <= 1'b0; end  
else  
begin  
shift_r[0] <= s_in;  
shift_r[1] <= shift_r[0];  
shift_r[2] <= shift_r[1];  
s_out <= shift_r[2];  
end endmodule 

//Testbench code  

module shift_reg_tb;  

reg clk,rst,s_in;  

wire s_out; 

shift_reg dut( .clk(clk), .rst(rst), .s_in(s_in), .s_out(s_out)); 

always #5 clk = ~clk; 

 initial begin 

   clk = 0; 
    rst = 1; 
    s_in = 0; 
 
    // Apply reset 
    #10; 
    rst = 0; 
    // Apply input serially 
    s_in = 1; #10; 
    s_in = 0; #10; 
    s_in = 1; #10; 
    s_in = 1; #10; 
    s_in = 0; #10; 
    s_in = 0; #10; 
 
    // Finish simulation 
    #20; 
    $finish; 
end 
initial begin 
    $monitor("Time = %0t | serial_in = %b | serial_out = %b", $time, s_in, s_out); 
end 
endmodule 
OUTPUT 

Time = 0 | serial_in = 0 | serial_out = 0 
Time = 10 | serial_in = 1 | serial_out = 0 
Time = 20 | serial_in = 0 | serial_out = 0 
Time = 30 | serial_in = 1 | serial_out = 0 
Time = 45 | serial_in = 1 | serial_out = 1 
Time = 50 | serial_in = 0 | serial_out = 1 
Time = 55 | serial_in = 0 | serial_out = 0 
Time = 65 | serial_in = 0 | serial_out = 1 
Time = 85 | serial_in = 0 | serial_out = 0 
testbench.sv:33: $finish called at 90 (1s) 
