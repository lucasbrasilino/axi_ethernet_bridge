`timescale 1 ns / 1 ps

module axi_ethernet_bridge #
        (
        parameter integer C_TDATA_WIDTH = 32
        )
        (
        // Ports of Axi Slave Bus Interface s_data
        input wire                  aclk,
        input wire                  aresetn,

        output wire [7:0]           debug_bus,

        output reg                           s_axis_txd_tready,
        input wire [C_TDATA_WIDTH-1 : 0]     s_axis_txd_tdata,
        input wire [(C_TDATA_WIDTH/8)-1 : 0] s_axis_txd_tkeep,
        input wire                           s_axis_txd_tlast,
        input wire                           s_axis_txd_tvalid,

        output wire                          s_axis_txs_tready,
        input wire [C_TDATA_WIDTH-1 : 0]     s_axis_txs_tdata,
        input wire [(C_TDATA_WIDTH/8)-1 : 0] s_axis_txs_tkeep,
        input wire                           s_axis_txs_tlast,
        input wire                           s_axis_txs_tvalid,

        // Ports of Axi Master Bus Interface m_axis_txc
        input wire                            m_axis_txc_tready,
        output wire [C_TDATA_WIDTH-1 : 0]     m_axis_txc_tdata,
        output wire [(C_TDATA_WIDTH/8)-1 : 0] m_axis_txc_tkeep,
        output reg                            m_axis_txc_tlast,
        output reg                            m_axis_txc_tvalid,

        // Ports of Axi Master Bus Interface m_axis_txd
        output reg                            m_axis_txd_tvalid,
        output wire [C_TDATA_WIDTH-1 : 0]     m_axis_txd_tdata,
        output wire [(C_TDATA_WIDTH/8)-1 : 0] m_axis_txd_tkeep,
        output wire                           m_axis_txd_tlast,
        input wire                            m_axis_txd_tready
        );

    localparam NB_DELAY                    = 0.2;
    localparam A_DELAY                     = 1;
    // Add user logic here
    parameter WAIT_CTRL_READY              = 4'h0;
    parameter CTRL_WD_0                    = 4'h1;
    parameter CTRL_WD_1                    = 4'h2;
    parameter CTRL_WD_2                    = 4'h3;
    parameter DATA_STREAM_0                = 4'h4;
    parameter DATA_STREAM_1                = 4'h5;

    reg [3:0]                  state, state_next;
    reg [2:0]                  counter, counter_next;
    wire                       counter_stop;
    reg [C_TDATA_WIDTH+(C_TDATA_WIDTH/8)+1:0]                 status, status_next;
    wire [C_TDATA_WIDTH+(C_TDATA_WIDTH/8)+1:0]                status_port;
    wire [2:0]                 counter_plus1;
    reg                        s_txd_tlast_r, s_txd_tlast_next;

    //debug
    /*
    (* mark_debug = "yes" *) wire [7:0]      state_out = {4'b0,state};
    assign debug_bus [7:0]      = state_out;
    */
    // ------------- Logic ----------------

    // AXIS
    assign m_axis_txd_tdata = s_axis_txd_tdata;
    assign m_axis_txd_tkeep = s_axis_txd_tkeep;
    assign m_axis_txd_tlast = s_axis_txd_tlast;
    assign m_axis_txc_tdata    = (state == CTRL_WD_0) ? {4'ha,28'h0} : {32'h0};
    assign m_axis_txc_tkeep    = 4'hf;
    assign s_axis_txs_tready   = 1'b1;

    // Other assignments
    assign counter_plus1       = counter + 1'b1;
    assign counter_stop        = ((counter == 3'h3) && m_axis_txc_tready);
    assign status_port        = {s_axis_txs_tdata,s_axis_txs_tkeep,s_axis_txs_tvalid,s_axis_txs_tlast};

    always @(*) begin : TXC
        state_next = state;
        status_next = status_port;
        m_axis_txc_tlast = 1'b0;
        m_axis_txc_tvalid = 1'b0;
        m_axis_txd_tvalid = 1'b0;
        s_axis_txd_tready = 1'b0;
        s_txd_tlast_next = s_txd_tlast_r;
        case(state)
            WAIT_CTRL_READY: begin
                s_txd_tlast_next = 1'b0;
                if (m_axis_txc_tready) begin
                    state_next = CTRL_WD_0;
                end
            end
            CTRL_WD_0: begin
                m_axis_txc_tvalid = 1'b1;
                if (m_axis_txc_tready) begin
                    state_next = CTRL_WD_1;
                end
            end
            CTRL_WD_1: begin
                m_axis_txc_tvalid = 1'b1;
                if (m_axis_txc_tready && counter_stop) begin
                    state_next = CTRL_WD_2;
                end
            end
            CTRL_WD_2: begin
                m_axis_txc_tvalid = 1'b1;
                if (m_axis_txc_tready) begin
                    m_axis_txc_tlast = 1'b1;
                    state_next = DATA_STREAM_0;
                end
            end
            DATA_STREAM_0: begin
                m_axis_txd_tvalid = s_axis_txd_tvalid;
                s_axis_txd_tready = m_axis_txd_tready;
                if (s_axis_txd_tlast && m_axis_txd_tready) begin
                        state_next = DATA_STREAM_1;

                end
            end
            DATA_STREAM_1: begin
                m_axis_txd_tvalid = s_axis_txd_tvalid;
                s_axis_txd_tready = m_axis_txd_tready;
                if (m_axis_txc_tready) begin
                        state_next = WAIT_CTRL_READY;
                end
            end
        endcase
    end//always

    always @(*) begin: COUNTER
        counter_next = counter;
        case (state)
            CTRL_WD_1: begin
                if (m_axis_txc_tready) begin
                    counter_next = counter_plus1;
                end
            end
            default: begin
                counter_next = 3'h0;
            end
        endcase
    end//always

    always @(posedge aclk) begin
        if(~aresetn) begin
            state <= #NB_DELAY WAIT_CTRL_READY;
            counter <= #NB_DELAY 3'b0;
            status <= #NB_DELAY 38'b0;
            s_txd_tlast_r <= #NB_DELAY 1'b0;
        end
        else begin
            state <= #NB_DELAY state_next;
            counter <= #NB_DELAY counter_next;
            status <= #NB_DELAY status_next;
            s_txd_tlast_r <= #NB_DELAY s_txd_tlast_next;
        end
    end
endmodule
