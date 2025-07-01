/* ╔════════════════════════════════════════════════════════════════════╗
 * ║                        Verilog I2C Master-Slave                    ║
 * ╠════════════════════════════════════════════════════════════════════╣
 * ║  File        : i2c_master.v                                        ║
 * ║  Name        : Dhanasankar K                                       ║
 * ║  Description : I2C Master module implementing bit-level protocol   ║
 * ║  Created On  : 2025-07-01                                          ║
 * ╚════════════════════════════════════════════════════════════════════╝
 */

/* ╔════════════════════════════════════════════════════════════════════╗
 * ║  This module generates start/stop conditions, handles ACK,         ║
 * ║  and sends/receives data through SDA/SCL lines.                    ║
 * ╚════════════════════════════════════════════════════════════════════╝
 */

`timescale 1ns / 1ps

// ==================================================================
//  Include all slave controller modules
// ==================================================================
`include "i2c_slave_controller1.sv"
`include "i2c_slave_controller2.sv"
`include "i2c_slave_controller3.sv"
`include "i2c_slave_controller4.sv"
`include "i2c_slave_controller5.sv"

// ==================================================================
//  Top-Level I2C Controller Module
// ==================================================================
module i2c_controller(
	input wire clk,
	input wire rst,
	input wire [6:0] addr,
	input wire [7:0] data_in,
	input wire enable,
	input wire rw,

	output reg [7:0] data_out,
	output wire ready,

	inout i2c_sda,
	inout wire i2c_scl
	);

	// ===============================================================
	//  Local parameters for FSM states and clock divider
	// ===============================================================
	localparam IDLE = 0;
	localparam START = 1;
	localparam ADDRESS = 2;
	localparam READ_ACK = 3;
	localparam WRITE_DATA = 4;
	localparam WRITE_ACK = 5;
	localparam READ_DATA = 6;
	localparam READ_ACK2 = 7;
	localparam STOP = 8;

	localparam DIVIDE_BY = 4;

	// ===============================================================
	//  Internal registers
	// ===============================================================
	reg [7:0] state;
	reg [7:0] saved_addr;
	reg [7:0] saved_data;
	reg [7:0] counter;
	reg [7:0] counter2 = 0;
	reg write_enable;
	reg sda_out;
	reg i2c_scl_enable = 0;
	reg i2c_clk = 1;

	// ===============================================================
	//  Output assignments
	// ===============================================================
	assign ready = ((rst == 0) && (state == IDLE)) ? 1 : 0;
	assign i2c_scl = (i2c_scl_enable == 0 ) ? 1 : i2c_clk;
	assign i2c_sda = (write_enable == 1) ? sda_out : 'bz;

	// ===============================================================
	//  Clock divider logic for I2C timing
	// ===============================================================
	always @(posedge clk) begin
		if (counter2 == (DIVIDE_BY/2) - 1) begin
			i2c_clk <= ~i2c_clk;
			counter2 <= 0;
		end else
			counter2 <= counter2 + 1;
	end 

	// ===============================================================
	//  Control SCL enable based on state (Idle/Start/Stop → disabled)
	// ===============================================================
	always @(negedge i2c_clk, posedge rst) begin
		if(rst == 1)
			i2c_scl_enable <= 0;
		else begin
			if ((state == IDLE) || (state == START) || (state == STOP))
				i2c_scl_enable <= 0;
			else
				i2c_scl_enable <= 1;
		end
	end

	// ===============================================================
	//  FSM: Handles I2C transaction logic (START → STOP)
	// ===============================================================
	always @(posedge i2c_clk, posedge rst) begin
		if(rst == 1)
			state <= IDLE;
		else begin
			case(state)
				IDLE: begin
					if (enable) begin
						state <= START;
						saved_addr <= {addr, rw};
						saved_data <= data_in;
					end
				end

				START: begin
					counter <= 7;
					state <= ADDRESS;
				end

				ADDRESS: begin
					if (counter == 0)
						state <= READ_ACK;
					else
						counter <= counter - 1;
				end

				READ_ACK: begin
					if (i2c_sda == 0) begin
						counter <= 7;
						state <= (saved_addr[0] == 0) ? WRITE_DATA : READ_DATA;
					end else
						state <= STOP;
				end

				WRITE_DATA: begin
					if (counter == 0)
						state <= READ_ACK2;
					else
						counter <= counter - 1;
				end

				READ_ACK2: begin
					state <= (i2c_sda == 0 && enable == 1) ? IDLE : STOP;
				end

				READ_DATA: begin
					data_out[counter] <= i2c_sda;
					if (counter == 0)
						state <= WRITE_ACK;
					else
						counter <= counter - 1;
				end

				WRITE_ACK: state <= STOP;

				STOP: state <= IDLE;
			endcase
		end
	end

	// ===============================================================
	//  SDA output control logic (depending on FSM state)
	// ===============================================================
	always @(negedge i2c_clk, posedge rst) begin
		if(rst == 1) begin
			write_enable <= 1;
			sda_out <= 1;
		end else begin
			case(state)
				START: begin
					write_enable <= 1;
					sda_out <= 0;
				end

				ADDRESS: sda_out <= saved_addr[counter];

				READ_ACK: write_enable <= 0;

				WRITE_DATA: begin
					write_enable <= 1;
					sda_out <= saved_data[counter];
				end

				WRITE_ACK: begin
					write_enable <= 1;
					sda_out <= 0;
				end

				READ_DATA: write_enable <= 0;

				STOP: begin
					write_enable <= 1;
					sda_out <= 1;
				end
			endcase
		end
	end

endmodule

