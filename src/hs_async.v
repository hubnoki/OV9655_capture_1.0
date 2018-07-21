`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 2018/04/16 02:28:48
// Design Name:
// Module Name: hs_async
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

// History
// 18.04.20 kinoshita
//     Modified ASYNC_REG property notation


module hs_async #(
    parameter D_WIDTH = 32
    )(
    input   wire                        clk_src,
    input   wire                        resetn_src,
    input   wire                        clk_dst,
    input   wire                        resetn_dst,

    input   wire                        valid_src_i,
    input   wire    [D_WIDTH-1 : 0]     data_src_i,
    output  reg                         ready_src_o,

    input   wire                        ready_dst_i,
    output  reg                         valid_dst_o,
    output  reg     [D_WIDTH-1 : 0]     data_dst_o
    );

    reg ack_dst;
    (* ASYNC_REG = "TRUE" *) reg [1:0] valid_s_dst;
    (* ASYNC_REG = "TRUE" *) reg [2:0] ready_s_src;
    (* ASYNC_REG = "TRUE" *) reg [1:0] ready_s_dst;


    always @ (posedge clk_src) begin
        ready_s_src     <= {ready_s_src[1:0], ack_dst};
    end

    always @ (posedge clk_dst) begin
        valid_s_dst     <= {valid_s_dst[0], valid_src_i};
        ready_s_dst     <= {ready_s_dst[0], ready_s_src[1]};
    end

    wire accept_data = (!ack_dst) && valid_s_dst[1] && (!ready_s_dst[1]);

    always @ (posedge clk_dst) begin
        if(resetn_dst == 1'b0) begin
            data_dst_o      <= {(D_WIDTH){1'b0}};
            valid_dst_o     <= 1'b0;
            ack_dst         <= 1'b0;
        end
        else begin
            if(accept_data) data_dst_o      <= data_src_i;

            if(accept_data)         ack_dst       <= 1'b1;
            else if(ready_s_dst[1]) ack_dst       <= 1'b0;

            if(valid_dst_o && ready_dst_i)  valid_dst_o     <= 1'b0;
            else if(accept_data)            valid_dst_o     <= 1'b1;
        end
    end

    always @ (posedge clk_src) begin
        if(resetn_src == 1'b0) begin
            ready_src_o     <= 1'b0;
        end
        else begin
            if(ready_src_o)             ready_src_o     <= 1'b0; // Assuming valid_src_i is still kept
            else if(ready_s_src[2:1] == 2'b01)     ready_src_o     <= 1'b1;

        end
    end

endmodule
