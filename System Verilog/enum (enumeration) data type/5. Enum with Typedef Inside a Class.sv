class packet;
  typedef enum {REQ, ACK, NACK} packet_type_t;
  packet_type_t packet_type;
  
  function void set(packet_type_t t);
    begin
      packet_type = t;
      $display("The packet set is %s", packet_type.name());
    end
  endfunction
endclass

module test;
  packet p;
  initial begin
    p = new();
    
    p.set(packet ::REQ);
    #5;
    p.set(packet ::ACK);
    #5;
    p.set(packet ::NACK);
  end
endmodule
