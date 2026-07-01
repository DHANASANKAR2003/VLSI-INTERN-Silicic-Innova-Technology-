module twob_comp(
  input [1:0]a,b,
  output reg A_eq_B,A_ls_B,A_gt_B
);
  always@(*)
    if(a==b)
      begin
        A_eq_B = 1'b1;
        A_ls_B = 1'b0;
        A_gt_B = 1'b0;
      end
  else if(a<b)
    begin
      A_eq_B = 1'b0;
      A_ls_B = 1'b1;
      A_gt_B = 1'b0;
    end
  else if(a>b)
    begin
      A_eq_B = 1'b0;
      A_ls_B = 1'b0;
      A_gt_B = 1'b1;
    end
endmodule
    
      
module twob_comp_tb;
  reg [1:0]a,b;
  wire A_eq_B,A_ls_B,A_gt_B;
  
  twob_comp uut(a,b,A_eq_B,A_ls_B,A_gt_B);
  
  initial begin
    a = 2'b00; b = 2'b00;#10;
    a = 2'b01; b = 2'b11;#10;
    a = 2'b10; b = 2'b01;#10;
    a = 2'b11; b = 2'b11;#10;
  end
  initial begin
    $dumpfile("twob_comp.vcd");
    $dumpvars(1,twob_comp_tb);
  end
  initial begin
    $monitor("Time = %0t \t   A = %b B = %b A=B = %b A<B = %b A>B = %b",$time,a,b,A_eq_B,A_ls_B,A_gt_B);
  end
endmodule
