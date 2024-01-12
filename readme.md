# Dual Port Distributed RAM
- This is a a simple dual-port distributed RAM. Writes and reads can happen simultaneously in different clock domains.
- There is no interlocking to prevent writing and reading to the same address, so be aware of this.
- The testbench writes random data to random addresses and reads them back and compares. If anything differs, the simulation will fail.
- Open Vivado and run the `build_example_project.tcl` script to create a project and simulate the RAM.