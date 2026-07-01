class Message;
  string content;
endclass

module producer(output Message m);
  initial begin
    m = new();                                 
    m.content = "Hello from producer";
  end
endmodule

module consumer(input Message m);
  initial begin
    #5;
    $display("Received: %s", m.content);       
  end
endmodule

module top;
  Message m;
  producer p(.m(m));                           
  consumer c(.m(m));
endmodule
