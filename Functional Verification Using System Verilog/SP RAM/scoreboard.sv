class scoreboard;
  mailbox m2s;
  event my_event;
  bit [7:0] model_mem[int];     
  int mem_size = 0;
  localparam int MEM_DEPTH = 16;

  function new(mailbox m2s);
    this.m2s = m2s;
  endfunction

  task main();
    repeat(15) begin
      transaction trans;
      m2s.get(trans);

      if (trans.en) begin  
        if (mem_size < MEM_DEPTH) begin
          if (model_mem.exists(trans.addr)) begin
            
            
            
            if (model_mem[trans.addr] === trans.din) begin
              $display("SCOREBOARD: WRITE PASS (Same Data) -> Addr: %0d | Data: %0d",trans.addr, trans.din);
            end 
            else begin
              $display("SCOREBOARD: WRITE FAIL (Overwrite) -> Addr: %0d | Old: %0d | New: %0d",trans.addr, model_mem[trans.addr], trans.din);
            end
          end 
          
          
          else begin      
            $display("SCOREBOARD: WRITE PASS (New Entry) -> Addr: %0d | Data: %0d",trans.addr, trans.din);
            mem_size++;
          end
          model_mem[trans.addr] = trans.din;
        end 
        
        
        else begin
          $display("SCOREBOARD: WRITE FAIL -> MEMORY FULL! Addr: %0d | Data: %0d",trans.addr, trans.din);
        end
      end 
      
      
      else begin  
        if (model_mem.exists(trans.addr)) begin
          if (trans.dout === model_mem[trans.addr]) begin
            $display("SCOREBOARD: READ PASS -> Addr: %0d | Expected: %0d | DATA OUT: %0d",trans.addr, model_mem[trans.addr], trans.dout);
          end 
          
          
          else begin
            $display("SCOREBOARD: READ FAIL -> Addr: %0d | Expected: %0d | DATA OUT: %0d",trans.addr, model_mem[trans.addr], trans.dout);
          end
        end 
        
        
        else begin
          $display("SCOREBOARD: READ FAIL -> Addr: %0d | No Data Written Yet", trans.addr);
        end
      end
      
      
      $display("==================================TRANSACTION DONE===============================");
      $display("=================================================================================");
      ->my_event;
    end
  endtask
endclass
