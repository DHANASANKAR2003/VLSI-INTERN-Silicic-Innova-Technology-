12. Write Verilog code to generate odd or even numbers using a function. 

module odd_even_generator; 
  integer i; 
  reg select_even; // 1 = even, 0 = odd 
  reg [7:0] num; 
  // Function to generate odd or even number 
  function [7:0] generate_number; 
    input integer index; 
    input bit even; // 1 = even, 0 = odd 
    begin 
      generate_number = even ? (index * 2) : (index * 2 + 1); 
    end 
  endfunction 
  initial begin 
    // Generate EVEN numbers 
    select_even = 1; 
    $display("Even numbers:"); 
    for (i = 0; i < 20; i = i + 1) begin 
      num = generate_number(i, select_even); 
      $display("Number %0d = %0d", i, num); 
    end 
    // Generate ODD numbers 
    select_even = 0; 
    $display("\nOdd numbers:"); 
    for (i = 0; i < 20; i = i + 1) begin 
      num = generate_number(i, select_even); 
      $display("Number %0d = %0d", i, num); 
    end 
  end 
endmodule 
 

OUTPUT 

Even numbers: 
Number 0 = 0 
Number 1 = 2 
Number 2 = 4 
Number 3 = 6 
Number 4 = 8 
Number 5 = 10 
Number 6 = 12 
Number 7 = 14 
Number 8 = 16 
Number 9 = 18 
Number 10 = 20 
Number 11 = 22 
Number 12 = 24 
Number 13 = 26 
Number 14 = 28 
Number 15 = 30 
Number 16 = 32 
Number 17 = 34 
Number 18 = 36 
Number 19 = 38 
 
Odd numbers: 
Number 0 = 1 
Number 1 = 3 
Number 2 = 5 
Number 3 = 7 
Number 4 = 9 
Number 5 = 11 
Number 6 = 13 
Number 7 = 15 
Number 8 = 17 
Number 9 = 19 
Number 10 = 21 
Number 11 = 23 
Number 12 = 25 
Number 13 = 27 
Number 14 = 29 
Number 15 = 31 
Number 16 = 33 
Number 17 = 35 
Number 18 = 37 
Number 19 = 39 
