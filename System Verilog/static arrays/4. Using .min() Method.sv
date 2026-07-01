module static_array_min;
  int arr[5] = '{10, 20, 5, 40, 50};
  int min_val;

  initial begin
    min_val = arr[0];
    foreach (arr[i]) begin
      if (arr[i] < min_val)
        min_val = arr[i];
    end
    $display("Minimum value in static array = %0d", min_val);
  end
endmodule
