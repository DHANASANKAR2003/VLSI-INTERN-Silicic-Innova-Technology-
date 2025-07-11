module enum_mixed;
  typedef enum bit [7:0]{
    
    ONE = 8'd1, TWO = 8'd3, THREE = 8'd4, FOUR = 8'd6, FIVE = 8'd7, SIX = 8'd8, SEVEN, EIGHT}count_t;
  
  count_t c1,c2,c3,c4,c5,c6,c7,c8;
  
  initial begin
    c1 = ONE;
    c2 = TWO;
    c3 = THREE;
    c4 = FOUR;
    c5 = FIVE;
    c6 = SIX;
    c7 = SEVEN;
    c8 = EIGHT;
    $display("Enum value: %s = %0d", c1.name(), c1);
    $display("Enum value: %s = %0d", c2.name(), c2);
    $display("Enum value: %s = %0d", c3.name(), c3);
    $display("Enum value: %s = %0d", c4.name(), c4);
    $display("Enum value: %s = %0d", c5.name(), c5);
    $display("Enum value: %s = %0d", c6.name(), c6);
    $display("Enum value: %s = %0d", c7.name(), c7);
    $display("Enum value: %s = %0d", c8.name(), c8);
  end
endmodule
    
