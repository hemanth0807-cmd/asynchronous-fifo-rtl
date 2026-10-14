# Simulation Notes

## Vivado / XSIM

1. Open `asyn_fifo.xpr` in Vivado.
2. Confirm `tb_async_fifo.sv` is selected as the simulation top.
3. Run behavioral simulation.

## Scripted Simulation

The ordered sources are listed in `filelist.f`. Use this file with a SystemVerilog-capable simulator, or import the files in the listed order.

The testbench drives separate write and read clocks and compares read data against an expected-data queue.
