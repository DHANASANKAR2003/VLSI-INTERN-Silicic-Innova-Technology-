class Table;
  static int arr[3] = '{10,20,30};
endclass
  
module test;
  initial begin
    foreach(Table::arr[i])
      $display("arr[%0d] = %0d",i,Table::arr[i]);
    end
endmodule
