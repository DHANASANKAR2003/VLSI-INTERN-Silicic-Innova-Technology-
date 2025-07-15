class Scoreboard;
  int score[string];

  function void add_score(string name, int s);
    score[name] = s;
  endfunction

  function void show();
    foreach (score[n])
      $display("Player %s score = %0d", n, score[n]);
  endfunction
endclass

module assoc_array_class_test;
  initial begin
    Scoreboard sb = new();
    sb.add_score("Alice", 90);
    sb.add_score("Bob", 85);
    sb.show();
  end
endmodule
