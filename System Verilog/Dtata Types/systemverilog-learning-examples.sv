// ====================================================
// 1. Basic String Comparison and Character Access
// ====================================================
module str_operations1;
  string a = "Hello world";
  string b = "Hello world";

  initial begin
    int i;
    if(a == b)
      $display("[str_operations1] a and b are Equal...");
    else
      $display("[str_operations1] Not Equal...");

    if(a != b)
      $display("[str_operations1] a and b are not Equal...");
    else
      $display("[str_operations1] Is Equal...");

    for(i = 0; i < 5; i++)
      $display("[str_operations1] a[%0d] = %c", i, a[i]);
  end
endmodule
// ====================================================
// 2. String Concatenation, Replication, Comparison
// ====================================================
module str_operations2;
  string a = "HELLO WORLD";
  string c = "Welcome to VLSI";
  string d = ".";
  string e = "w";
  string f = "com";

  initial begin 
    if(a > c)
      $display("[str_operations2] a is greater than c");
    else
      $display("[str_operations2] a is not greater than c");

    $display("[str_operations2] Concatenation: %s", {a, d, c});
    $display("[str_operations2] Replication: %s", {{3{e}}, d, f});
  end
endmodule
// ====================================================
// 3. Enum Without Typedef
// ====================================================
module enum_example1;
  enum {CARROT, BRINJAL, ONION, POTATO, TOMATO} veg_e;

  initial begin
    veg_e = ONION;
    $display("[enum_example1] Element: %s, Value: %0d", veg_e.name(), veg_e);
  end
endmodule
// ====================================================
// 4. Enum With Typedef
// ====================================================
module enum_example2;
  typedef enum {CARROT, BRINJAL, ONION, POTATO, TOMATO} veg_e;

  veg_e veg1, veg2, veg3;

  initial begin
    veg1 = ONION;
    veg2 = POTATO;
    veg3 = TOMATO;

    $display("[enum_example2] veg1 = %s (%0d)", veg1.name(), veg1);
    $display("[enum_example2] veg2 = %s (%0d)", veg2.name(), veg2);
    $display("[enum_example2] veg3 = %s (%0d)", veg3.name(), veg3);
  end
endmodule
// ====================================================
// 5. Typedef Enum Example
// ====================================================
module typedef_enum_example;
  typedef enum {RED, GREEN, BLUE} color_t;
  color_t signal_color;

  initial begin
    signal_color = GREEN;
    $display("[typedef_enum_example] Signal color = %s (%0d)", signal_color.name(), signal_color);
  end
endmodule
// ====================================================
// 6. Structure Without Typedef
// ====================================================
module struct_example;
  struct {
    int id;
    string name;
  } person;

  initial begin
    person.id = 1;
    person.name = "Dhana";
    $display("[struct_example] ID: %0d, Name: %s", person.id, person.name);
  end
endmodule
// ====================================================
// 7. Structure With Typedef
// ====================================================
module struct_typedef_example;
  typedef struct {
    int id;
    string name;
  } person_t;

  person_t student;

  initial begin
    student.id = 101;
    student.name = "Sankar";
    $display("[struct_typedef_example] Student ID: %0d, Name: %s", student.id, student.name);
  end
endmodule


