# Asynchronous FIFO Design and Verification

## Overview

This project implements a parameterized, synthesizable **Asynchronous FIFO (First-In, First-Out) buffer** using Verilog/SystemVerilog. It enables reliable data transfer between two independent clock domains without requiring a fixed phase or frequency relationship between the clocks.

The design uses Gray-coded read and write pointers, synchronizer circuits for clock-domain crossing (CDC), and full/empty detection logic. A self-checking SystemVerilog testbench, assertions, and functional coverage are used to verify the design.

## Key Features

- Parameterized data width and FIFO depth.
- Independent read and write clock domains.
- Gray-code pointer synchronization for CDC.
- Synchronized read and write pointers.
- Full and empty flag generation.
- Active-low reset support.
- Self-checking SystemVerilog testbench.
- SystemVerilog Assertions (SVA) for design checks.
- Functional coverage for important FIFO scenarios.
- Simulation and synthesis compatibility.

## Architecture

The FIFO consists of the following major components:

1. **FIFO Memory:** Stores data written in the write clock domain and supplies data to the read interface.
2. **Write Pointer Logic:** Tracks write operations and generates the next write pointer.
3. **Read Pointer Logic:** Tracks read operations and generates the next read pointer.
4. **Binary-to-Gray Conversion:** Converts binary pointers into Gray code to reduce simultaneous bit transitions during CDC.
5. **Pointer Synchronizers:** Synchronize Gray-coded pointers into the opposite clock domain.
6. **Full Detection:** Prevents writes when the FIFO is full.
7. **Empty Detection:** Prevents reads when the FIFO is empty.

### Clock-Domain Crossing

The write and read clocks operate independently. Gray-coded pointers are passed through synchronizer flip-flops before being used in the opposite clock domain.

This architecture reduces the risk of incorrect pointer sampling during clock-domain crossings. Synchronizer circuits reduce metastability propagation risk but do not eliminate metastability entirely.

## Design Parameters

| Parameter | Default Value | Description |
|---|---:|---|
| `DATA_WIDTH` | 8 | Number of bits per data word |
| `ADDR_WIDTH` | 4 | Number of address bits |
| FIFO Depth | 16 | Calculated as \(2^{ADDR\_WIDTH}\) |

## Interface

### Write Interface

| Signal | Description |
|---|---|
| `wr_clk` | Write-domain clock |
| `wr_rst_n` | Active-low write-domain reset |
| `wr_en` | Write enable |
| `wr_data` | Input data |
| `full` | Indicates that the FIFO is full |

### Read Interface

| Signal | Description |
|---|---|
| `rd_clk` | Read-domain clock |
| `rd_rst_n` | Active-low read-domain reset |
| `rd_en` | Read enable |
| `rd_data` | Output data |
| `empty` | Indicates that the FIFO is empty |

## Verification Strategy

The design is verified using a self-checking SystemVerilog testbench.

The verification strategy includes:

- Reset and initial empty-state checks.
- Normal write and read operations.
- FIFO full-condition testing.
- FIFO empty-condition testing.
- Data-integrity checks.
- Back-to-back transactions.
- Independent read and write clocks.
- Assertion-based checks for important design properties.
- Functional coverage of key operating scenarios.

The testbench compares expected and observed data to identify functional mismatches.

## Tools Used

- **HDL:** Verilog/SystemVerilog
- **Simulation:** Icarus Verilog 12.0
- **Waveform Analysis:** GTKWave
- **Synthesis and Design Validation:** AMD/Xilinx Vivado
- **Verification:** Self-checking testbench, SVA, functional coverage

## Running the Simulation

The following commands are examples. Adjust the source filenames and module names to match the actual repository structure.

### Compile

```bash
iverilog -g2012 -o fifo_sim \
  async_fifo.sv tb_async_fifo.sv
```

### Run

```bash
vvp fifo_sim
```

### View Waveforms

```bash
gtkwave dump.vcd
```

Ensure that waveform dumping is enabled in the testbench before opening `dump.vcd`.

**Note:** Icarus Verilog has limitations in support for some SystemVerilog Assertions and functional coverage constructs. If these features are not supported by your simulator, use a compatible simulator or run the relevant checks separately.

## Key Learning Outcomes

- Designing parameterized RTL modules.
- Understanding asynchronous FIFO architecture.
- Implementing binary and Gray-code pointer logic.
- Handling clock-domain crossing in digital systems.
- Designing FIFO full and empty detection logic.
- Developing self-checking verification environments.
- Using assertions and functional coverage.
- Debugging RTL simulations and analyzing waveforms.

## Applications

Asynchronous FIFOs are commonly used in:

- System-on-Chip (SoC) interconnects.
- Processor and peripheral interfaces.
- Digital communication systems.
- Multi-clock FPGA designs.
- Data buffering between independent hardware blocks.

## Future Improvements

- Formal verification of FIFO safety properties.
- Randomized stress testing across different clock ratios.
- Additional CDC analysis and synchronizer review.
- Synthesis and timing reports for FPGA or ASIC implementation.
- Improved functional coverage and regression automation.

---

**Project Focus:** RTL Design | SystemVerilog | CDC | Digital Design Verification | SVA
