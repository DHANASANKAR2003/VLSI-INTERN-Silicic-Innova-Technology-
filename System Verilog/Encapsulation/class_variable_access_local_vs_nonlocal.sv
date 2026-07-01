class packet;
  int i;
endclass

module example;
  initial begin
    packet p1 = new();
    p1.i = 10;
    $display("value of i = %0d",p1.i);
  end
endmodule

class packet;
  local int i;
endclass

module example;
  initial begin
    packet p1 = new();
    p1.i = 10;
    $display("value of i = %0d",p1.i);
  end
endmodule

| Feature        | Description                                         |
| -------------- | --------------------------------------------------- |
| `int i;`       | Public by default, accessible outside the class     |
| `local int i;` | Private to the class, cannot be accessed externally |
