4. Find the value of the variable t at 1ns and 20ns respectively from the below snippet: 

time t; 
initial begin 
    #10 t = $time; 
    #20; 
end 

Answer: 

At 0ns: Simulation starts, but no assignment yet. 

At 10ns: t = $time; 
 ➤ $time returns current simulation time, which is 10ns. 
 ➤ So, t = 10. 

At 20ns: No further assignment occurs after this time. 

Final Values: 

At 1ns: t is still uninitialized (undefined or unknown). 

At 20ns: t = 10 (assigned at 10ns and unchanged after). 
