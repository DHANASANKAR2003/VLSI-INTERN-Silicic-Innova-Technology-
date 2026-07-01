21. Consider the following Verilog code using dataflow modeling 

module Unknown (p,a,b,c);  

output p;  

input a,b,c;  

wire q,r;  

assign q=!((!a) && b && (!c)); 

assign r= !(a && (!b) && (!c));  

and G1(p,q,r);  

endmodule 

If c = 0 the Boolean expression for p would be 

A. NAND operation between variables a and b  

B. NOR operation between variables a and b  

C. XOR operation between variables a and b  

D. XNOR operation between variables a and b 

 

Answer: 

C. XOR operation between variables a and b 
