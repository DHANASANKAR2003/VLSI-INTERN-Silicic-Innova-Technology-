class person;
  string name;
  int age;
  
  function void show();
    $display("NAME = %s | AGE = %0d",name ,age);
  endfunction
endclass

module test1;
  initial begin
    person p;
    p = new();
    p.name = "DHANASANKAR K";
    p.age = 21;
    p.show();
  end
endmodule
    
