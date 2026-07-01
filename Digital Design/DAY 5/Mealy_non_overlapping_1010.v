
//Design code
module mealy(
  input x,rst,clk,
  output reg z);
  
  parameter A = 4'b0000;
  parameter B = 4'b0001;
  parameter C = 4'b0010;
  parameter D = 4'b0011;
  
  reg [3:0]state,n_state;
  
  always@(posedge clk or posedge rst) begin
    if(rst)
      state <= A;
    else
      state <= n_state;
  end
  always@(state or x)begin
    case(state)
      A:begin
        if(x==0)
          n_state <= A;
        else
          n_state <= B;
      end
      B:begin
        if(x==0)
          n_state <= C;
        else
          n_state <= B;
      end
      C:begin
        if(x==0)
          n_state <= A;
        else
          n_state <= D;
      end
      D:begin
        if(x==0)
          n_state <= A;
        else
          n_state <= B;
      end
      default: n_state <= A;
    endcase
  end
  
  always@(*) begin
    if((state == D) && (x == 0))
      z = 1;
    else
      z = 0;
  end
endmodule

      
      
          
// Testbench code

module mealy_tb;
  reg x,rst,clk;
  wire z;
  
  mealy uut(x,rst,clk,z);
  
  initial begin
    clk = 0;
    forever #5clk = ~clk;
  end
  initial begin
    rst = 1; 
    x = 1;#10; 
    x = 0;#10;
    x = 1;#10;
    x = 0;#10;
    rst = 0;#10;
    x = 1;#10;
    x = 1;#10;
    x = 0;#10;
    x = 1;#10;
    x = 0;#10;
    x = 0;#10;
    x = 1;#10;
    x = 0;#10;
    x = 1;#10;
    x = 0;#10;
    x = 0;#10;
    
    $finish;
  end
  initial begin
    $dumpfile("mealy.vcd");
    $dumpvars(1,mealy_tb);
  end
  initial begin
    $monitor("Time = %0t \t CLK = %b RST = %b INPUT = %b OUTPUT = %b",$time,clk,rst,x,z);
  end
endmodule
    
  
