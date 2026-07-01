/* ╔════════════════════════════════════════════════════════════════════╗
 * ║                        Verilog I2C Master-Slave                    ║
 * ╠════════════════════════════════════════════════════════════════════╣
 * ║  File        : i2c_slave_controller4.sv                            ║
 * ║  Name        : Dhanasankar K                                       ║
 * ║  Description : I2C Slave module (Address: 0x40) for responding to  ║
 * ║                master's read and write operations.                 ║
 * ║  Created On  : 2025-07-01                                          ║
 * ╚════════════════════════════════════════════════════════════════════╝
 */

/* ╔════════════════════════════════════════════════════════════════════╗
 * ║  Implements I2C address match (0x40), ACK/NACK, and data logic.    ║
 * ║  Used in multi-slave I2C communication environment.                ║
 * ╚════════════════════════════════════════════════════════════════════╝
 */

`timescale 1ns / 1ps

// ==================================================================
//  I2C Slave Controller 4 (Address: 0x2D)
// ==================================================================
module i2c_slave_controller4(
	inout sda,
	inout scl
);

// ==================================================================
//  Parameters
// ==================================================================
localparam ADDRESS    = 7'b0101101;  // Slave address: 0x2D
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

// Tristate control of SDA line
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
//  Main FSM: Respond to I2C Commands (Clocked on SCL rising edge)
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
			// Read 8-bit Data from Master
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
			// Write 8-bit Data to Master
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
//  SDA Line Control (Clocked on SCL falling edge)
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
