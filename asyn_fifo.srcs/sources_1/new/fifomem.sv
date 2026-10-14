`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 30.06.2026 11:31:53
// Design Name: 
// Module Name: fifomem
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


module fifomem #(
    parameter DATA_WIDTH = 8,
    parameter ADDR_WIDTH = 4
)(
    input  logic                   wr_clk,
    input  logic                   do_write,

    input  logic [ADDR_WIDTH-1:0]  waddr,
    input  logic [ADDR_WIDTH-1:0]  raddr,

    input  logic [DATA_WIDTH-1:0]  wr_data,

    output logic [DATA_WIDTH-1:0]  rd_data
);

    localparam DEPTH = 1 << ADDR_WIDTH;

    logic [DATA_WIDTH-1:0] mem [0:DEPTH-1];

    always_ff @(posedge wr_clk) begin
        if (do_write)
            mem[waddr] <= wr_data;
    end
 
    assign rd_data = mem[raddr];

endmodule
