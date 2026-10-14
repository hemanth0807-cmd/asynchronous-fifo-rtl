# Asynchronous FIFO RTL

Parameterized asynchronous FIFO implemented in SystemVerilog for independent write and read clock domains.

## Project Contents

- `asyn_fifo.srcs/sources_1/new/async_fifo.sv` - top-level FIFO module.
- `asyn_fifo.srcs/sources_1/new/fifomem.sv` - storage array.
- `asyn_fifo.srcs/sources_1/new/wptr_full.sv` - write pointer and full flag logic.
- `asyn_fifo.srcs/sources_1/new/rptr_empty.sv` - read pointer and empty flag logic.
- `asyn_fifo.srcs/sources_1/new/sync_w2r.sv` - write pointer synchronizer into read clock domain.
- `asyn_fifo.srcs/sources_1/new/sync_r2w.sv` - read pointer synchronizer into write clock domain.
- `asyn_fifo.srcs/sim_1/new/tb_async_fifo.sv` - self-checking testbench with independent write/read clocks.
- `asyn_fifo.xpr` - Vivado project file.
- `filelist.f` - ordered source list for simulators or scripted builds.

## Design Notes

The FIFO uses Gray-coded read and write pointers with two-flop synchronization across clock domains. Writes are accepted when `wr_en` is asserted and the FIFO is not full. Reads are accepted when `rd_en` is asserted and the FIFO is not empty.

Default parameters:

- `DATA_WIDTH = 8`
- `ADDR_WIDTH = 4`

## Simulation

See `docs/SIMULATION.md` for simulation guidance.
