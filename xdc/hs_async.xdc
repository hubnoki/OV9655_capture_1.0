
set src_clk [get_clocks -of_objects [get_ports -scoped_to_current_instance clk_src]]
set dst_clk [get_clocks -of_objects [get_ports -scoped_to_current_instance clk_dst]]

set src_clk_period [get_property PERIOD $src_clk]
set dst_clk_period [get_property PERIOD $dst_clk]

set_max_delay -from [get_clocks $src_clk] -to [get_pins data_dst_o_reg[*]/D] [expr {$dst_clk_period * 2}] -datapath_only
set_false_path -to [get_pins valid_s_dst_reg[0]/D]
set_false_path -to [get_pins ready_s_src_reg[0]/D]
set_false_path -to [get_pins ready_s_dst_reg[0]/D]


 