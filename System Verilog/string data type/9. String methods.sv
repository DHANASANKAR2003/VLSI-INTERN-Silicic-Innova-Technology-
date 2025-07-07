module string_methods_test;

  string s = "SystemVerilog";
  string result;
  int index;

  initial begin
    // 1. Length
    $display("Length: %0d", s.len());

    // 2. To Uppercase
    result = s.toupper();
    $display("Upper: %s", result);

    // 3. To Lowercase
    result = s.tolower();
    $display("Lower: %s", result);

    // 4. Substring
    result = s.substr(0, 5);
    $display("Substring (0–5): %s", result);

    // 5. Compare
    string a = "Verilog", b = "verilog";
    int cmp = a.compare(b);
    $display("Compare '%s' vs '%s': %0d", a, b, cmp);

    // 6. Find
    index = s.find("Veri");
    $display("Find 'Veri': Index = %0d", index);

    // 7. Character at Index
    $display("Char at index 3: %s", s.getc(3));

    // 8. Replace character using putc()
    s.putc(0, "X");
    $display("After putc(0, 'X'): %s", s);

    // 9. String to int (atoi)
    string num = "1234";
    int value = num.atoi();
    $display("String to int: %0d", value);

    // 10. Int to string (itoa)
    string converted = string::itoa(value + 66);
    $display("Int to string: %s", converted);
  end

endmodule
