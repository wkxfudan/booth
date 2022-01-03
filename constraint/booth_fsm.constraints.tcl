#*******************************************************************
#set design optimization constraints
#*******************************************************************
create_clock -name clock_main -period 5 [get_ports "clk"]

set_clock_latency      0.05 [get_clocks "clock_main"]
set_clock_uncertainty  1.5 -setup [get_clocks "clock_main"]
set_clock_uncertainty  0.05 -hold [get_clocks "clock_main"]
set_clock_transition   0.05 [get_clocks "clock_main"]


#clock_main 
set_input_delay  -max 1 	-clock clock_main [remove_from_collection [all_inputs] [get_ports  "clk"]]
set_input_delay  -min 0.1 	-clock clock_main [remove_from_collection [all_inputs] [get_ports  "clk"]]
set_output_delay -max 1 	-clock clock_main [all_outputs]
set_output_delay -min 0.1 	-clock clock_main [all_outputs]


#*******************************************************************
#set design rule constraints
#*******************************************************************

set_ideal_network [get_ports "rstn"]
set_ideal_network [get_ports "clk"]

#set_driving_cell -lib_cell "PSBI8N"  -from_pin "A" -pin "P" [all_inputs]

group_path -name REGOUT      -to   [all_outputs] 
group_path -name REGIN       -from [remove_from_collection [all_inputs] [get_ports "clk"]] 
group_path -name FEEDTHROUGH -from [remove_from_collection [all_inputs] [get_ports "clk"]] -to [all_outputs]

