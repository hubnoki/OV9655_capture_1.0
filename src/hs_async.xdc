
set axi_clk [get_clocks -of_objects [get_ports s00_axi_aclk]]
set axis_clk [get_clocks -of_objects [get_ports m00_axis_aclk]]

set axi_clk_period [get_property PERIOD $axi_clk]
set axis_clk_period [get_property PERIOD $axis_clk]

# aw_hs_async
set_max_delay -from [get_clocks axi_clk] -to [get_pins OV9655_regs_inst/aw_hs_async/data_dst_o_reg[*]/D] [expr {$axis_clk_period * 2}] -datapath_only
# w_hs_async
set_max_delay -from [get_clocks axi_clk] -to [get_pins OV9655_regs_inst/w_hs_async/data_dst_o_reg[*]/D] [expr {$axis_clk_period * 2}] -datapath_only
# b_hs_async
set_max_delay -from [get_clocks axis_clk] -to [get_pins OV9655_regs_inst/b_hs_async/data_dst_o_reg[*]/D] [expr {$axi_clk_period * 2}] -datapath_only
# ar_hs_async
set_max_delay -from [get_clocks axi_clk] -to [get_pins OV9655_regs_inst/ar_hs_async/data_dst_o_reg[*]/D] [expr {$axis_clk_period * 2}] -datapath_only
# r_hs_async
set_max_delay -from [get_clocks axis_clk] -to [get_pins OV9655_regs_inst/r_hs_async/data_dst_o_reg[*]/D] [expr {$axi_clk_period * 2}] -datapath_only

