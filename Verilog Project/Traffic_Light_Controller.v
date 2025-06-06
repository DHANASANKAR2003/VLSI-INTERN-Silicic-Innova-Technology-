module traffic_light_controller(
    input clk,
    input rst,
  input [1:0] emergency_dir,      
    input [3:0] pedestrian_req,     
    input [1:0] traffic_density_N,
    input [1:0] traffic_density_E,
    input [1:0] traffic_density_S,
    input [1:0] traffic_density_W,
    
    output reg [2:0] traffic_N,     
    output reg [2:0] traffic_E,
    output reg [2:0] traffic_S,
    output reg [2:0] traffic_W,
    
    output reg walk_N,
    output reg walk_E,
    output reg walk_S,
    output reg walk_W
);
    localparam RED    = 3'b001;
    localparam YELLOW = 3'b010;
    localparam GREEN  = 3'b100;

    typedef enum reg [3:0] {
    S_NORTH_GREEN  = 4'd0,
    S_NORTH_YELLOW = 4'd1,
    S_EAST_GREEN   = 4'd2,
    S_EAST_YELLOW  = 4'd3,
    S_SOUTH_GREEN  = 4'd4,
    S_SOUTH_YELLOW = 4'd5,
    S_WEST_GREEN   = 4'd6,
    S_WEST_YELLOW  = 4'd7,
    S_EMERGENCY    = 4'd8
} state_t;

    state_t state, next_state;
    reg [7:0] timer;
    reg [7:0] green_time;

    function [7:0] calc_green_time(input [1:0] density);
        case (density)
            2'b00: calc_green_time = 8'd10;
            2'b01: calc_green_time = 8'd20;
            2'b10: calc_green_time = 8'd30;
            2'b11: calc_green_time = 8'd40;
            default: calc_green_time = 8'd10;
        endcase
    endfunction

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= S_NORTH_GREEN;
            timer <= 0;
        end else begin
            if (timer == 0)
                state <= next_state;
            else
                timer <= timer - 1;
        end
    end

  always @(*) 
    begin
        next_state = state;
        green_time = 8'd20;
        case(state)
            S_NORTH_GREEN: 
              begin
                green_time = calc_green_time(traffic_density_N);
                if (timer == 0)
                    next_state = S_NORTH_YELLOW;
              end
            S_NORTH_YELLOW: 
              begin
                green_time = 8'd5; 
                if (timer == 0)
                    next_state = S_EAST_GREEN;
              end
            S_EAST_GREEN: 
              begin
                green_time = calc_green_time(traffic_density_E);
                if (timer == 0)
                    next_state = S_EAST_YELLOW;
              end
            S_EAST_YELLOW: 
              begin
                green_time = 8'd5;
                if (timer == 0)
                    next_state = S_SOUTH_GREEN;
              end
            S_SOUTH_GREEN: 
              begin
                green_time = calc_green_time(traffic_density_S);
                if (timer == 0)
                    next_state = S_SOUTH_YELLOW;
              end
            S_SOUTH_YELLOW: 
              begin
                green_time = 8'd5;
                if (timer == 0)
                    next_state = S_WEST_GREEN;
              end
            S_WEST_GREEN: 
              begin
                green_time = calc_green_time(traffic_density_W);
                if (timer == 0)
                    next_state = S_WEST_YELLOW;
              end
            S_WEST_YELLOW: 
              begin
                green_time = 8'd5;
                if (timer == 0)
                    next_state = S_NORTH_GREEN;
              end
            S_EMERGENCY: 
              begin
              end
        endcase
        if (emergency_dir != 2'b00) 
          begin
            next_state = S_EMERGENCY;
          end
    end
    always @(*) 
      begin
        traffic_N = RED; 
        traffic_E = RED; 
        traffic_S = RED; 
        traffic_W = RED;
        walk_N = 0; 
        walk_E = 0; 
        walk_S = 0; 
        walk_W = 0;
        case(state)
            S_NORTH_GREEN: 
              begin
                traffic_N = GREEN; 
                traffic_E = RED; 
                traffic_S = RED; 
                traffic_W = RED;
                if(pedestrian_req[0]) 
                  walk_N = 1;
              end
            S_NORTH_YELLOW: traffic_N = YELLOW;
            S_EAST_GREEN: 
              begin
                traffic_N = RED; 
                traffic_E = GREEN; 
                traffic_S = RED; 
                traffic_W = RED;         
                if(pedestrian_req[1]) 
                walk_E = 1;
              end
            S_EAST_YELLOW: traffic_E = YELLOW;
            S_SOUTH_GREEN: 
              begin
                traffic_N = RED; 
                traffic_E = RED; 
                traffic_S = GREEN; 
                traffic_W = RED;
                if(pedestrian_req[2]) 
                  walk_S = 1;
              end
            S_SOUTH_YELLOW: traffic_S = YELLOW;
            S_WEST_GREEN: 
              begin
                traffic_N = RED; 
                traffic_E = RED; 
                traffic_S = RED; 
                traffic_W = GREEN;
                if(pedestrian_req[3]) 
                  walk_W = 1;
              end
            S_WEST_YELLOW: traffic_W = YELLOW;
            S_EMERGENCY: 
              begin
                traffic_N = (emergency_dir == 2'b01) ? GREEN : RED;
                traffic_E = (emergency_dir == 2'b10) ? GREEN : RED;
                traffic_S = (emergency_dir == 2'b11) ? GREEN : RED;
                traffic_W = (emergency_dir == 2'b11) ? GREEN : RED;
              
                walk_N = 0; 
                walk_E = 0; 
                walk_S = 0; 
                walk_W = 0;
              end
        endcase
      end
    always @(posedge clk or posedge rst) begin
        if(rst)
            timer <= 0;
        else if(timer == 0)
            timer <= green_time;
        else
            timer <= timer - 1;
    end
endmodule

`timescale 1ns/1ps

module tb_traffic_light_controller;

  reg clk;
  reg rst;
  reg [1:0] emergency_dir;
  reg [3:0] pedestrian_req;
  reg [1:0] traffic_density_N;
  reg [1:0] traffic_density_E;
  reg [1:0] traffic_density_S;
  reg [1:0] traffic_density_W;

  wire [2:0] traffic_N;
  wire [2:0] traffic_E;
  wire [2:0] traffic_S;
  wire [2:0] traffic_W;

  wire walk_N;
  wire walk_E;
  wire walk_S;
  wire walk_W;

  traffic_light_controller uut (
    .clk(clk),
    .rst(rst),
    .emergency_dir(emergency_dir),
    .pedestrian_req(pedestrian_req),
    .traffic_density_N(traffic_density_N),
    .traffic_density_E(traffic_density_E),
    .traffic_density_S(traffic_density_S),
    .traffic_density_W(traffic_density_W),
    .traffic_N(traffic_N),
    .traffic_E(traffic_E),
    .traffic_S(traffic_S),
    .traffic_W(traffic_W),
    .walk_N(walk_N),
    .walk_E(walk_E),
    .walk_S(walk_S),
    .walk_W(walk_W)
  );

  initial clk = 0;
  always #5 clk = ~clk;

  initial begin
    rst = 1;
    emergency_dir = 2'b00;
    pedestrian_req = 4'b0000;
    traffic_density_N = 2'b00;
    traffic_density_E = 2'b00;
    traffic_density_S = 2'b00;
    traffic_density_W = 2'b00;

    #20 rst = 0;

    traffic_density_N = 2'b01;
    traffic_density_E = 2'b10;
    traffic_density_S = 2'b11;
    traffic_density_W = 2'b00;
    #100;

    pedestrian_req = 4'b0001;
    #100;

    pedestrian_req = 4'b0010;
    #100;

    pedestrian_req = 4'b0100;
    #100;

    pedestrian_req = 4'b1000;
    #100;

    pedestrian_req = 4'b1111;
    #100;

    emergency_dir = 2'b01;
    #100;

    emergency_dir = 2'b10;
    #100;

    emergency_dir = 2'b11;
    #100;

    emergency_dir = 2'b00;
    pedestrian_req = 4'b0000;
    #100;

    repeat (4) begin : density_loop
      traffic_density_N = $random % 4;
      traffic_density_E = $random % 4;
      traffic_density_S = $random % 4;
      traffic_density_W = $random % 4;
      #100;
    end
    $finish;
  end

  initial begin
    $monitor("Time=%0t \tRST=%b| N=%b E=%b S=%b W=%b | Walk N=%b E=%b S=%b W=%b | Emergency=%b | PedReq=%b | Density N=%b E=%b S=%b W=%b",
      $time,rst, traffic_N, traffic_E, traffic_S, traffic_W,
      walk_N, walk_E, walk_S, walk_W,
      emergency_dir, pedestrian_req,
      traffic_density_N, traffic_density_E, traffic_density_S, traffic_density_W);
  end
endmodule


OUTPUT
Time=0 	      RST=1| N=100 E=001 S=001 W=001 | Walk N=0 E=0 S=0 W=0 | Emergency=00 | PedReq=0000 | Density N=00 E=00 S=00 W=00
Time=20000   	RST=0| N=100 E=001 S=001 W=001 | Walk N=0 E=0 S=0 W=0 | Emergency=00 | PedReq=0000 | Density N=01 E=10 S=11 W=00
Time=25000 	  RST=0| N=010 E=001 S=001 W=001 | Walk N=0 E=0 S=0 W=0 | Emergency=00 | PedReq=0000 | Density N=01 E=10 S=11 W=00
Time=120000 	RST=0| N=010 E=001 S=001 W=001 | Walk N=0 E=0 S=0 W=0 | Emergency=00 | PedReq=0001 | Density N=01 E=10 S=11 W=00
Time=220000 	RST=0| N=010 E=001 S=001 W=001 | Walk N=0 E=0 S=0 W=0 | Emergency=00 | PedReq=0010 | Density N=01 E=10 S=11 W=00
Time=235000 	RST=0| N=001 E=100 S=001 W=001 | Walk N=0 E=1 S=0 W=0 | Emergency=00 | PedReq=0010 | Density N=01 E=10 S=11 W=00
Time=295000 	RST=0| N=001 E=010 S=001 W=001 | Walk N=0 E=0 S=0 W=0 | Emergency=00 | PedReq=0010 | Density N=01 E=10 S=11 W=00
Time=320000 	RST=0| N=001 E=010 S=001 W=001 | Walk N=0 E=0 S=0 W=0 | Emergency=00 | PedReq=0100 | Density N=01 E=10 S=11 W=00
Time=420000 	RST=0| N=001 E=010 S=001 W=001 | Walk N=0 E=0 S=0 W=0 | Emergency=00 | PedReq=1000 | Density N=01 E=10 S=11 W=00
Time=520000 	RST=0| N=001 E=010 S=001 W=001 | Walk N=0 E=0 S=0 W=0 | Emergency=00 | PedReq=1111 | Density N=01 E=10 S=11 W=00
Time=605000 	RST=0| N=001 E=001 S=100 W=001 | Walk N=0 E=0 S=1 W=0 | Emergency=00 | PedReq=1111 | Density N=01 E=10 S=11 W=00
Time=620000 	RST=0| N=001 E=001 S=100 W=001 | Walk N=0 E=0 S=1 W=0 | Emergency=01 | PedReq=1111 | Density N=01 E=10 S=11 W=00
Time=665000 	RST=0| N=100 E=001 S=001 W=001 | Walk N=0 E=0 S=0 W=0 | Emergency=01 | PedReq=1111 | Density N=01 E=10 S=11 W=00
Time=720000 	RST=0| N=001 E=100 S=001 W=001 | Walk N=0 E=0 S=0 W=0 | Emergency=10 | PedReq=1111 | Density N=01 E=10 S=11 W=00
Time=820000 	RST=0| N=001 E=001 S=100 W=100 | Walk N=0 E=0 S=0 W=0 | Emergency=11 | PedReq=1111 | Density N=01 E=10 S=11 W=00
Time=920000 	RST=0| N=001 E=001 S=001 W=001 | Walk N=0 E=0 S=0 W=0 | Emergency=00 | PedReq=0000 | Density N=01 E=10 S=11 W=00
Time=1020000 	RST=0| N=001 E=001 S=001 W=001 | Walk N=0 E=0 S=0 W=0 | Emergency=00 | PedReq=0000 | Density N=00 E=01 S=01 W=11
Time=1120000 	RST=0| N=001 E=001 S=001 W=001 | Walk N=0 E=0 S=0 W=0 | Emergency=00 | PedReq=0000 | Density N=01 E=01 S=01 W=10
Time=1220000 	RST=0| N=001 E=001 S=001 W=001 | Walk N=0 E=0 S=0 W=0 | Emergency=00 | PedReq=0000 | Density N=01 E=01 S=10 W=01
Time=1320000 	RST=0| N=001 E=001 S=001 W=001 | Walk N=0 E=0 S=0 W=0 | Emergency=00 | PedReq=0000 | Density N=01 E=00 S=01 W=10
testbench.sv:113: $finish called at 1420000 (1ps)
