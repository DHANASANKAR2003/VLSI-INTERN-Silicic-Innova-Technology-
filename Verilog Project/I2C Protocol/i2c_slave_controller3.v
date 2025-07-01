/* ╔════════════════════════════════════════════════════════════════════╗
 * ║                        Verilog I2C Master-Slave                    ║
 * ╠════════════════════════════════════════════════════════════════════╣
 * ║  File        : i2c_slave_controller3.sv                            ║
 * ║  Name        : Dhanasankar K                                       ║
 * ║  Description : I2C Slave module (Address: 0x30) for bidirectional  ║
 * ║                I2C communication with the master.                  ║
 * ║  Created On  : 2025-07-01                                          ║
 * ╚════════════════════════════════════════════════════════════════════╝
 */

/* ╔════════════════════════════════════════════════════════════════════╗
 * ║  Supports receiving and transmitting bytes via I2C protocol.      ║
 * ║  Responds only to master's request at address 0x30.               ║
 * ╚════════════════════════════════════════════════════════════════════╝
 */

`timescale 1ns / 1ps

// ==================================================================
//  I2C Slave Controller 3 (Address: 0x2C)
// ==================================================================
module i2c_slave_controller3(
	inout sda,
	inout scl
);

// ==================================================================
//  Parameters
// ==================================================================
localparam ADDRESS    = 7'b0101100;  // Slave address: 0x2C
localparam READ_ADDR  = 0;
localparam SEND_ACK   = 1;
localparam READ_DATA  = 2;
localparam WRITE_DATA = 3;
localparam SEND_ACK2  = 4;

// ==================================================================
//  Internal Registers and Wires
// ==================================================================
reg [7:0] addr;
reg [7:0] counter;
reg [7:0] state = 0;
reg [7:0] data_in = 0;
reg [7:0] data_out;
reg sda_out = 0;
reg sda_in = 0;
reg start = 0;
reg write_enable = 0;

wire matched_address = (addr[7:1] == ADDRESS);
assign sda = (write_enable && matched_address) ? sda_out : 1'bz;

// ==================================================================
//  Detect I2C START Condition (falling edge of SDA while SCL is high)
// ==================================================================
always @(negedge sda) begin
	if ((start == 0) && (scl == 1)) begin
		start <= 1;
		counter <= 7;
	end
end

// ==================================================================
//  Detect STOP Condition (rising edge of SDA while SCL is high)
// ==================================================================
always @(posedge sda) begin
	if ((start == 1) && (scl == 1)) begin
		state <= READ_ADDR;
		start <= 0;
		write_enable <= 0;
	end
end

// ==================================================================
//  Main FSM for Slave Logic (Triggered on SCL rising edge)
// ==================================================================
always @(posedge scl) begin
	if (start == 1) begin
		case(state)

			// ----------------------------------------------------------
			// Read 7-bit Address + R/W bit from Master
			// ----------------------------------------------------------
			READ_ADDR: begin
				addr[counter] <= sda;
				if (counter == 0)
					state <= SEND_ACK;
				else
					counter <= counter - 1;
			end

			// ----------------------------------------------------------
			// Send ACK if address matches
			// ----------------------------------------------------------
			SEND_ACK: begin
				if (addr[7:1] == ADDRESS) begin
					counter <= 7;
					state <= (addr[0] == 0) ? READ_DATA : WRITE_DATA;
				end
			end

			// ----------------------------------------------------------
			// Read 8-bit data from Master
			// ----------------------------------------------------------
			READ_DATA: begin
				data_in[counter] <= sda;
				if (counter == 0) begin
					state <= SEND_ACK2;
					data_out <= data_in;  // Save received data
				end else
					counter <= counter - 1;
			end

			// ----------------------------------------------------------
			// Send final ACK after receiving data
			// ----------------------------------------------------------
			SEND_ACK2: begin
				state <= READ_ADDR;
			end

			// ----------------------------------------------------------
			// Send 8-bit data to Master
			// ----------------------------------------------------------
			WRITE_DATA: begin
				if (counter == 0)
					state <= READ_ADDR;
				else
					counter <= counter - 1;
			end
		endcase
	end
end

// ==================================================================
//  Output Logic for SDA Line (Triggered on SCL falling edge)
// ==================================================================
always @(negedge scl) begin
	case(state)

		READ_ADDR: begin
			write_enable <= 0;
		end

		SEND_ACK: begin
			sda_out <= 0;
			write_enable <= 1;
		end

		READ_DATA: begin
			write_enable <= 0;
		end

		WRITE_DATA: begin
			sda_out <= data_out[counter];
			write_enable <= 1;
		end

		SEND_ACK2: begin
			sda_out <= 0;
			write_enable <= 1;
		end
	endcase
end

endmodule
