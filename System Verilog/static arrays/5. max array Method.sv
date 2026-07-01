module static_array_max;
  int arr[5] = '{4, 16, 9, 33, 21};
  int max_val;

  initial begin
    max_val = arr[0];
    foreach (arr[i]) begin
      if (arr[i] > max_val)
        max_val = arr[i];
    end

    $display("Maximum value in static array = %0d", max_val);
  end
endmodule
