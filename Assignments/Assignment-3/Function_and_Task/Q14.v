Explain and differentiate between automatic and non-automatic functions in Verilog coding . 

1. Non-Automatic Function (default in Verilog) 

Lifetime: Static (exists throughout simulation) 

Storage: Shared — variables declared in the function retain their value between calls 

Concurrency: Not reentrant (cannot be called from multiple places simultaneously without conflict) 

Usage: Good for simple, sequential logic 

Risk: 

If a non-automatic function is called in parallel (e.g., from multiple processes or threads), it may cause incorrect behavior due to shared memory. 

function [3:0] add_static; 
  input [3:0] a, b; 
  reg [3:0] temp; // Static by default 
  begin 
    temp = a + b; 
    add_static = temp; 
  end 
endfunction 

2. Automatic Function (declared with automatic) 

Lifetime: Dynamic — variables are created fresh for each function call 

Storage: Local to each call 

Concurrency: Reentrant and thread-safe (safe for fork-join, parallel processes) 

Usage: Preferred in testbenches, random stimulus generators, or recursive functions 

function automatic [3:0] add_auto; 
  input [3:0] a, b; 
  reg [3:0] temp; 
  begin 
    temp = a + b; 
    add_auto = temp; 
  end 
endfunction 

 
 
