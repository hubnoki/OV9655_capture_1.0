`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 2018/04/08 16:24:36
// Design Name:
// Module Name: OV9655_if
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


module OV9655_if#(
    parameter C_XCLK_DIV = 8'd3, // Half period of XCLK in "clk" count
    parameter C_DATA_WIDTH = 32 // Supported data width : 32, 64
    )(
    input   wire            clk,
    input   wire            resetn,

    input   wire    [1:0]   ctrl_i,
    input   wire            ctrl_strb_i,

    output  reg             act_o,
    input   wire    [7:0]   format_i,
    input   wire    [31:0]  frames_set_i,
    output  reg     [31:0]  frames_cur_o,
    input   wire    [31:0]  line_size_i,

    input   wire            pclk_i,
    input   wire    [9:0]   dat_i,
    input   wire            href_i,
    input   wire            vsync_i,
    output  reg             xclk_o,

    output  wire            fsync_o,
    output  reg             sof_o,

    output  reg     [C_DATA_WIDTH-1:0]  dat_o,
    output  reg     [C_DATA_WIDTH/8-1:0]   dat_strb_o,
    output  reg             valid_o,
    output  reg             last_o,
    input   wire            ready_i
    );

//-----------------------------------------------------------------------------
    // Synchronizer
    (* ASYNC_REG = "TRUE" *) reg             pclk_s1, pclk_s2;
    reg             pclk_s3;
    (* ASYNC_REG = "TRUE" *) reg     [9:0]   dat_s1, dat_s2;
    (* ASYNC_REG = "TRUE" *) reg             vsync_s1, vsync_s2;
    (* ASYNC_REG = "TRUE" *) reg             href_s1, href_s2;

    always @ (posedge clk) begin
        if(resetn == 1'b0) begin
            pclk_s1     <= 1'b0;
            pclk_s2     <= 2'b0;
            dat_s1      <= 10'd0;
            dat_s2      <= 10'd0;
            vsync_s1    <= 1'b0;
            vsync_s2    <= 1'b0;
            href_s1     <= 1'b0;
            href_s2     <= 1'b0;
        end
        else begin
            pclk_s1     <= pclk_i;
            pclk_s2     <= pclk_s1;
            pclk_s3     <= pclk_s2;
            dat_s1      <= dat_i;
            dat_s2      <= dat_s1;
            vsync_s1    <= vsync_i;
            vsync_s2    <= vsync_s1;
            href_s1     <= href_i;
            href_s2     <= href_s1;
        end
    end

    wire pclk_rise = pclk_s2 & (~pclk_s3);
    wire dat_valid = pclk_rise & href_s2;

    assign fsync_o = vsync_s2;

//-----------------------------------------------------------------------------
    reg     [7:0]   xclk_cnt;

    always @(posedge clk) begin
        if(resetn == 1'b0) begin
            xclk_cnt    <= 8'd0;
            xclk_o      <= 1'b0;
        end
        else begin
            if(xclk_cnt >= C_XCLK_DIV - 8'd1) begin
                xclk_cnt    <= 8'd0;
                xclk_o      <= ~xclk_o;
            end
            else
                xclk_cnt    <= xclk_cnt + 8'd1;
        end
    end
//-----------------------------------------------------------------------------

    localparam  C_DATA_WORDS = C_DATA_WIDTH / 32;

    reg             act_ready;
    reg     [7:0]   format_reg;
    reg     [31:0]  line_size_reg;
    reg     [31:0]  size_tmp;
    reg             vsync_d;
    reg             byte_pos;

    reg     [31:0]  dat_int;
    reg             valid_int;
    reg             last_int;
    reg             sof_ready;
    reg             sof_int;

    wire dat_valid_fmt0 = (byte_pos == 1'b1) && pclk_rise;

    always @(posedge clk) begin
        if (resetn == 1'b0) begin
            act_o       <= 1'b0;
            act_ready   <= 1'b0;

            frames_cur_o    <= 32'd0;

            format_reg  <= 8'd0;
            line_size_reg  <= 32'd0;

            vsync_d     <= 1'b0;

            dat_int     <= 32'd0;
            byte_pos    <= 1'b0;
            valid_int   <= 1'b0;
            size_tmp    <= 32'd0;
            last_int    <= 1'b0;

            sof_ready   <= 1'b0;
            sof_int     <= 1'b0;
        end else begin
            act_ready   <=
                (ctrl_i == 2'b0) && ctrl_strb_i ? 1'b0 :
                (ctrl_i == 2'b1) && ctrl_strb_i ? 1'b1 :
                act_ready && vsync_s2           ? 1'b0 : act_ready;

            act_o   <=
                (ctrl_i == 2'b0)                ? 1'b0 :
                (ctrl_i == 2'd2) && vsync_s2    ? 1'b0 :
                act_ready && vsync_s2           ? 1'b1 :
                act_o && (frames_cur_o == frames_set_i - 32'd1) && vsync_s2
                                                ? 1'b0 : act_o;

            if(pclk_rise)   vsync_d <= vsync_s2;

            frames_cur_o    <=
                (ctrl_i == 2'b0)                    ? 32'd0 :
                (ctrl_i == 2'b1) && ctrl_strb_i     ? 32'd0 :
                act_o && (!vsync_d) && vsync_s2     ? frames_cur_o + 32'd1 :
                                                    frames_cur_o;

            if(!act_o) begin
                format_reg      <= format_i;
                line_size_reg  <= line_size_i;
            end

            case(format_reg)
            8'd0 : begin
                dat_int[31 : 24] <= 8'd0;

                if(!act_o) begin
                    size_tmp    <= 32'd0;
                    byte_pos    <= 1'b0;
                end
                else if(!href_s2) begin
                    size_tmp    <= 32'd0;
                    byte_pos    <= 1'b0;
                end
                else if(pclk_rise) begin
                    if(byte_pos == 1'b0) begin
                        dat_int[23:16]  <=  {3'd0, dat_s2[9:5]};        // R
                        dat_int[15:8]   <=  {2'd0, dat_s2[4:2], 3'd0};  // G
                        byte_pos        <= 1'b1;
                    end
                    else if(byte_pos == 1'b1) begin
                        dat_int[15:8]   <=  {2'd0, dat_int[13:11], dat_s2[9:7]};  //G
                        dat_int[7:0]    <=  {3'd0, dat_s2[6:2]};        // B
                        byte_pos        <= 1'b0;
                        size_tmp        <= size_tmp + 32'd4;
                    end
                end
                valid_int   <= dat_valid_fmt0;
                last_int    <= dat_valid_fmt0
                                && (size_tmp >= line_size_reg - 32'd4);
                sof_ready   <=
                    vsync_d && vsync_s2             ? 1'b1 :
                    sof_ready && dat_valid_fmt0     ? 1'b0 :
                    sof_ready;
                sof_int     <= sof_ready && dat_valid_fmt0;

            end
            default : begin
                dat_int         <= 64'd0;
                valid_int       <= 1'b0;
                size_tmp        <= 32'd0;
                last_int        <= 1'b0;
                sof_int         <= 1'b0;
            end
            endcase


        end

    end


    //-----------------------------------------------------------------------------

    // function called clogb2 that returns an integer which has the
	// value of the ceiling of the log base 2.
	function integer clogb2 (input integer bit_depth);
	  begin
	    for(clogb2=0; bit_depth>0; clogb2=clogb2+1)
	      bit_depth = bit_depth >> 1;
	  end
	endfunction


    localparam  BUF_DEPTH = 16;
    localparam  BUF_P_WIDTH = clogb2(BUF_DEPTH-1);
    reg    [31 : 0]     buf_dat [0 : BUF_DEPTH - 1];
    reg    [0 : 0]      buf_last [0 : BUF_DEPTH - 1];
    reg    [0 : 0]      buf_sof [0 : BUF_DEPTH - 1];

    reg    [BUF_P_WIDTH - 1 : 0]    p_wr, p_rd;
    reg    [BUF_P_WIDTH - 1 : 0]    n_buf;

    reg     [7:0]   dat_o_word_cnt;

    wire ack = valid_o && ready_i;
    wire rden = (((!valid_o) || ack) && (n_buf != 8'd0));

    always @(posedge clk) begin
        if (resetn == 1'b0) begin
            p_wr        <= 'd0;
            p_rd        <= 'd0;
            n_buf       <= 'd0;
        end
        else begin

            n_buf <=
                rden && valid_int   ? n_buf :
                rden                ? n_buf - 8'd1 :
                valid_int           ? n_buf + 8'd1 : n_buf;

            p_rd        <= rden         ? p_rd + 8'd1 : p_rd;

            if(valid_int) begin
                p_wr            <= p_wr + 8'd1;
                buf_dat[p_wr]   <= dat_int;
                buf_last[p_wr]  <= last_int;
                buf_sof[p_wr]   <= sof_int;
            end

        end
    end

    generate
    begin
        if(C_DATA_WIDTH == 32) begin
            always @(posedge clk) begin
                if(resetn == 1'b0) begin
                    valid_o         <= 1'b0;
                    dat_o           <= 32'd0;
                    last_o          <= 1'b0;
                    dat_o_word_cnt  <= 8'd0;
                    dat_strb_o  <= 4'hF;
                    sof_o       <= 1'b0;
                end
                else begin
                    if(rden) begin
                        dat_o   <= buf_dat[p_rd];
                        last_o  <= buf_last[p_rd];
                        sof_o   <= buf_sof[p_rd];
                        valid_o     <= 1'b1;
                    end
                    else if(ack) begin
                        sof_o   <= 1'b0;
                        valid_o   <= 1'b0;
                        last_o  <= 1'b0;
                    end
                    dat_strb_o  <= 4'hF;
                end
            end
        end
        else if(C_DATA_WIDTH == 64) begin
            reg sof0;

            always @(posedge clk) begin
                if(resetn == 1'b0) begin
                    valid_o         <= 1'b0;
                    dat_o           <= 64'd0;
                    last_o          <= 1'b0;
                    dat_o_word_cnt  <= 8'd0;
                    dat_strb_o  <= 8'hFF;
                    sof0        <= 1'b0;
                    sof_o       <= 1'b0;
                end
                else begin
                    if(rden) begin
                        dat_o_word_cnt[0] <= ~dat_o_word_cnt[0];
                        if(dat_o_word_cnt == 8'd0) begin
                            dat_o[31:0] <= buf_dat[p_rd];
                            sof0        <= buf_sof[p_rd];
                            last_o      <= 1'b0;
                            sof_o       <= 1'b0;
                            valid_o     <= 1'b0;
                        end
                        else if(dat_o_word_cnt == 8'd1) begin
                            dat_o[63:32]    <= buf_dat[p_rd];
                            sof_o           <= sof0;
                            last_o          <= buf_last[p_rd];
                            valid_o         <= 1'b1;
                        end
                    end
                    else if(ack) begin
                        sof_o       <= 1'b0;
                        last_o      <= 1'b0;
                        valid_o     <= 1'b0;
                    end

                end
            end

        end
        else begin
            always @(posedge clk) begin
                    dat_o           <= 'd0;
                    last_o          <= 1'b0;
                    sof_o           <= 1'b0;
                    dat_o_word_cnt  <= 8'd0;
                    dat_strb_o      <= 8'hFF;
                    $display("OV9655_capture :: Unsupported Data width");
            end
        end

    end
    endgenerate


endmodule
