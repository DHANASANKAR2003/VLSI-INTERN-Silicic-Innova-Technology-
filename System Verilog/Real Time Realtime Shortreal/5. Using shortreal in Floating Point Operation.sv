module shortreal_operation;
  shortreal a = 5.5;
  shortreal b = 2.0;
  shortreal result;
  
  initial begin 
    result = a/b;
    $display("division operation (shortreal) = %f",result);
  end
endmodule 
