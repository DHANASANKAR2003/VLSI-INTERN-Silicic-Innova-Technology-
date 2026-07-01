9. Write RTL code for designing a D latch using a 2:1 mux. 

module d_latch_mux ( 
    input wire D,       
    input wire En,     
    output wire Q      

); 
wire mux_out; 
assign mux_out = En ? D : Q; 
assign Q = mux_out; 
endmodule 

 

`timescale 1ns / 1ps 
module tb_d_latch_mux; 
reg D; 
reg En; 
wire Q; 
d_latch_mux uut ( 
    .D(D), 
    .En(En), 
    .Q(Q) 
); 
initial begin 
    D = 0; En = 0; 
    #10; 
    En = 1; D = 1; 
    #10; 
    D = 0; 
    #10;
        En = 0; 
    D = 1;    #20; 
    En = 1; 
    #10;    
   $finish; 
end 
initial begin 
    $monitor("Time=%0t : En=%b, D=%b, Q=%b", $time, En, D, Q); 
end 
endmodule 

OUTPUT 

Time=0 : En=0, D=0, Q=x 
Time=10000 : En=1, D=1, Q=1 
Time=20000 : En=1, D=0, Q=0 
Time=30000 : En=0, D=1, Q=0 
Time=50000 : En=1, D=1, Q=1 
testbench.sv:38: $finish called at 60000 (1ps) 
