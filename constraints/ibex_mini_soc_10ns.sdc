################################################################################
# Ibex Mini SoC baseline functional constraints
################################################################################

create_clock -name clk -period 10.000 [get_ports clk_i]

set_clock_uncertainty 0.100 [get_clocks clk]
set_clock_transition 0.100 [get_clocks clk]

set_input_delay 1.000 -clock clk [get_ports {gpio_i* imem_we_i imem_waddr_i* imem_wdata_i*}]
set_output_delay 1.000 -clock clk [all_outputs]

set_false_path -from [get_ports rst_ni]
