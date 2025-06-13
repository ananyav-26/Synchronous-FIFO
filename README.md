This project implements and tests a parameterized synchronous FIFO (First-In First-Out) buffer in SystemVerilog. It includes a clean testbench with waveform dumping enabled. The FIFO supports simultaneous read/write operations on a shared clock, with correct `full` and `empty` signaling. This is a common design used in buffering data between two subsystems running on the same clock domain.

## Features

- Parameterized `DEPTH` and `DATA_WIDTH`
- Proper full/empty logic
- Synthesizable SystemVerilog code
- Testbench with:
  - Randomized writes and reads
  - FIFO behavior verification using a queue
  - VCD waveform dump for analysis
 
## Output
RTL Schematic:
Output Waveform: 
