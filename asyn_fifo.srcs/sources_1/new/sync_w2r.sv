`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 30.06.2026 11:31:53
// Design Name: 
// Module Name: sync_w2r
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


module sync_w2r #(
    parameter ADDR_WIDTH = 4
)(
    input  logic                 rd_clk,
    input  logic                 rd_rst_n,
    input  logic [ADDR_WIDTH:0]  wgray,

    output logic [ADDR_WIDTH:0]  wgray_sync
);

    logic [ADDR_WIDTH:0] wgray_ff1;

    always_ff @(posedge rd_clk or negedge rd_rst_n) begin
        if (!rd_rst_n) begin
            wgray_ff1  <= '0;
            wgray_sync <= '0;
        end
        else begin
            wgray_ff1  <= wgray;
            wgray_sync <= wgray_ff1;
        end
    end

endmodule
