`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 30.06.2026 11:31:53
// Design Name: 
// Module Name: wptr_full
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


module wptr_full #(
    parameter ADDR_WIDTH = 4
)(
    input  logic                  wr_clk,
    input  logic                  wr_rst_n,
    input  logic                  wr_en,
    input  logic [ADDR_WIDTH:0]   rgray_sync,

    output logic [ADDR_WIDTH-1:0] waddr,
    output logic [ADDR_WIDTH:0]   wbin,
    output logic [ADDR_WIDTH:0]   wgray,
    output logic                  full
);

    logic [ADDR_WIDTH:0] wbinnext;
    logic [ADDR_WIDTH:0] wgraynext;
    logic                full_next;

    assign wbinnext =
        (wr_en && !full) ? (wbin + 1'b1) : wbin;

    assign waddr = wbin[ADDR_WIDTH-1:0];

    assign wgraynext = (wbinnext >> 1) ^ wbinnext;

    assign full_next =
        (wgraynext ==
         {~rgray_sync[ADDR_WIDTH:ADDR_WIDTH-1],
           rgray_sync[ADDR_WIDTH-2:0]});

    always_ff @(posedge wr_clk or negedge wr_rst_n) begin
        if (!wr_rst_n) begin
            wbin  <= '0;
            wgray <= '0;
            full  <= 1'b0;
        end
        else begin
            wbin  <= wbinnext;
            wgray <= wgraynext;
            full  <= full_next;
        end
    end

endmodule
