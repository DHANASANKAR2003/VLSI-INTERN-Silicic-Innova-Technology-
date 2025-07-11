module enum_basics;
  typedef enum {RED = 2,GREEN = 3,BLUE} color_t;
  color_t my_color;
  
  initial begin
    my_color = GREEN;
    $display("Selected color %s = %0d",my_color.name(),my_color);
  end
endmodule
