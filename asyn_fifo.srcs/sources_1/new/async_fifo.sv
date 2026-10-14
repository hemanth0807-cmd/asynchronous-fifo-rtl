`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 30.06.2026 11:31:53
// Design Name: 
// Module Name: async_fifo
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module async_fifo #(
    parameter DATA_WIDTH = 8,
    parameter ADDR_WIDTH = 4
)(

    input  logic                   wr_clk,
    input  logic                   wr_rst_n,
    input  logic                   wr_en,
    input  logic [DATA_WIDTH-1:0]  wr_data,
    output logic                   full,

    input  logic                   rd_clk,
    input  logic                   rd_rst_n,
    input  logic                   rd_en,
    output logic [DATA_WIDTH-1:0]  rd_data,
    output logic                   empty
);

 
    logic [ADDR_WIDTH:0]   wbin;
    logic [ADDR_WIDTH:0]   wgray;

    logic [ADDR_WIDTH:0]   rbin;
    logic [ADDR_WIDTH:0]   rgray;

    logic [ADDR_WIDTH:0]   wgray_sync;
    logic [ADDR_WIDTH:0]   rgray_sync;

    logic [ADDR_WIDTH-1:0] waddr;
    logic [ADDR_WIDTH-1:0] raddr;

    logic                  do_write;

 
    assign do_write = wr_en && !full;

  
    wptr_full #(
        .ADDR_WIDTH(ADDR_WIDTH)
    ) u_wptr (
        .wr_clk(wr_clk),
        .wr_rst_n(wr_rst_n),
        .wr_en(wr_en),
        .rgray_sync(rgray_sync),

        .waddr(waddr),
        .wbin(wbin),
        .wgray(wgray),
        .full(full)
    );

    
    rptr_empty #(
        .ADDR_WIDTH(ADDR_WIDTH)
    ) u_rptr (
        .rd_clk(rd_clk),
        .rd_rst_n(rd_rst_n),
        .rd_en(rd_en),
        .wgray_sync(wgray_sync),

        .raddr(raddr),
        .rbin(rbin),
        .rgray(rgray),
        .empty(empty)
    );


    sync_w2r #(
        .ADDR_WIDTH(ADDR_WIDTH)
    ) u_sync_w2r (
        .rd_clk(rd_clk),
        .rd_rst_n(rd_rst_n),
        .wgray(wgray),

        .wgray_sync(wgray_sync)
    );



    sync_r2w #(
        .ADDR_WIDTH(ADDR_WIDTH)
    ) u_sync_r2w (
        .wr_clk(wr_clk),
        .wr_rst_n(wr_rst_n),
        .rgray(rgray),

        .rgray_sync(rgray_sync)
    );


    fifomem #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH)
    ) u_mem (
        .wr_clk(wr_clk),
        .do_write(do_write),

        .waddr(waddr),
        .raddr(raddr),

        .wr_data(wr_data),
        .rd_data(rd_data)
    );

endmodule
