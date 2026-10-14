# Asynchronous FIFO Design & Verification using SystemVerilog

## Overview

This project implements a parameterized **Asynchronous FIFO (First-In, First-Out)** using Verilog/SystemVerilog. It is designed to transfer data safely between two independent clock domains with different frequencies and phases.

The design uses **binary read/write pointers, Gray-code pointer conversion, clock-domain crossing (CDC) synchronizers, and full/empty detection logic**. A self-checking SystemVerilog testbench verifies FIFO functionality using directed tests, randomized transactions, a scoreboard, and SystemVerilog Assertions (SVA).

## Features

- Parameterized FIFO data width and depth
- Independent read and write clock domains
- Binary read and write pointers
- Gray-code pointer conversion for CDC
- Two-stage synchronizers for crossing pointer information between clock domains
- Full and empty flag generation
- FIFO memory with independent read and write interfaces
- Self-checking SystemVerilog testbench
- Driver, monitor, and scoreboard
- Directed and randomized testing
- SystemVerilog Assertions for interface protocol checks

## Architecture

The FIFO consists of the following major components:

| Module | Responsibility |
|---|---|
| `async_fifo` | Top-level FIFO integration |
| `wptr_full` | Write pointer management and full detection |
| `rptr_empty` | Read pointer management and empty detection |
| `sync_w2r` | Synchronizes the write Gray pointer into the read clock domain |
| `sync_r2w` | Synchronizes the read Gray pointer into the write clock domain |
| `fifomem` | FIFO storage memory |

### Block Diagram

```text
                  ASYNCHRONOUS FIFO
    +------------------------------------------+
    |                                          |
    |  WRITE CLOCK DOMAIN   READ CLOCK DOMAIN  |
    |                                          |
    |  wr_clk                rd_clk            |
    |     |                     |              |
    |     v                     v              |
    | +------------+       +------------+      |
    | | Write      |       | Read       |      |
    | | Pointer    |       | Pointer    |      |
    | | Binary/Gray|       | Binary/Gray|      |
    | +------+-----+       +------+-----+      |
    |        |                    |            |
    |        v                    v            |
    |   +----------+         +----------+      |
    |   | Write-to-|         | Read-to- |      |
    |   | Read Sync|         | Write Sync|     |
    |   +-----+----+         +-----+----+      |
    |         |                    |           |
    |         v                    v           |
    |   Empty Detection       Full Detection   |
    |                                          |
    |           +----------------+             |
    |           |  FIFO Memory   |             |
    |           +----------------+             |
    |                                          |
    +------------------------------------------+
```

The synchronizers transfer Gray-coded pointer information into the opposite clock domain. The local pointer logic uses this synchronized information to generate the `full` and `empty` status flags.

## Parameters

The default configuration is:

| Parameter | Default | Description |
|---|---:|---|
| `DATA_WIDTH` | 8 | Number of bits stored in each FIFO entry |
| `ADDR_WIDTH` | 4 | Number of address bits |
| FIFO Depth | 16 entries | Calculated as \(2^{ADDR\_WIDTH}\) |
| Pointer Width | 5 bits | `ADDR_WIDTH + 1` |

The extra pointer bit tracks wrap-around and helps distinguish a full FIFO from an empty FIFO when the memory addresses are identical.

## Design Details

### 1. Binary Pointers

The read and write pointers identify the current FIFO memory locations. Each pointer contains `ADDR_WIDTH + 1` bits.

- The lower `ADDR_WIDTH` bits select a memory location.
- The additional most significant bit tracks pointer wrap-around.

The write pointer advances only when a write is accepted, and the read pointer advances only when a read is accepted.

### 2. Gray-Code Conversion

Gray code is used for pointer synchronization because consecutive Gray-code values differ by only one bit.

The conversion is:

```systemverilog
gray = (binary >> 1) ^ binary;
```

This reduces the risk of inconsistent multi-bit pointer transitions being observed by the receiving clock domain. Gray coding does not eliminate metastability; the synchronizer stages help reduce its probability of propagating into destination logic.

### 3. Clock-Domain Crossing

The FIFO uses separate synchronizers for the read and write Gray pointers:

- `sync_w2r`: write pointer into the read clock domain
- `sync_r2w`: read pointer into the write clock domain

Each synchronizer uses two flip-flop stages clocked by the destination clock.

### 4. Full Detection

The write-side logic calculates the next write pointer and compares its Gray-coded value against the synchronized read pointer with the appropriate upper bits inverted.

This detects when advancing the write pointer would fill the FIFO.

### 5. Empty Detection

The read-side logic calculates the next read pointer and compares its Gray-coded value with the synchronized write pointer.

When these values match, the FIFO is empty.

### 6. Memory Operation

The FIFO memory stores data written through `wr_data` and addressed by the write pointer. The read address is generated from the read pointer.

Writes are accepted when `wr_en` is asserted and `full` is deasserted. Reads are accepted when `rd_en` is asserted and `empty` is deasserted.

## Interface

| Signal | Direction | Description |
|---|---|---|
| `wr_clk` | Input | Write clock |
| `wr_rst_n` | Input | Active-low write-domain reset |
| `wr_en` | Input | Write enable |
| `wr_data` | Input | Input data |
| `full` | Output | Indicates FIFO is full |
| `rd_clk` | Input | Read clock |
| `rd_rst_n` | Input | Active-low read-domain reset |
| `rd_en` | Input | Read enable |
| `rd_data` | Output | Output data |
| `empty` | Output | Indicates FIFO is empty |

## Verification Methodology

The design is verified using a self-checking SystemVerilog testbench.

### Testbench Components

**Driver**

Generates write and read transactions. It checks the FIFO status before attempting an operation and drives inputs with respect to the relevant clock domain.

**Monitor**

Observes accepted writes and reads at their respective clock edges.

**Scoreboard**

Uses a SystemVerilog queue as a reference model:

- `push_back()` stores expected data after an accepted write.
- `pop_front()` retrieves the oldest expected data after an accepted read.
- Expected and actual output data are compared to detect data mismatches and ordering errors.

**Assertions**

SystemVerilog Assertions are used to check interface protocol rules, including:

- No write request while the FIFO is full.
- No read request while the FIFO is empty.

Pointer-related assertions require careful temporal sampling and validation before being included in the final regression.

## Test Scenarios

The testbench has exercised the following scenarios:

| Test | Purpose |
|---|---|
| Empty FIFO | Check behavior when a read is attempted while empty |
| Full FIFO | Fill the FIFO to its configured depth and exercise full detection |
| Read after full | Read stored data and verify FIFO ordering |
| Normal read/write | Verify basic FIFO functionality |
| Simultaneous read/write | Exercise concurrent operations in both clock domains |
| Pointer wrap-around | Exercise circular memory addressing |
| Random stress test | Generate randomized read/write operations and data |

The randomized test used 100 transaction iterations. The scoreboard output showed matching expected and actual data for the reported reads in the recorded simulation run.

## Simulation and Tools

The project has been simulated using:

- **Language:** Verilog/SystemVerilog
- **Simulation:** Icarus Verilog
- **RTL development and checking:** Xilinx Vivado
- **Verification techniques:** Self-checking testbench, scoreboard, directed tests, randomized testing, and SVA

The testbench uses independent clocks to exercise asynchronous operation.

### Running the Simulation

Add the FIFO RTL source files and `tb_async_fifo.sv` to your simulator project.

For an Icarus Verilog setup, compile the required source files together. For example, adapt the filenames to match your repository:

```bash
iverilog -g2012 -s tb_async_fifo -o fifo_sim \
    async_fifo.sv \
    wptr_full.sv \
    rptr_empty.sv \
    sync_w2r.sv \
    sync_r2w.sv \
    fifomem.sv \
    tb_async_fifo.sv
```

Run the simulation:

```bash
vvp fifo_sim
```

The testbench prints write activity and scoreboard comparisons. A successful data comparison prints `PASS`; a mismatch prints `FAIL`.

**Note:** The command assumes the listed files exist under those names and that the simulator supports the SystemVerilog constructs used by the testbench. Adjust the source list and paths to match the actual project.

## Functional Coverage

Functional coverage is the next planned verification enhancement. The intended coverage goals are:

- FIFO full and empty states
- Accepted write and read operations
- Simultaneous read/write activity
- Pointer wrap-around
- Relevant combinations of interface controls and FIFO status

Coverage results should be reported only after the covergroups are implemented, sampled, and measured in simulation.

## Future Improvements

- Implement and validate functional coverage using covergroups, coverpoints, bins, and cross coverage.
- Add carefully validated pointer increment and pointer stability assertions.
- Add Gray-code transition assertions.
- Verify full and empty flag behavior with dedicated properties.
- Improve regression reporting and test summaries.
- Organize the testbench into reusable verification components.
- Expand randomized testing and add reproducible random seeds.
- Add waveform screenshots and documented simulation results.

## Learning Outcomes

This project demonstrates practical experience with:

- Asynchronous FIFO architecture
- Binary and Gray-code pointer logic
- Clock-domain crossing fundamentals
- FIFO full/empty detection
- SystemVerilog testbench development
- Queue-based scoreboard implementation
- Directed and randomized verification
- SystemVerilog Assertions
- RTL simulation and debugging

## Conclusion

This project combines RTL design and functional verification of a parameterized asynchronous FIFO. It provides hands-on experience with clock-domain crossing, pointer management, FIFO status logic, self-checking verification, and assertion-based protocol checking.

The project is intended as a learning and portfolio project for RTL Design and Design Verification roles.
