class scoreboard;
  mailbox mon2scb;
  event my_event;
  bit [7:0] fifo_model[$]; 

  function new(mailbox mon2scb);
    this.mon2scb = mon2scb;
  endfunction
  
  task main();
    transaction trans;
    repeat (10) begin  
      mon2scb.get(trans);

      if (trans.wr_en && !trans.full)
        fifo_model.push_back(trans.din);

      if (trans.rd_en && !trans.empty) begin
        bit [7:0] expected_dout = fifo_model.pop_front();

        if (trans.dout === expected_dout)
          $display("Scoreboard: PASS -> DOUT matched: %0d", expected_dout);
        else
          $display("Expected DOUT = %0d | Observed DOUT = %0d", expected_dout, trans.dout);
      end

      $display("==============TRANSACTION DONE==============\n");
      ->my_event;
    end
  endtask
endclass

