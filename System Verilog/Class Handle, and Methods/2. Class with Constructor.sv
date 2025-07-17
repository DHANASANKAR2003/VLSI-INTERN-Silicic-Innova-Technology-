class student;
  string name;
  int id;
  
  function new(string n,int i);
    name = n;
    id = i;
  endfunction
  
  function void show();
    $display("NAME = %s | ID = %0d",name ,id);
  endfunction
  
endclass

module test1;
  initial begin
    student s = new("DHANASANKAR",101);
    s.show();
  end
endmodule
    
