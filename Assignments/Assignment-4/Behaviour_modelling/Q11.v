11. For the below RTL schematic write the RTL snippet 
 

module rtl_snippet ( 
    input wire clk, 
    input wire x1, 
    input wire x2, 
    input wire x3, 
    output reg f, 
    output reg g 
); 
    always @(posedge clk) begin 
        f <= x1 & x2; 
        g <= x3 | f; 
    end 
 
endmodule 

Testbench  

`timescale 1ns / 1ps 
module rtl_snippet_tb; 
    reg clk; 
    reg x1, x2, x3; 
    wire f, g; 
    rtl_snippet uut ( 
        .clk(clk), 
        .x1(x1), 
        .x2(x2), 
        .x3(x3), 
        .f(f), 
        .g(g) 
    ); 
    initial begin 
        clk = 0; 
        forever #5 clk = ~clk;  
    end 
    initial begin 
        $monitor("Time=%0t | x1=%b x2=%b x3=%b | f=%b g=%b", $time, x1, x2, x3, f, g); 
        x1 = 0; x2 = 0; x3 = 0; 
        #10; 
        x1 = 1; x2 = 0; x3 = 1; #10; 
        x1 = 1; x2 = 1; x3 = 0; #10; 
        x1 = 0; x2 = 1; x3 = 1; #10; 
        x1 = 1; x2 = 1; x3 = 1; #10; 
        x1 = 0; x2 = 0; x3 = 0; #10; 
        $finish; 
    end 
endmodule 

OUTPUT 

Time=0 | x1=0 x2=0 x3=0 | f=x g=x 
Time=5000 | x1=0 x2=0 x3=0 | f=0 g=x 
Time=10000 | x1=1 x2=0 x3=1 | f=0 g=x 
Time=15000 | x1=1 x2=0 x3=1 | f=0 g=1 
Time=20000 | x1=1 x2=1 x3=0 | f=0 g=1 
Time=25000 | x1=1 x2=1 x3=0 | f=1 g=0 
Time=30000 | x1=0 x2=1 x3=1 | f=1 g=0 
Time=35000 | x1=0 x2=1 x3=1 | f=0 g=1 
Time=40000 | x1=1 x2=1 x3=1 | f=0 g=1 
Time=45000 | x1=1 x2=1 x3=1 | f=1 g=1 
Time=50000 | x1=0 x2=0 x3=0 | f=1 g=1 
Time=55000 | x1=0 x2=0 x3=0 | f=0 g=1 
testbench.sv:42: $finish called at 60000 (1ps) 
