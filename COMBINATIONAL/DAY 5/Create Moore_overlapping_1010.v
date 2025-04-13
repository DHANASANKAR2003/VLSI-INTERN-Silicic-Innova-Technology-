
//Design code
module moore(
  input x,rst,clk,
  output reg z);
  
  parameter A = 4'b000;
  parameter B = 4'b001;
  parameter C = 4'b010;
  parameter D = 4'b011;
  parameter E = 4'b100;
  reg [2:0]state,n_state;
  
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
          n_state <= E;
        else
          n_state <= B;
      end
      E:begin
        if(x==0)
          n_state <= A;
        else
          n_state <= D;
      end
      default: n_state <= A;
    endcase
  end
  
  always@(*) begin
    case(state)
      A:z = 0;
      B:z = 0;
      C:z = 0;
      D:z = 0;
      E:z = 1;
      default:z = 0;
    endcase
  end
endmodule

      
      
          
// Testbench code

module moore_tb;
  reg x,rst,clk;
  wire z;
  
  moore uut(x,rst,clk,z);
  
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
    $dumpfile("moore.vcd");
    $dumpvars(1,moore_tb);
  end
  initial begin
    $monitor("Time = %0t \t CLK = %b RST = %b INPUT = %b OUTPUT = %b",$time,clk,rst,x,z);
  end
endmodule
    
  
