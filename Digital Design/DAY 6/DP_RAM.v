module dual_port_ram (
    input clk1,
    input clk2,
    input wea,
    input web,
    input [4:0] addra,
    input [4:0] addrb,
    input [3:0] dia,
    input [3:0] dib,
    output [3:0] doa,
    output [3:0] dob
);

    reg [3:0] ram [0:31];
    reg [4:0] read_addra, read_addrb;

    always @(posedge clk1) begin
        if (wea)
            ram[addra] <= dia;
    else
        read_addra <= addra;
    end

    always @(posedge clk2) begin
        if (web)
            ram[addrb] <= dib;
    else
        read_addrb <= addrb;
    end

    assign doa = ram[read_addra];
    assign dob = ram[read_addrb];

endmodule
modmodule dual_port_ram_tb;

    reg clk1, clk2;
    reg wea, web;
    reg [4:0] addra, addrb;
    reg [3:0] dia, dib;
    wire [3:0] doa, dob;

    dual_port_ram uut (
        .clk1(clk1),
        .clk2(clk2),
        .wea(wea),
        .web(web),modmodule dual_port_ram_tb;

    reg clk1, clk2;
    reg wea, web;
    reg [4:0] addra, addrb;
    reg [3:0] dia, dib;
    wire [3:0] doa, dob;

    dual_port_ram uut (
        .clk1(clk1),
        .clk2(clk2),
        .wea(wea),
        .web(web),
        .addra(addra),
        .addrb(addrb),
        .dia(dia),
        .dib(dib),
        .doa(doa),
        .dob(dob)
    );

    always #5 clk1 = ~clk1;
    always #5 clk2 = ~clk2;

 initial begin
        $dumpfile("dual_port_ram.vcd");
        $dumpvars(0, dual_port_ram_tb);
    end

    initial begin
        clk1 = 0; clk2 = 0;
        wea = 0; web = 0;
        dia = 0; dib = 0;
        addra = 0; addrb = 0;
        #10 wea = 1; dia = 4'd4; addra = 5'd3;
        #10 wea = 0;

        #14 web = 1; dib = 4'd9; addrb = 5'd7;
        #14 web = 0;

        #20 addra = 5'd3;

        #14 addrb = 5'd7;

        #50 $finish;
    end

    initial begin
        $monitor("Time=%0t | CLK1=%b CLK2=%b | ADDRA=%2d DIA=%1d => DOA=%1d | ADDRB=%2d DIB=%1d => DOB=%1d | WEA=%b WEB=%b",
                 $time, clk1, clk2, addra, dia, doa, addrb, dib, dob, wea, web);
    end

endmodule

