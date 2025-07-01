/* ╔════════════════════════════════════════════════════════════════════╗
 * ║                        Verilog I2C Master-Slave                    ║
 * ╠════════════════════════════════════════════════════════════════════╣
 * ║  File        : i2c_slave_controller5.sv                            ║
 * ║  Name        : Dhanasankar K                                       ║
 * ║  Description : I2C Slave module (Address: 0x50) for data exchange  ║
 * ║                with the master.                                    ║
 * ║  Created On  : 2025-07-01                                          ║
 * ╚════════════════════════════════════════════════════════════════════╝
 */

/* ╔════════════════════════════════════════════════════════════════════╗
 * ║  Handles SDA/SCL signaling, address decoding (0x50), and ACKing.   ║
 * ║  Can be used for I2C sensor emulation or slave devices.            ║
 * ╚════════════════════════════════════════════════════════════════════╝
 */

`timescale 1ns / 1ps

// ==================================================================
//  I2C Slave Controller 5 (Address: 0x2F)
// ==================================================================
module i2c_slave_controller5(
	inout sda,
	inout scl
);

// ==================================================================
//  Parameters
// ==================================================================
localparam ADDRESS    = 7'b0101111;  // Slave address: 0x2F
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

// Tristate control for SDA line
wire matched_address = (addr[7:1] == ADDRESS);
assign sda = (write_enable && matched_address) ? sda_out : 1'bz;

// ==================================================================
//  Detect START Condition (falling edge of SDA while SCL is high)
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
//  Main FSM: Respond to I2C Commands (triggered on SCL rising edge)
// ==================================================================
always @(posedge scl) begin
	if (start == 1) begin
		case(state)

			// ----------------------------------------------------------
			// Read 7-bit address + R/W bit
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
					data_out <= data_in;  // Store received data
				end else
					counter <= counter - 1;
			end

			// ----------------------------------------------------------
			// Send ACK after receiving data
			// ----------------------------------------------------------
			SEND_ACK2: begin
				state <= READ_ADDR;
			end

			// ----------------------------------------------------------
			// Write 8-bit data to Master
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
//  SDA Line Control (triggered on SCL falling edge)
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
