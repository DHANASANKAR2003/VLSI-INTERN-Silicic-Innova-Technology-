class Engine;
  function void start();                       
    $display("Engine started!");
  endfunction
endclass

class Vehicle;
  Engine e;                                    

  function void run();                         
    e = new();                                 
    e.start();                                 
  endfunction
endclass

module test10;
  initial begin
    Vehicle v = new();                         
    v.run();                                   
  end
endmodule
