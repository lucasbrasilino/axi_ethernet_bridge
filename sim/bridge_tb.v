`timescale 1ns / 1ps
/****************************************************************************
 * axi_ethenet_tb.v
 * Author: Lucas Brasilino <lbrasili@indiana.edu>
 ****************************************************************************/

/**
 * Module: axi_ethernet_brige testbench
 *
 */
module bridge_tb();
    reg                  aclk;
    reg                  aresetn;

    wire                          s_axis_txd_tready;
    reg  [31:0]                   s_axis_txd_tdata;
    wire [3:0]                    s_axis_txd_tkeep;
    reg                           s_axis_txd_tlast;
    reg                           s_axis_txd_tvalid;

    wire                          s_axis_txs_tready;
    wire [31:0]                   s_axis_txs_tdata;
    wire [3:0]                    s_axis_txs_tkeep;
    reg                           s_axis_txs_tlast;
    reg                           s_axis_txs_tvalid;

    // Ports of Axi Master Bus Interface m_axis_txc
    reg                             m_axis_txc_tready;
    wire [31:0]                     m_axis_txc_tdata;
    wire [3:0]                      m_axis_txc_tkeep;
    wire                            m_axis_txc_tlast;
    wire                            m_axis_txc_tvalid;

    // Ports of Axi Master Bus Interface m_axis_txd
    wire                            m_axis_txd_tvalid;
    wire [31:0]                     m_axis_txd_tdata;
    wire [3:0]                      m_axis_txd_tkeep;
    wire                            m_axis_txd_tlast;
    reg                             m_axis_txd_tready;

    localparam HALF_CORE_PERIOD = 5; // 100Mhz
    localparam PERIOD = HALF_CORE_PERIOD*2;

    assign s_axis_txs_tdata = 32'hDA5A;
    assign s_axis_txs_tkeep = 4'hf;
    assign s_axis_txd_tkeep = 4'hf;

    initial begin
        aclk = 1'b0;
        #(HALF_CORE_PERIOD);
        forever
            #(HALF_CORE_PERIOD) aclk = ~aclk;
    end

    initial begin
        aresetn = 1'b0;
        #(PERIOD * 5);
        aresetn = 1'b1;
        $display("Reset Deasserted");
    end


    initial begin
        s_axis_txs_tvalid = 1'b0;
        s_axis_txs_tlast  = 1'b0;

        m_axis_txc_tready = 1'b0;

        m_axis_txd_tready = 1'b0;

        s_axis_txd_tvalid = 1'b0;
        s_axis_txd_tlast = 1'b0;
        s_axis_txd_tdata = 32'h0;

        #(PERIOD * 12) s_axis_txd_tvalid = 1'b1;
        m_axis_txc_tready = 1'b1;

        #(PERIOD * 2) m_axis_txc_tready = 1'b0;
        #(PERIOD) m_axis_txc_tready = 1'b1;
        #(PERIOD) m_axis_txc_tready = 1'b0;
        #(PERIOD) m_axis_txc_tready = 1'b1;
        #(PERIOD * 5) m_axis_txc_tready = 1'b0;

        #(PERIOD * 2) m_axis_txd_tready = 1'b1;
        #(PERIOD * 2) s_axis_txd_tvalid = 1'b1;
        s_axis_txd_tdata = 32'h0c05fefe;

        #(PERIOD) s_axis_txd_tdata = 32'h0babaca;
        s_axis_txd_tlast = 1'b1;

        #(PERIOD) s_axis_txd_tlast = 1'b0;
        s_axis_txd_tvalid = 1'b0;
        #(PERIOD) m_axis_txd_tready = 1'b0;

        //2
        #(PERIOD * 12) s_axis_txd_tvalid = 1'b1;
        m_axis_txc_tready = 1'b1;

        #(PERIOD * 2) m_axis_txc_tready = 1'b0;
        #(PERIOD) m_axis_txc_tready = 1'b1;
        #(PERIOD * 5) m_axis_txc_tready = 1'b0;

        #(PERIOD * 2) m_axis_txd_tready = 1'b1;
        #(PERIOD * 2) s_axis_txd_tvalid = 1'b1;
        s_axis_txd_tdata = 32'h0c05fefe;

        #(PERIOD) s_axis_txd_tdata = 32'h0babaca;
        s_axis_txd_tlast = 1'b1;

        #(PERIOD) s_axis_txd_tlast = 1'b0;
        s_axis_txd_tvalid = 1'b0;
        #(PERIOD) m_axis_txd_tready = 1'b0;

        #(PERIOD * 11);
        $display("Simulation ended");
        $finish;
    end

    axi_ethernet_bridge dut (
            .aclk (aclk),
            .aresetn (aresetn),
            // a_axis_txd
            .s_axis_txd_tready    (s_axis_txd_tready),
            .s_axis_txd_tdata     (s_axis_txd_tdata),
            .s_axis_txd_tkeep     (s_axis_txd_tkeep),
            .s_axis_txd_tlast     (s_axis_txd_tlast),
            .s_axis_txd_tvalid    (s_axis_txd_tvalid),
            // .s_axis_txs
            .s_axis_txs_tready    (s_axis_txs_tready),
            .s_axis_txs_tdata     (s_axis_txs_tdata),
            .s_axis_txs_tkeep     (s_axis_txs_tkeep),
            .s_axis_txs_tlast     (s_axis_txs_tlast),
            .s_axis_txs_tvalid    (s_axis_txs_tvalid),
            // .m_axis_txc
            .m_axis_txc_tready    (m_axis_txc_tready),
            .m_axis_txc_tdata     (m_axis_txc_tdata),
            .m_axis_txc_tkeep     (m_axis_txc_tkeep),
            .m_axis_txc_tlast     (m_axis_txc_tlast),
            .m_axis_txc_tvalid    (m_axis_txc_tvalid),
            // .m_axis_txd
            .m_axis_txd_tvalid    (m_axis_txd_tvalid),
            .m_axis_txd_tdata     (m_axis_txd_tdata),
            .m_axis_txd_tkeep     (m_axis_txd_tkeep),
            .m_axis_txd_tlast     (m_axis_txd_tlast),
            .m_axis_txd_tready    (m_axis_txd_tready)
            );
endmodule
