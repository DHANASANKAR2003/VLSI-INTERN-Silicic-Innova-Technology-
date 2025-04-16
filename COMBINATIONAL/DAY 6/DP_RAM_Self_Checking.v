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



//Testbench code
module dual_port_ram_tb;

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
    always #7 clk2 = ~clk2;

    reg [3:0] expected_doa, expected_dob;

    initial begin
        $dumpfile("dual_port_ram_tb.vcd");
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

        #20 addra = 5'd3; expected_doa = 4'd4;
        #14
        $display("Reading from addr 3 (Port A): doa = %0d", doa);
        if (doa === expected_doa)
            $display("PASS: Port A Read = %0d at address %0d", doa, addra);
        else
            $display("FAIL: Port A Read = %0d, expected %0d", doa, expected_doa);

        addrb = 5'd7; expected_dob = 4'd9;
        #14
        $display("Reading from addr 7 (Port B): dob = %0d", dob);
        if (dob === expected_dob)
            $display("PASS: Port B Read = %0d at address %0d", dob, addrb);
        else
            $display("FAIL: Port B Read = %0d, expected %0d", dob, expected_dob);

        #20 wea = 1; dia = 4'd12; addra = 5'd5;
        #10 wea = 0;

        #14 web = 1; dib = 4'd7; addrb = 5'd10;
        #14 web = 0;

        #20 addra = 5'd5; expected_doa = 4'd12;
        #14
        $display("Reading from addr 5 (Port A): doa = %0d", doa);
        if (doa === expected_doa)
            $display("PASS: Port A Read = %0d at address %0d", doa, addra);
        else
            $display("FAIL: Port A Read = %0d, expected %0d", doa, expected_doa);

        addrb = 5'd10; expected_dob = 4'd7;
        #14
        $display("Reading from addr 10 (Port B): dob = %0d", dob);
        if (dob === expected_dob)
            $display("PASS: Port B Read = %0d at address %0d", dob, addrb);
        else
            $display("FAIL: Port B Read = %0d, expected %0d", dob, expected_dob);

        #20 $finish;
    end

endmodule

                                                                                                            
                                                         
