1. What is the value of y in binary format in the below snippet?

reg [5:0] y;
initial
begin
y= 'Ox2;
end

This seems to be a typo. In Verilog, the correct way to assign a hexadecimal value is:
  y = 6'h2;
'Ox2 = 'h2 = Hex value 2

Final Answer:
Binary value of y = 000010
