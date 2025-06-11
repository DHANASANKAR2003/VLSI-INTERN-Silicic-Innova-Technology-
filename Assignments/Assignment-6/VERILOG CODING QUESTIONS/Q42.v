42. Implement a Fibonacci sequence generator using a shift-add technique.

//Design code
module fibonacci_shift_add (
    input wire clk,
    input wire rst,
    input wire start,
    input wire [3:0] count,           
    output reg [31:0] fib,            
    output reg done
);

    reg [31:0] a, b, temp;
    reg [3:0] i;
    reg running;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            a <= 0;
            b <= 1;
            i <= 0;
            fib <= 0;
            done <= 0;
            running <= 0;
        end else if (start && !running) begin
            a <= 0;
            b <= 1;
            i <= 0;
            done <= 0;
            running <= 1;
            fib <= 0;
        end else if (running) begin
            if (i < count) begin
                fib <= a;
                temp = a + b;
                a <= b;
                b <= temp;
                i <= i + 1;
            end else begin
                done <= 1;
                running <= 0;
            end
        end
    end
endmodule
//Testbench code
module tb_fibonacci_shift_add;
    reg clk = 0, rst = 0, start = 0;
  reg [3:0] count = 10;
    wire [31:0] fib;
    wire done;

    fibonacci_shift_add uut (
        
      .clk(clk), 
      .rst(rst), 
      .start(start), 
      .count(count), 
      .fib(fib), 
      .done(done)
    );
  

    always #5 clk = ~clk;

    initial begin
        $dumpfile("fibonacci.vcd");
        $dumpvars(0, tb_fibonacci_shift_add);

        rst = 1; #10;
        rst = 0;
        start = 1; #10;
        start = 0; #10;

        while (!done) begin
            #10;
            $display("Fibonacci: %0d", fib);
        end
        $finish;
    end
endmodule
OUTPUT
Fibonacci: 1
Fibonacci: 1
Fibonacci: 2
Fibonacci: 3
Fibonacci: 5
Fibonacci: 8
Fibonacci: 13
Fibonacci: 21
Fibonacci: 34
Fibonacci: 34
