7. What is the bug in the following snippet? 

module test; 
    parameter WIDTH = 8; 
endmodule 
 
module top; 
    test OUT (); 
    initial 
        defparam OUT.WIDTH = 10; 
endmodule 
 

Answer: 

module top; 

    test #(10) OUT (); 

endmodule 
