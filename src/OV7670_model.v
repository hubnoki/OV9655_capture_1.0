`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 2016/04/01 15:32:53
// Design Name:
// Module Name: OV7670_model
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


module OV7670_model #(
    parameter OV7670_VSYNC_WIDTH = 3, // VSYNC pulse width by lines
    parameter OV7670_VSYNC_TO_HREF = 17, // by lines
    parameter OV7670_HREF_TO_VSYNC = 10, // by lines
    parameter OV7670_HREF_BLANK = 144, // period between two HREF pulses by pixels
    parameter OV7670_HSIZE = 640,
    parameter OV7670_VSIZE = 480,
    parameter OV7670_R_STARTV = 8'h0,
    parameter OV7670_G_STARTV = 8'h4,
    parameter OV7670_B_STARTV = 8'h8
)
    (
    input wire XCLK,
    output wire PCLK,
    input wire RESETN,
    output wire HREF,
    output wire VSYNC,
    output wire [7:0] DATA,

    input wire [31:0] PIXEL_FORMAT
    );


    reg [31:0] line_count, h_cnt;

    reg [7:0] data_r, data_g, data_b;
    reg byte_pos;

    reg href_int;
    reg valid_line;


    localparam PIXEL_FORMAT_RGB444 = 32'h0;
    localparam PIXEL_FORMAT_RGB565 = 32'h1;
    localparam PIXEL_FORMAT_RGB555 = 32'h2;

    function [7:0] RGBdata_to_8bits;
        input [7:0] input_r, input_g, input_b;
        input input_byte_pos;
        input[31:0] input_pformat;

        case(input_pformat)
            PIXEL_FORMAT_RGB444 : RGBdata_to_8bits =
                (~input_byte_pos ? {4'b0, input_r[3:0]} : {input_g[3:0], input_b[3:0]});
            PIXEL_FORMAT_RGB565 : RGBdata_to_8bits =
                (~input_byte_pos ? {input_r[4:0], input_g[5:3]} : {input_g[2:0], input_b[4:0]});
            PIXEL_FORMAT_RGB555 : RGBdata_to_8bits =
                (~input_byte_pos ? {1'b0, input_r[4:0], input_g[4:3]} : {input_g[2:0], input_b[4:0]});
            default : RGBdata_to_8bits = 8'h0;
        endcase

    endfunction


    always @(negedge XCLK) begin
        if(RESETN == 1'b0)
            byte_pos <= 1'b0;
        // else if(href_advanced)
        else if(href_int)
            byte_pos <= ~byte_pos;
        else
            byte_pos <= 1'b0;
    end

    always @(negedge XCLK) begin
        if(RESETN == 1'b0) begin
            data_r <= OV7670_R_STARTV;
            data_g <= OV7670_G_STARTV;
            data_b <= OV7670_B_STARTV;
        end
        // else if(HREF && (~byte_pos)) begin
        else if(href_int && (byte_pos == 1'b1)) begin
            data_r <= data_r + 8'b1;
            data_g <= data_g + 8'b1;
            data_b <= data_b + 8'b1;
        end
    end

    wire h_cnt_up = (h_cnt == (OV7670_HSIZE * 2 + OV7670_HREF_BLANK) - 1);

    always @(negedge XCLK) begin
        if(RESETN == 1'b0)
            h_cnt <= 32'b0;
        else if(h_cnt_up)
            h_cnt <= 32'b0;
        else
            h_cnt <= h_cnt + 32'b1;
    end

    localparam TOTAL_LINES = OV7670_VSYNC_WIDTH + OV7670_VSYNC_TO_HREF + OV7670_VSIZE + OV7670_HREF_TO_VSYNC;

    always @(negedge XCLK) begin
        if(RESETN == 1'b0) begin
            line_count  <= 32'b0;
            valid_line  <= 1'b0;
            href_int    <= 1'b0;
        end
        else begin
            if(h_cnt_up) begin
                if( line_count == TOTAL_LINES - 1 )
                    line_count  <= 32'b0;
                else
                    line_count  <= line_count + 32'b1;
            end

            valid_line  <=
                (line_count == OV7670_VSYNC_WIDTH + OV7670_VSYNC_TO_HREF - 1) && h_cnt_up
                    ? 1'b1 :
                (line_count == OV7670_VSYNC_WIDTH + OV7670_VSYNC_TO_HREF + OV7670_VSIZE - 1) && h_cnt_up
                    ? 1'b0 :
                    valid_line;

            href_int    <= valid_line && (h_cnt < OV7670_HSIZE * 2);
        end
    end

    assign HREF = href_int;

    assign VSYNC = RESETN && (line_count < OV7670_VSYNC_WIDTH);

    assign DATA = RGBdata_to_8bits(data_r, data_g, data_b, byte_pos, PIXEL_FORMAT);
    assign PCLK = XCLK;



endmodule
