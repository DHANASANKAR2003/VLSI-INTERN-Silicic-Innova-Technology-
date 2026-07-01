//condition?true_expression:false_expression
module conditional_code;

int c,d;
string y;
string a,b;
initial begin

  a = "true";
  b = "false";
  
  c = 4'b1001;
  d = 4'b0011;

  $display("\n \t the value of c is %0b",c);

  $display("\n \t the value of d is %0b",d);


  y=c>d?a:b;
  $display("\n \t the conditional output is %s",y);
  $display("\n \t Because the c value is lessthan d values");
end
endmodule 

OUTPUT

the value of c is 1001

 	 the value of d is 11

 	 the conditional output is true
