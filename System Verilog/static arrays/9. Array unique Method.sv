module static_array_unique;
  int arr[6] = '{1, 2, 2, 3, 4, 4};
  bit is_unique = 1;

  initial begin
    foreach (arr[i]) begin
      foreach (arr[j]) begin
        if (i != j && arr[i] == arr[j]) begin
          is_unique = 0;
          break;
        end
      end
      if (!is_unique)
        break;
    end

    if (!is_unique)
      $display("Array has duplicates");
    else
      $display("All elements are unique");
  end
endmodule

