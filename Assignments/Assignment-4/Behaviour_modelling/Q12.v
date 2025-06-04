12. What will be the output of the following code and if it is wrong then what will be thecorrect code? 

Original Code  

begin 
    fork  
        begin 
            initial 
            for (bit[2:0] i=0;i<=3;i++) 
                $display($time, "value of i=%0d", i); 
        end 
 
        begin 
            #1; 
            $display("Executed 2nd begin block"); 
        end 
    join 
    $display("Fork Join Ended"); 
end 
Issues in the Code 

❗ initial inside fork...begin is invalid. 

initial blocks should be used at the module level. 

Inside a fork...join, you should just use begin...end or a named block. 

❗ Data type bit is a SystemVerilog type, not valid in pure Verilog. 

For Verilog, use reg or integer instead. 

If you're using SystemVerilog, ensure the simulator supports it. 

 Corrected Version  

module fork_example; 
  initial begin 
    fork 
      begin 
        int i; 
        for (i = 0; i <= 3; i++) 
          $display($time, " value of i = %0d", i); 
      end 
 
      begin 
        #1; 
        $display("Executed 2nd begin block"); 
      end 
    join 
    $display("Fork Join Ended"); 
  end 
endmodule 

Output 

0 value of i = 0 
0 value of i = 1 
0 value of i = 2 
0 value of i = 3 
1 Executed 2nd begin block 
1 Fork Join Ended\ 
