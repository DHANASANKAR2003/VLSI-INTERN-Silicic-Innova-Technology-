class packet;
  local int i;
  
  function void display(int a);
    i = a;
    $display("value of i = %0d",i);
  endfunction
endclass

module class_example;
  initial begin
    packet p1 = new();
    p1.display(10);
  end
endmodule 


class packet;
  local int i;
endclass

class child_packet extends packet;
  function void display(int a);
    i = a;
    $display("value of i = %0d",i);
  endfunction
endclass

module class_example;
  initial begin
    child_packet c1 = new();
    c1.display(10);
  end
endmodule 

| Feature                     | Description                                          |
| --------------------------- | ---------------------------------------------------- |
| `local int i;`              | A variable accessible **only within the same class** |
| **Subclass access fails**   | `child_packet` cannot access `local i` from `packet` |
| **Same-class access works** | `display()` in `packet` can access its own `local i` |
