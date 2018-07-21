
create_clock -period 10 -name axi_clk [get_ports s00_axi_aclk]
create_clock -period 6.67 -name axis_clk [get_ports m00_axis_aclk]
