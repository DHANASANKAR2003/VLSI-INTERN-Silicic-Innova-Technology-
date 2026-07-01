class transaction;
  rand bit en;                   
  rand bit [3:0] addr;           
  rand bit [7:0] din;            
       bit [7:0] dout;           

  
  constraint write_addr_range {
    if (en) {
      
      addr inside {[0:4]};
    } else {
      
      addr inside {[0:3]};
    }
  }

  function void display(string name);
    $display("  \t %s....", name);
    $display("  \t ---------------------------");
    $display("||\t TIME = %0t | ENABLE = %0d | ADDRESS = %0d | DATA IN = %0d | DATA OUT = %0d \t||",$time, en, addr, din, dout);
  endfunction
endclass
