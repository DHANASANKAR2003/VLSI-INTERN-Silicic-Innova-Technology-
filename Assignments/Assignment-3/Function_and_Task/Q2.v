2. Write a Verilog code to perform the sum of two numbers using a function. 
//Design Code  
module add_two_numbers( input [7:0]a,b, output [7:0]result );  
assign result = function_two_numbers(a,b); 
function [7:0]function_two_numbers;  
input[7:0]a,b;
 begin function_two_numbers = a + b;  
end  
endfunction  
endmodule 
 
//Testbench code  
module add_two_numbers_tb; 
reg [7:0]a,b;  
wire [7:0]result; 
add_two_numbers uut( .a(a), .b(b), .result(result) ); 
initial begin  
a = 8'd10; b = 8'd11;#10;  
$display("a = %0d,\tb = %0d, result = %0d", a, b, result);  
a = 8'd8; b = 8'd11;#10;  
$display("a = %0d,\tb = %0d, result = %0d", a, b, result);  
a = 8'd15; b = 8'd16;#10;  
$display("a = %0d,\tb = %0d, result = %0d", a, b, result);  
a = 8'd1; b = 8'd5;#10;  
$display("a = %0d,\tb = %0d,\tresult = %0d", a, b, result); 
end endmodule 
//OUTPUT 
a = 10,	b = 11,  result = 21 
a = 8,	       b = 11,  result = 19 
a = 15,	b = 16,  result = 31 
a = 1,	       b = 5,	  result = 6 

 
