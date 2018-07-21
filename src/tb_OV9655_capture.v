`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 2018/05/05 05:29:30
// Design Name:
// Module Name: tb_OV9655_capture
// Project Name:
// Target Devices:
// Tool Versions:
// Description:
//
// Dependencies:
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//
//////////////////////////////////////////////////////////////////////////////////


module tb_OV9655_capture;

//-----------------------------------------------------------------------------

initial $timeformat(-6, 3, " us", 15);

//-----------------------------------------------------------------------------

`include "OV9655_capture_regs_def.vh"

    parameter C_S00_AXI_DATA_WIDTH	= 32;
    parameter C_S00_AXI_ADDR_WIDTH	= 16;
//    parameter C_M00_AXI_DATA_WIDTH	= 32;
    parameter C_M00_AXI_DATA_WIDTH	= 64;

    parameter C_S_AXI_CLK_PERIOD = 10;
    parameter C_M_AXIS_CLK_PERIOD = 6.67;

    parameter C_XCLK_DIV = 3; // Half period of XCLK in m00_axis_aclk

    parameter C_H_SIZE = 32'd20;
    parameter C_V_SIZE = 32'd10;
    parameter C_LINE_SIZE_BYTE = C_H_SIZE * 4;
    parameter C_FRAME_SIZE_BYTE = C_H_SIZE * C_V_SIZE * 4;


    wire            PCLK;
    wire    [9:0]   DAT;
    wire            HREF;
    wire            VSYNC;
    wire            XCLK;

    reg   s00_axi_aclk;
    reg   s00_axi_aresetn;
    reg  [C_S00_AXI_ADDR_WIDTH-1 : 0] s00_axi_awaddr;
    wire [2 : 0] s00_axi_awprot = 'd0;
    reg   s00_axi_awvalid;
    wire  s00_axi_awready;
    reg  [C_S00_AXI_DATA_WIDTH-1 : 0] s00_axi_wdata;
    reg  [(C_S00_AXI_DATA_WIDTH/8)-1 : 0] s00_axi_wstrb;
    reg   s00_axi_wvalid;
    wire  s00_axi_wready;
    wire [1 : 0] s00_axi_bresp;
    wire  s00_axi_bvalid;
    reg   s00_axi_bready;
    reg  [C_S00_AXI_ADDR_WIDTH-1 : 0] s00_axi_araddr;
    wire [2 : 0] s00_axi_arprot = 'd0;
    reg   s00_axi_arvalid;
    wire  s00_axi_arready;
    wire [C_S00_AXI_DATA_WIDTH-1 : 0] s00_axi_rdata;
    wire [1 : 0] s00_axi_rresp;
    wire  s00_axi_rvalid;
    reg   s00_axi_rready;

    reg   m00_axis_aclk;
    reg   m00_axis_aresetn;
    wire  m00_axis_tvalid;
    wire [C_M00_AXI_DATA_WIDTH-1 : 0] m00_axis_tdata;
    wire [C_M00_AXI_DATA_WIDTH/8-1 : 0] m00_axis_tstrb;
    wire  m00_axis_tuser;
    wire  m00_axis_tlast;
    reg   m00_axis_tready;
    // wire  m00_axis_tready = 1'b1;

//-----------------------------------------------------------------------------

    OV9655_capture_v1_0 #(
        .C_XCLK_DIV(3),
        // Parameters of Axi Slave Bus Interface S00_AXI
        .C_S00_AXI_DATA_WIDTH(C_S00_AXI_DATA_WIDTH),
        .C_S00_AXI_ADDR_WIDTH(C_S00_AXI_ADDR_WIDTH),
        .C_M00_AXIS_TDATA_WIDTH(C_M00_AXI_DATA_WIDTH)
    ) dut (
        // Users to add ports here
        .pclk_i     (PCLK),
        .dat_i      (DAT),
        .href_i     (HREF),
        .vsync_i    (VSYNC),
        .xclk_o     (XCLK),
        // User ports ends

        // Ports of Axi Slave Bus Interface S00_AXI
        .s00_axi_aclk       (s00_axi_aclk),
        .s00_axi_aresetn    (s00_axi_aresetn),
        .s00_axi_awaddr     (s00_axi_awaddr),
        .s00_axi_awprot     (s00_axi_awprot),
        .s00_axi_awvalid    (s00_axi_awvalid),
        .s00_axi_awready    (s00_axi_awready),
        .s00_axi_wdata      (s00_axi_wdata),
        .s00_axi_wstrb      (s00_axi_wstrb),
        .s00_axi_wvalid     (s00_axi_wvalid),
        .s00_axi_wready     (s00_axi_wready),
        .s00_axi_bresp      (s00_axi_bresp),
        .s00_axi_bvalid     (s00_axi_bvalid),
        .s00_axi_bready     (s00_axi_bready),
        .s00_axi_araddr     (s00_axi_araddr),
        .s00_axi_arprot     (s00_axi_arprot),
        .s00_axi_arvalid    (s00_axi_arvalid),
        .s00_axi_arready    (s00_axi_arready),
        .s00_axi_rdata      (s00_axi_rdata),
        .s00_axi_rresp      (s00_axi_rresp),
        .s00_axi_rvalid     (s00_axi_rvalid),
        .s00_axi_rready     (s00_axi_rready),

        // Ports of Axi Master Bus Interface M00_AXIS
        .m00_axis_aclk      (m00_axis_aclk),
        .m00_axis_aresetn   (m00_axis_aresetn),
        .m00_axis_tvalid    (m00_axis_tvalid),
        .m00_axis_tdata     (m00_axis_tdata),
        .m00_axis_tstrb     (m00_axis_tstrb),
        .m00_axis_tuser     (m00_axis_tuser),
        .m00_axis_tlast     (m00_axis_tlast),
        .m00_axis_tready    (m00_axis_tready)
    );

    OV7670_model #(
        .OV7670_VSYNC_WIDTH(32'd3),
        .OV7670_VSYNC_TO_HREF(32'd4),
        .OV7670_HREF_TO_VSYNC(32'd3),
        .OV7670_HREF_BLANK(32'd40),
        .OV7670_HSIZE(C_H_SIZE),
        .OV7670_VSIZE(C_V_SIZE)
    ) OV7670_model_inst(
        .XCLK(XCLK),
        .PCLK(PCLK),
        .RESETN(s00_axi_aresetn),
        .HREF(HREF),
        .VSYNC(VSYNC),
        .DATA(DAT[9:2]),
        .PIXEL_FORMAT(32'h1)
    );

    assign DAT[1:0] = 2'b0;

//-----------------------------------------------------------------------------
    wire [7:0] dat_int_mon = dut.OV9655_if_inst.dat_s2[9:2];
//-----------------------------------------------------------------------------
    always begin
        s00_axi_aclk = 1'b0;
        #(C_S_AXI_CLK_PERIOD/2) s00_axi_aclk = 1'b1;
        #(C_S_AXI_CLK_PERIOD/2);
    end

    initial begin
        s00_axi_aresetn = 1'b0;
        #(100);
        @(posedge s00_axi_aclk) s00_axi_aresetn = 1'b1;
    end

    always begin
        m00_axis_aclk = 1'b0;
        #(C_M_AXIS_CLK_PERIOD/2) m00_axis_aclk = 1'b1;
        #(C_M_AXIS_CLK_PERIOD/2);
    end

    initial begin
        m00_axis_aresetn = 1'b0;
        #(100);
        @(posedge m00_axis_aclk) m00_axis_aresetn = 1'b1;
    end

//-----------------------------------------------------------------------------

    initial begin
        s00_axi_awvalid     <= 1'b0;
        s00_axi_wstrb       <= {(C_S00_AXI_DATA_WIDTH/8){1'b1}};
        s00_axi_wvalid      <= 1'b0;
        s00_axi_bready      <= 1'b0;
        s00_axi_arvalid     <= 1'b0;
        s00_axi_rready      <= 1'b0;
    end

    task reg_write(
        input [C_S00_AXI_ADDR_WIDTH-1 : 0] addr,
        input [C_S00_AXI_DATA_WIDTH-1 : 0] data
    );
    begin
        while(s00_axi_aresetn == 1'b0)
            @(posedge s00_axi_aclk);

        fork
            begin
                s00_axi_awaddr      <= addr;
                s00_axi_awvalid     <= 1'b1;
                while(s00_axi_awready == 1'b0)
                    @(posedge s00_axi_aclk);
                s00_axi_awvalid     <= 1'b0;
            end

            begin
                repeat(3) @(posedge s00_axi_aclk);
                s00_axi_wdata   <= data;
                s00_axi_wvalid  <= 1'b1;
                while(s00_axi_wready == 1'b0)
                    @(posedge s00_axi_aclk);
                s00_axi_wvalid  <= 1'b0;
            end

            begin
                while(s00_axi_bvalid == 1'b0)
                    @(posedge s00_axi_aclk);
                s00_axi_bready  <= 1'b1;
                @(posedge s00_axi_aclk);
                s00_axi_bready  <= 1'b0;
            end

        join
    end
    endtask


    reg     [C_S00_AXI_DATA_WIDTH-1 : 0] reg_read_data = 32'd0;

    task reg_read(
        input [C_S00_AXI_ADDR_WIDTH-1 : 0] addr
    );
    begin
        while(s00_axi_aresetn == 1'b0)
            @(posedge s00_axi_aclk);

        fork
            begin
                s00_axi_araddr      <= addr;
                s00_axi_arvalid     <= 1'b1;
                while(s00_axi_arready == 1'b0)
                    @(posedge s00_axi_aclk);
                s00_axi_arvalid     <= 1'b0;
            end

            begin
                while(s00_axi_rvalid == 1'b0)
                    @(posedge s00_axi_aclk);
                reg_read_data   <= s00_axi_rdata;
                s00_axi_rready  <= 1'b1;
                @(posedge s00_axi_aclk);
                s00_axi_rready  <= 1'b0;
            end
        join
    end
    endtask

//-----------------------------------------------------------------------------

    reg [7:0] R0, G0, B0;
    reg [7:0] R1, G1, B1;

    always @(posedge m00_axis_aclk) begin
        if(m00_axis_aresetn == 1'b0) begin
            R0  <= 8'd0;
            G0  <= 8'd0;
            B0  <= 8'd0;
            R1  <= 8'd0;
            G1  <= 8'd0;
            B1  <= 8'd0;

            m00_axis_tready <= 1'b0;
        end
        else begin
            if(m00_axis_tready && m00_axis_tvalid) begin
                R0 <= m00_axis_tdata[23:16];
                G0 <= m00_axis_tdata[15:8];
                B0 <= m00_axis_tdata[7:0];
                R1 <= m00_axis_tdata[55:48];
                G1 <= m00_axis_tdata[47:40];
                B1 <= m00_axis_tdata[39:32];
            end

            m00_axis_tready <= ($random);
        end
    end

    generate
        if(C_M00_AXI_DATA_WIDTH == 64) begin
            always @(posedge m00_axis_aclk) begin
                if(m00_axis_aresetn == 1'b0) begin
                    R1  <= 8'd0;
                    G1  <= 8'd0;
                    B1  <= 8'd0;
                end
                else begin
                    if(m00_axis_tready && m00_axis_tvalid) begin
                        R1 <= m00_axis_tdata[55:48];
                        G1 <= m00_axis_tdata[47:40];
                        B1 <= m00_axis_tdata[39:32];
                    end
                end
            end

        end
    endgenerate

//-----------------------------------------------------------------------------
    reg [31:0]  sof_interval, line_interval;

    always @(posedge m00_axis_aclk) begin
        if(m00_axis_aresetn == 1'b0) begin
            sof_interval    <= 32'd0;
            line_interval   <= 32'd0;
        end
        else begin
            if(m00_axis_tvalid && m00_axis_tready) begin
                if(m00_axis_tuser) begin
                    sof_interval    <= 32'd1;
                    if((sof_interval != 32'd0) && (sof_interval != C_FRAME_SIZE_BYTE / (C_M00_AXI_DATA_WIDTH/8)))
                        $display("SOF interval error, expected:%d, actual:%d", C_FRAME_SIZE_BYTE / (C_M00_AXI_DATA_WIDTH/8), sof_interval);
                end
                else if(sof_interval != 32'd0)
                    sof_interval    <= sof_interval + 32'd1;

                if(m00_axis_tlast) begin
                    line_interval   <= 32'd0;
                    if(line_interval != C_LINE_SIZE_BYTE / (C_M00_AXI_DATA_WIDTH/8) - 1)
                        $display("Line interval error, expected:%d, actual:%d", C_LINE_SIZE_BYTE / (C_M00_AXI_DATA_WIDTH/8), line_interval);
                end
                else
                    line_interval   <= line_interval + 32'd1;
            end
        end

    end


//-----------------------------------------------------------------------------
    initial begin
        while(s00_axi_aresetn == 1'b0)
            @(posedge s00_axi_aclk);

        #(100);

        reg_write(REG_ADDR_OV9655CPT_FORMAT, 32'd0);
        reg_write(REG_ADDR_OV9655CPT_FRAMES_SET, 32'd0);
        reg_write(REG_ADDR_OV9655CPT_LINE_SIZE, C_H_SIZE * 4);

        reg_read(REG_ADDR_OV9655CPT_STATUS);
        $display("[%t] OV9655CPT_STATUS : %x", $time, reg_read_data);

        #(20000);
        reg_write(REG_ADDR_OV9655CPT_CTRL, 32'd1);
        $display("[%t] Write OV9655_CTRL", $time);

        reg_read(REG_ADDR_OV9655CPT_STATUS);
        while(reg_read_data != 32'd1)
            reg_read(REG_ADDR_OV9655CPT_STATUS);

        $display("[%t] Capture started", $time);

        #(1000000);
        $finish;
    end


endmodule
