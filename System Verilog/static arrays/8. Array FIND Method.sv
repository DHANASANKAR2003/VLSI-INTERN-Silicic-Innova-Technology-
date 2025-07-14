module static_array_find;
  int arr[5] = '{5, 3, 8, 9, 2};
  int index = -1;

  initial begin
    foreach (arr[i]) begin
      if (arr[i] == 8) begin
        index = i;
        break;
      end
    end
    $display("Index of 8 in arr = %0d", index);
  end
endmodule
