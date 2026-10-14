`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 30.06.2026 11:31:53
// Design Name: 
// Module Name: sync_r2w
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


module sync_r2w #(
    parameter ADDR_WIDTH = 4
)(
    input  logic                 wr_clk,
    input  logic                 wr_rst_n,
    input  logic [ADDR_WIDTH:0]  rgray,

    output logic [ADDR_WIDTH:0]  rgray_sync
);

    logic [ADDR_WIDTH:0] rgray_ff1;

    always_ff @(posedge wr_clk or negedge wr_rst_n) begin
        if (!wr_rst_n) begin
            rgray_ff1  <= '0;
            rgray_sync <= '0;
        end
        else begin
            rgray_ff1  <= rgray;
            rgray_sync <= rgray_ff1;
        end
    end

endmodule
