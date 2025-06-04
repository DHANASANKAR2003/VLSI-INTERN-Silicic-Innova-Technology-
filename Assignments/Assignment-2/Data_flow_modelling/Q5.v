5. Write an RTL snippet to initialize all the locations of an array of size 10×8 to 0 at 0ns. 
(Depth = 10, Width = 8 bits). 

//Design code 
module init_array; 
    reg [7:0] memory [0:9]; // 10x8 array 
    integer i; 
  initial begin 
        for (i = 0; i < 10; i = i + 1) 
            memory[i] = 8'd0; // Initialize each location to 0 
    end 
Endmodule 

//Testbench code 
module tb_init_array; 
reg [7:0] memory [0:9]; 
integer i; 
initial begin 
    for (i = 0; i < 10; i = i + 1) 
        memory[i] = 8'd0; 
    #1; 
    $display("Array contents at 0ns:"); 
    for (i = 0; i < 10; i = i + 1) 
        $display("memory[%0d] = %b", i, memory[i]); 
end 
endmodule 
  
Output: 
Array contents at 0ns: 
memory[0] = 00000000 
memory[1] = 00000000 
memory[2] = 00000000 
memory[3] = 00000000 
memory[4] = 00000000 
memory[5] = 00000000 
memory[6] = 00000000 
memory[7] = 00000000 
memory[8] = 00000000 
memory[9] = 00000000 
