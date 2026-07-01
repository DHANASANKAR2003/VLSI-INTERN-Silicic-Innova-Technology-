6. What will be the value of the parameter constant for the instance DUT in the top module from the below snippet? 

module test; 
    parameter WIDTH = 8; 
endmodule 
 
module top; 
    test #(16) OUT ( ); 
endmodule 

Answer: 
The module test defines a parameter WIDTH with a default value of 8. 
In the top module, the instance OUT of module test is created with a parameter override: #(16). 
This means that for this instance, the parameter WIDTH is explicitly set to 16, overriding the default value. 
Therefore, the value of the parameter WIDTH for the instance OUT is 16. 
