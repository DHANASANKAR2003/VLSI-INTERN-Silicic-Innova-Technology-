module enum_fsm;
  typedef enum{S0, S1, S2} state_t;
  state_t state = S0;
  
  logic clk;
  always #5clk = ~clk;
  
  always @(posedge clk) begin
    case(state)
      S0 : begin
        $display("Time %0t: State = S0 → Moving to S1",$time);
        state <= S1;
      end
      S1 : begin
        $display("Time %0t: State = S1 → Moving to S2",$time);
        state <= S2;
      end
      S2 : begin
        $display("Time %0t: State = S2 → Moving to S0",$time);
        state <= S0;
      end
    endcase
  end
  
  initial begin
    clk = 0;
    #100;
    $finish;
  end
endmodule

        
      
