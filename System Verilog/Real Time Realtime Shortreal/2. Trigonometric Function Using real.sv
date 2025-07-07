module real_trigonometry;
  real angle = 3.14159/4;
  
  initial begin
    $display("angle(cos(45)) = %f",$cos(angle));
    $display("angle(sin(45)) = %f",$sin(angle));
  end
endmodule 
