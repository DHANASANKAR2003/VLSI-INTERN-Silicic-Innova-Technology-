// Code your design 
module ram(
    input clk,
    input write_enable,
    input [9:0]address,
    input [7:0]data_in,
    output reg [7:0]data_out
);

reg [7:0]ram_block[0:1023];

always @(posedge clk) begin
        if(write_enable)
            ram_block[address] <= data_in;
        else
            data_out <= ram_block[address];
end

endmodule

// Code your testbench here

module ram_tb;

reg clk;
reg write_enable;
reg [9:0]address;
reg [7:0]data_in;
wire [7:0]data_out;

ram uut(clk,write_enable,address,data_in,data_out);
initial begin
  $monitor("Time = %0t \t CLK = %b WRITE ENABLE = %h ADDRESS = %d DATA IN = %h DATA OUT = %h",$time,clk,write_enable,address,data_in,data_out);
end
initial begin
  $dumpfile("ram_tb.vcd");
  $dumpvars(0 , ram_tb);
end
initial begin
clk = 0;
write_enable = 0;address = 55;#20;
write_enable = 1;data_in = 8'h56;address = 55;#20;
write_enable = 0;address = 55;#20;
write_enable = 1;data_in = 8'h36;address = 55;#20; 
write_enable = 0;address = 55;#20;

$finish();

end
  



always #10 clk = ~clk;  //clock generation

endmodule
