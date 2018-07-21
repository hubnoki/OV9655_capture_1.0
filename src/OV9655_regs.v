`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 2018/04/15 23:41:34
// Design Name:
// Module Name: OV9655_regs
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


module OV9655_regs #
(
    parameter integer C_S_AXI_DATA_WIDTH	= 32,
    parameter integer C_S_AXI_ADDR_WIDTH	= 16
)(
    input   wire            clk_int,
    input   wire            resetn_int,

    output  reg     [1:0]   ctrl_o,
    output  reg             ctrl_strb_o,
    input   wire            act_i,
    output  reg     [7:0]   format_o,
    output  reg     [31:0]  frames_set_o,
    input   wire    [31:0]  frames_cur_i,
    output  reg     [31:0]  line_size_o,

    input wire  S_AXI_ACLK,
    input wire  S_AXI_ARESETN,
    input wire [C_S_AXI_ADDR_WIDTH-1 : 0] S_AXI_AWADDR,
    input wire [2 : 0] S_AXI_AWPROT,
    input wire  S_AXI_AWVALID,
    output wire  S_AXI_AWREADY,
    input wire [C_S_AXI_DATA_WIDTH-1 : 0] S_AXI_WDATA,
    input wire [(C_S_AXI_DATA_WIDTH/8)-1 : 0] S_AXI_WSTRB,
    input wire  S_AXI_WVALID,
    output wire  S_AXI_WREADY,
    output wire [1 : 0] S_AXI_BRESP,
    output wire  S_AXI_BVALID,
    input wire  S_AXI_BREADY,
    input wire [C_S_AXI_ADDR_WIDTH-1 : 0] S_AXI_ARADDR,
    input wire [2 : 0] S_AXI_ARPROT,
    input wire  S_AXI_ARVALID,
    output wire  S_AXI_ARREADY,
    output wire [C_S_AXI_DATA_WIDTH-1 : 0] S_AXI_RDATA,
    output wire [1 : 0] S_AXI_RRESP,
    output wire  S_AXI_RVALID,
    input wire  S_AXI_RREADY

    );

    `include "OV9655_capture_regs_def.vh"

    wire [C_S_AXI_ADDR_WIDTH-1 : 0] awaddr_int;
    wire awvalid_int;
    reg awready_int;


    wire [C_S_AXI_DATA_WIDTH-1 : 0] wdata_int;
    wire [(C_S_AXI_DATA_WIDTH/8)-1 : 0] wstrb_int;
    wire wvalid_int;
    reg wready_int;
    reg bvalid_int;
    wire bready_int;

    wire [C_S_AXI_ADDR_WIDTH-1 : 0] araddr_int;
    wire arvalid_int;
    reg arready_int;

    reg [C_S_AXI_DATA_WIDTH-1 : 0] rdata_int;
    wire rready_int;
    reg rvalid_int;

    hs_async #(
        .D_WIDTH(C_S_AXI_ADDR_WIDTH)
    ) aw_hs_async(
        .clk_src(S_AXI_ACLK),
        .resetn_src(S_AXI_ARESETN),
        .clk_dst(clk_int),
        .resetn_dst(resetn_int),
        .valid_src_i(S_AXI_AWVALID),
        .data_src_i(S_AXI_AWADDR),
        .ready_src_o(S_AXI_AWREADY),
        .data_dst_o(awaddr_int),
        .valid_dst_o(awvalid_int),
        .ready_dst_i(awready_int)
    );

    hs_async #(
        .D_WIDTH(C_S_AXI_DATA_WIDTH + (C_S_AXI_DATA_WIDTH/8))
    ) w_hs_async(
        .clk_src(S_AXI_ACLK),
        .resetn_src(S_AXI_ARESETN),
        .clk_dst(clk_int),
        .resetn_dst(resetn_int),
        .valid_src_i(S_AXI_WVALID),
        .data_src_i({S_AXI_WSTRB, S_AXI_WDATA}),
        .ready_src_o(S_AXI_WREADY),
        .data_dst_o({wstrb_int, wdata_int}),
        .valid_dst_o(wvalid_int),
        .ready_dst_i(wready_int)
    );

    hs_async #(
        .D_WIDTH(2)
    ) b_hs_async(
        .clk_src(clk_int),
        .resetn_src(resetn_int),
        .clk_dst(S_AXI_ACLK),
        .resetn_dst(S_AXI_ARESETN),
        .valid_src_i(bvalid_int),
        .data_src_i(2'b0),
        .ready_src_o(bready_int),
        .data_dst_o(S_AXI_BRESP),
        .valid_dst_o(S_AXI_BVALID),
        .ready_dst_i(S_AXI_BREADY)
    );

    hs_async #(
        .D_WIDTH(C_S_AXI_ADDR_WIDTH)
    ) ar_hs_async(
        .clk_src(S_AXI_ACLK),
        .resetn_src(S_AXI_ARESETN),
        .clk_dst(clk_int),
        .resetn_dst(resetn_int),
        .valid_src_i(S_AXI_ARVALID),
        .data_src_i(S_AXI_ARADDR),
        .ready_src_o(S_AXI_ARREADY),
        .data_dst_o(araddr_int),
        .valid_dst_o(arvalid_int),
        .ready_dst_i(arready_int)
    );

    hs_async #(
        .D_WIDTH(C_S_AXI_DATA_WIDTH + 2)
    ) r_hs_async(
        .clk_src(clk_int),
        .resetn_src(resetn_int),
        .clk_dst(S_AXI_ACLK),
        .resetn_dst(S_AXI_ARESETN),
        .valid_src_i(rvalid_int),
        .data_src_i({rdata_int, 2'd0}),
        .ready_src_o(rready_int),
        .data_dst_o({S_AXI_RDATA, S_AXI_RRESP}),
        .valid_dst_o(S_AXI_RVALID),
        .ready_dst_i(S_AXI_RREADY)
    );


    always @ (posedge clk_int) begin
        if(resetn_int == 1'b0) begin
            awready_int     <= 1'b0;
            wready_int      <= 1'b0;
            bvalid_int      <= 1'b0;
        end
        else begin
            if(awvalid_int && wvalid_int) begin
                awready_int     <= 1'b1;
                wready_int      <= 1'b1;
                bvalid_int      <= 1'b1;
            end
            else begin
                if(awvalid_int && awready_int)  awready_int <= 1'b0;
                if(wvalid_int && wready_int)    wready_int  <= 1'b0;
                if(bvalid_int && bready_int)    bvalid_int  <= 1'b0;
            end

        end
    end

    always @ (posedge clk_int) begin
        if(resetn_int == 1'b0) begin
            ctrl_o          <= 2'b0;
            ctrl_strb_o     <= 1'b0;
            format_o        <= 8'd0;
            frames_set_o    <= 32'd0;
            line_size_o     <= 32'd0;
        end
        else begin
            if(wvalid_int && wready_int) begin
                case(awaddr_int)
                REG_ADDR_OV9655CPT_CTRL : begin
                    if(wstrb_int[0]) begin
                        ctrl_o          <= wdata_int[1:0];
                        ctrl_strb_o     <= 1'b1;
                    end
                end
                REG_ADDR_OV9655CPT_FORMAT : begin
                    if(wstrb_int[0])    format_o    <= wdata_int[7:0];
                end
                REG_ADDR_OV9655CPT_FRAMES_SET : begin
                    if(wstrb_int[0])    frames_set_o[7:0]       <= wdata_int[7:0];
                    if(wstrb_int[1])    frames_set_o[15:8]      <= wdata_int[15:8];
                    if(wstrb_int[2])    frames_set_o[23:16]     <= wdata_int[23:16];
                    if(wstrb_int[3])    frames_set_o[31:24]     <= wdata_int[31:24];
                end
                REG_ADDR_OV9655CPT_LINE_SIZE : begin
                    if(wstrb_int[0])    line_size_o[7:0]        <= wdata_int[7:0];
                    if(wstrb_int[1])    line_size_o[15:8]       <= wdata_int[15:8];
                    if(wstrb_int[2])    line_size_o[23:16]      <= wdata_int[23:16];
                    if(wstrb_int[3])    line_size_o[31:24]      <= wdata_int[31:24];
                end
                default : begin
                end
                endcase
            end
            else begin
                ctrl_strb_o     <= 1'b0;
            end
        end
    end

    always @ (posedge clk_int) begin
        if(resetn_int == 1'b0) begin
            arready_int     <= 1'b0;
            rvalid_int      <= 1'b0;
            rdata_int       <= 32'd0;
        end
        else begin
            if(arvalid_int)
                arready_int     <= 1'b1;
            else if(arvalid_int && arready_int)
                arready_int     <= 1'b0;

            if(arvalid_int) begin
                rvalid_int      <= 1'b1;

                case(araddr_int)
                REG_ADDR_OV9655CPT_CTRL :           rdata_int   <= {30'd0, ctrl_o};
                REG_ADDR_OV9655CPT_STATUS :         rdata_int   <= {30'd0, (ctrl_o==2'd1), act_i};
                REG_ADDR_OV9655CPT_FORMAT :         rdata_int   <= {24'd0, format_o};
                REG_ADDR_OV9655CPT_FRAMES_SET :     rdata_int   <= frames_set_o;
                REG_ADDR_OV9655CPT_FRAMES_CUR :     rdata_int   <= frames_cur_i;
                REG_ADDR_OV9655CPT_LINE_SIZE :      rdata_int   <= line_size_o;
                endcase
            end
            else if(rvalid_int && rready_int) begin
                rvalid_int  <= 1'b0;
            end

        end
    end

endmodule
