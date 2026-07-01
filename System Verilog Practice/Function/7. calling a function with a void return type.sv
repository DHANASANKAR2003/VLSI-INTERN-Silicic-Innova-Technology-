module func_return_void;
  initial begin
    display("I am DHANASANKAR..");
    display("I am pursuving Silicon craft VLASI..");
    display("I know veri well about Digital system, verilog and SV");
  end
  
  function void display(string str);
    $display("%s",str);
  endfunction
endmodule


output

I am DHANASANKAR..
I am pursuving Silicon craft VLASI..
I know veri well about Digital system, verilog and SV
