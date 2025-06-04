17. What is the output of following code? 

int alpha, beta; 
 
initial begin 
  alpha = 4; 
  beta = 3; 
 
  beta <= beta + alpha; 
  alpha <= alpha + beta; 
 
  alpha = alpha * 2; 
 
  $display("Alpha=%0d Beta=%0d", alpha, beta); 
end 

 

Output: 

Alpha=7 Beta=7 
