module enum_array;
  typedef enum {WINTER, SPRING, SUMMER, FALL} season_t;
  season_t favorite[2];

  initial begin
    favorite[0] = SUMMER;
    favorite[1] = WINTER;
    foreach(favorite[i])
      $display("Favorite[%0d]: %s", i, favorite[i].name());
  end
endmodule
