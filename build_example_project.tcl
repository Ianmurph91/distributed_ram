set buid_dir [ file dirname [ file normalize [ info script ] ] ]

create_project -force distributed_RAM ${buid_dir}/distributed_RAM -part xc7z014sclg484-1

import_files -fileset sources_1 -norecurse ${buid_dir}/RAM.vhd
update_compile_order -fileset sources_1

set_property SOURCE_SET sources_1 [get_filesets sim_1]
import_files -fileset sim_1 -norecurse ${buid_dir}/testbench.sv
update_compile_order -fileset sim_1

launch_simulation
open_wave_config ${buid_dir}/testbench_behav.wcfg
restart
run 2000 ns