`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 30.06.2026 11:31:53
// Design Name: 
// Module Name: rptr_empty
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


module rptr_empty #(
    parameter ADDR_WIDTH = 4
)(
    input  logic                 rd_clk,
    input  logic                 rd_rst_n,
    input  logic                 rd_en,
    input  logic [ADDR_WIDTH:0]  wgray_sync,

    output logic [ADDR_WIDTH-1:0] raddr,
    output logic [ADDR_WIDTH:0]   rbin,
    output logic [ADDR_WIDTH:0]   rgray,
    output logic                  empty
);

    logic [ADDR_WIDTH:0] rbinnext;
    logic [ADDR_WIDTH:0] rgraynext;
    logic                empty_next;


    assign rbinnext =
        (rd_en && !empty) ? (rbin + 1'b1) : rbin;


    assign raddr = rbin[ADDR_WIDTH-1:0];

    assign rgraynext = (rbinnext >> 1) ^ rbinnext;

    assign empty_next = (rgraynext == wgray_sync);

    always_ff @(posedge rd_clk or negedge rd_rst_n) begin
        if (!rd_rst_n) begin
            rbin  <= '0;
            rgray <= '0;
            empty <= 1'b1;
        end
        else begin
            rbin  <= rbinnext;
            rgray <= rgraynext;
            empty <= empty_next;
        end
    end

endmodule
