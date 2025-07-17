class node;
  int value;
endclass

module test1;
  node n[6];
  
  initial begin
    foreach(n[i]) begin
      n[i] = new();
      n[i].value = i * 10;
      $display("node[%0d] = %0d",i,n[i].value);
    end
  end
endmodule
    
