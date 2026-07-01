module dyn_array_find;
  int da[] = '{5, 10, 15, 20};

  function int find_index(input int arr[], input int val);
    foreach (arr[i]) begin
      if (arr[i] == val)
        return i;
    end
    return -1;
  endfunction

  initial begin
    int index = find_index(da, 15);
    $display("Found at index: %0d", index);
  end
endmodule
