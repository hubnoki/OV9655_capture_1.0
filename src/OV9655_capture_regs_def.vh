
/*
* Name          : OV9655CPT_CTRL
* Direction     : WO
* Description   :
*   Write 0 : Stop capturing immediately
*   Write 1 : Start capturing (Actually starts when next VSYNC is detected)
*   Write 2 : Stop capturing (Actually stops when next VSYNC is detected)
*/
localparam  REG_ADDR_OV9655CPT_CTRL = 16'h0;

/*
* Name          : OV9655CPT_STATUS
* Direction     : RO
* Description   :
*   bit[0]  : capture status, 0 -> IDLE, 1 -> RUNNING
*   bit[1]  : CPU command status, 1 -> Capturing is requested, 0 -> else
*/
localparam  REG_ADDR_OV9655CPT_STATUS = 16'h4;

/*
* Name          : OV9655CPT_FORMAT
* Direction     : R/W
* Description   : bit[7:0] Image data capturing format
*   8'h0 : RGB565 to {8'h0, RED[7:0], GREEN[7:0], BLUE[7:0]}
*/
localparam  REG_ADDR_OV9655CPT_FORMAT = 16'h8;

/*
* Name          : OV9655CPT_FRAMES_SET
* Direction     : R/W
* Description   : bit[31:0] Number of frames to capture
*                 0 -> Capture infinitely
*/
localparam  REG_ADDR_OV9655CPT_FRAMES_SET = 16'hC;

/*
* Name          : OV9655CPT_FRAMES_CUR
* Direction     : RO
* Description   : bit[31:0] Currently captured frames
*/
localparam  REG_ADDR_OV9655CPT_FRAMES_CUR = 16'h10;

/*
* Name          : OV9655CPT_LINE_SIZE
* Direction     : R/W
* Description   : bit[31:0] One line size in bytes
*/
localparam  REG_ADDR_OV9655CPT_LINE_SIZE = 16'h14;
