`timescale 1ns/1ps

module axi4_master #(
    parameter ADDRESS     = 32,
    parameter DATA_WIDTH  = 32,
    parameter ID_WIDTH    = 4
)(
    input                       ACLK,
    input                       ARESETN,
    input                       START_READ,
    input                       START_WRITE,
    input   [ADDRESS-1:0]       address,
    input   [DATA_WIDTH-1:0]    W_data,
    input   [3:0]               W_strb,
    input   [ID_WIDTH-1:0]      axi_id,
    input   [7:0]               burst_len,
    
    // Read Address Channel
    output  reg [ADDRESS-1:0]   M_ARADDR,
    output  reg [ID_WIDTH-1:0]  M_ARID,
    output  reg [7:0]           M_ARLEN,
    output  reg                 M_ARVALID,
    input                       M_ARREADY,
    
    // Read Data Channel
    input   [DATA_WIDTH-1:0]    M_RDATA,
    input   [ID_WIDTH-1:0]      M_RID,
    input   [1:0]               M_RRESP,
    input                       M_RLAST,
    input                       M_RVALID,
    output  reg                 M_RREADY,
    
    // Write Address Channel
    output  reg [ADDRESS-1:0]   M_AWADDR,
    output  reg [ID_WIDTH-1:0]  M_AWID,
    output  reg [7:0]           M_AWLEN,
    output  reg                 M_AWVALID,
    input                       M_AWREADY,
    
    // Write Data Channel
    output  reg [DATA_WIDTH-1:0] M_WDATA,
    output  reg [3:0]            M_WSTRB,
    output  reg                  M_WLAST,
    output  reg                  M_WVALID,
    input                        M_WREADY,
    
    // Write Response Channel
    input   [ID_WIDTH-1:0]      M_BID,
    input   [1:0]               M_BRESP,
    input                       M_BVALID,
    output  reg                 M_BREADY
);

    // FSM States
    localparam IDLE          = 3'd0,
               WRITE_ADDR    = 3'd1,
               WRITE_DATA    = 3'd2,
               WRESP_CHANNEL = 3'd3,
               RADDR_CHANNEL = 3'd4,
               RDATA_CHANNEL = 3'd5;

    reg [2:0] state, next_state;
    reg [7:0] beat_counter;
    reg [ID_WIDTH-1:0] stored_id;
    reg [7:0] stored_len;
    reg [ADDRESS-1:0] stored_addr;
    reg [DATA_WIDTH-1:0] stored_wdata;
    reg [3:0] stored_wstrb;

    // Latch inputs when START signal is asserted
    always @(posedge ACLK or negedge ARESETN) begin
        if (!ARESETN) begin
            stored_id <= {ID_WIDTH{1'b0}};
            stored_len <= 8'd0;
            stored_addr <= {ADDRESS{1'b0}};
            stored_wdata <= {DATA_WIDTH{1'b0}};
            stored_wstrb <= 4'b0000;
        end else begin
            // Latch on START signals, not state change
            if (START_WRITE) begin
                stored_id <= axi_id;
                stored_len <= burst_len;
                stored_addr <= address;
                stored_wdata <= W_data;
                stored_wstrb <= W_strb;
            end else if (START_READ) begin
                stored_id <= axi_id;
                stored_len <= burst_len;
                stored_addr <= address;
            end
        end
    end

    // Beat counter for burst transfers
    always @(posedge ACLK or negedge ARESETN) begin
        if (!ARESETN) begin
            beat_counter <= 8'd0;
        end else begin
            case(state)
                WRITE_DATA: begin
                    if (M_WVALID && M_WREADY) begin
                        if (beat_counter == stored_len)
                            beat_counter <= 8'd0;
                        else
                            beat_counter <= beat_counter + 1;
                    end
                end
                RDATA_CHANNEL: begin
                    if (M_RVALID && M_RREADY) begin
                        if (M_RLAST)
                            beat_counter <= 8'd0;
                        else
                            beat_counter <= beat_counter + 1;
                    end
                end
                default: beat_counter <= 8'd0;
            endcase
        end
    end

    // Read Address Channel outputs
    always @(posedge ACLK or negedge ARESETN) begin
        if (!ARESETN) begin
            M_ARADDR <= {ADDRESS{1'b0}};
            M_ARID <= {ID_WIDTH{1'b0}};
            M_ARLEN <= 8'd0;
            M_ARVALID <= 1'b0;
        end else begin
            if (state == IDLE && next_state == RADDR_CHANNEL) begin
                M_ARADDR <= stored_addr;
                M_ARID <= stored_id;
                M_ARLEN <= stored_len;
                M_ARVALID <= 1'b1;
            end else if (state == RADDR_CHANNEL && M_ARREADY) begin
                M_ARVALID <= 1'b0;
            end
        end
    end

    // Read Data Channel outputs
    always @(posedge ACLK or negedge ARESETN) begin
        if (!ARESETN) begin
            M_RREADY <= 1'b0;
        end else begin
            M_RREADY <= (state == RDATA_CHANNEL);
        end
    end

    // Write Address Channel outputs
    always @(posedge ACLK or negedge ARESETN) begin
        if (!ARESETN) begin
            M_AWADDR <= {ADDRESS{1'b0}};
            M_AWID <= {ID_WIDTH{1'b0}};
            M_AWLEN <= 8'd0;
            M_AWVALID <= 1'b0;
        end else begin
            if (state == IDLE && next_state == WRITE_ADDR) begin
                M_AWADDR <= stored_addr;
                M_AWID <= stored_id;
                M_AWLEN <= stored_len;
                M_AWVALID <= 1'b1;
            end else if (state == WRITE_ADDR && M_AWREADY) begin
                M_AWVALID <= 1'b0;
            end
        end
    end

    // Write Data Channel outputs
    always @(posedge ACLK or negedge ARESETN) begin
        if (!ARESETN) begin
            M_WDATA <= {DATA_WIDTH{1'b0}};
            M_WSTRB <= 4'b0000;
            M_WLAST <= 1'b0;
            M_WVALID <= 1'b0;
        end else begin
            if (state == WRITE_ADDR && next_state == WRITE_DATA) begin
                M_WDATA <= stored_wdata;
                M_WSTRB <= stored_wstrb;
                M_WLAST <= (beat_counter == stored_len);
                M_WVALID <= 1'b1;
            end else if (state == WRITE_DATA) begin
                if (M_WREADY && M_WLAST) begin
                    M_WVALID <= 1'b0;
                    M_WLAST <= 1'b0;
                end else if (M_WREADY) begin
                    M_WDATA <= stored_wdata;
                    M_WSTRB <= stored_wstrb;
                    M_WLAST <= (beat_counter == stored_len);
                    M_WVALID <= 1'b1;
                end
            end else begin
                M_WVALID <= 1'b0;
                M_WLAST <= 1'b0;
            end
        end
    end

    // Write Response Channel outputs
    always @(posedge ACLK or negedge ARESETN) begin
        if (!ARESETN) begin
            M_BREADY <= 1'b0;
        end else begin
            M_BREADY <= (state == WRESP_CHANNEL);
        end
    end

    // FSM state register
    always @(posedge ACLK or negedge ARESETN) begin
        if (!ARESETN)
            state <= IDLE;
        else
            state <= next_state;
    end

    // FSM next state logic - FIXED TO USE CURRENT INPUTS
    always @(*) begin
        next_state = state;
        
        case(state)
            IDLE: begin
                // Check START signals directly - no edge detection needed
                if (START_WRITE && (W_strb != 4'b0000))
                    next_state = WRITE_ADDR;
                else if (START_READ)
                    next_state = RADDR_CHANNEL;
            end
            
            WRITE_ADDR: begin
                if (M_AWVALID && M_AWREADY)
                    next_state = WRITE_DATA;
            end
            
            WRITE_DATA: begin
                if (M_WVALID && M_WREADY && M_WLAST)
                    next_state = WRESP_CHANNEL;
            end
            
            WRESP_CHANNEL: begin
                if (M_BVALID && M_BREADY)
                    next_state = IDLE;
            end
            
            RADDR_CHANNEL: begin
                if (M_ARVALID && M_ARREADY)
                    next_state = RDATA_CHANNEL;
            end
            
            RDATA_CHANNEL: begin
                if (M_RVALID && M_RREADY && M_RLAST)
                    next_state = IDLE;
            end
            
            default: next_state = IDLE;
        endcase
    end

endmodule
