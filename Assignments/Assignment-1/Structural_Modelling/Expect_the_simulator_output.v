19. What do you expect the simulator output in this example

module tb_top;
wire w1;
xmit xmit_i1(w1);
rcv rcv_i1 (w1);
endmodule

module xmit (output reg w);
Initial w=1;
endmodule
module rcv (input wire w);
initial begin
$display ("w value is ");
$display(w);
end
endmodule

Corrected code

module tb_top;
wire w1;
xmit xmit_i1(w1);
rcv rcv_i1 (w1);
endmodule

module xmit (output reg w);
Initial w=1;
endmodule
module rcv (input wire w);
initial begin
    #1; // Delay to let xmit drive the wire
    $display ("w value is %b", w);
end

endmodule
