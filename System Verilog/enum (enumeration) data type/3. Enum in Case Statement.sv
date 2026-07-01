module enum_case;
  typedef enum {IDLE, START, STOP} state_t;
  state_t state;

  initial begin
    state = IDLE;
    case (state)
      IDLE:  $display("Time %0t: system is idle", $time);
      START: $display("Time %0t: system is start", $time);
      STOP:  $display("Time %0t: system is stop",  $time);
    endcase
    #10;

    state = START;
    case (state)
      IDLE:  $display("Time %0t: system is idle", $time);
      START: $display("Time %0t: system is start", $time);
      STOP:  $display("Time %0t: system is stop",  $time);
    endcase
    #10;

    state = STOP;
    case (state)
      IDLE:  $display("Time %0t: system is idle", $time);
      START: $display("Time %0t: system is start", $time);
      STOP:  $display("Time %0t: system is stop",  $time);
    endcase
  end
endmodule
