`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/29/2014 04:03:16 PM
// Design Name: 
// Module Name: Match
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


module Match(
    input clk,
    input reset,
    input en_proc,
    // programming interface
    // inputs
    input wire io_clk,                    // programming clock
    input wire io_sel,                    // this module has been selected for an I/O operation
    input wire io_sync,                    // start the I/O operation
    input wire [23:0] io_addr,        // slave address, memory or register. Top 16 bits already consumed.
    input wire io_rd_en,                // this is a read operation
    input wire io_wr_en,                // this is a write operation
    input wire [31:0] io_wr_data,    // data to write for write operations
    // outputs
    output wire [31:0] io_rd_data,    // data returned for read operations
    output wire io_rd_ack,                // 'read' data from this module is ready
    //clocks
    input wire [2:0] BX,
    input wire first_clk,
    input wire not_first_clk,
    
    input [11:0] data_in,
    
    output reg [5:0] number_out,
    input [5:0] read_add,
    output reg [11:0] data_out
    );

    // no IPbus here yet
    assign io_rd_data[31:0] = 32'h00000000;
    assign io_rd_ack = 1'b0;
    
    reg [11:0] data_in_dly;
    reg [5:0] wr_add;
    reg wr_en;
    
    reg [6:0] clk_cnt;
    reg [2:0] BX_pipe;
    reg first_clk_pipe;
    
    initial begin
        clk_cnt = 7'b0;
        BX_pipe = 3'b111;
    end
    
    always @(posedge clk) begin
        if(en_proc)
            clk_cnt <= clk_cnt + 1'b1;
        else begin
            clk_cnt <= 7'b0;
            BX_pipe <= 3'b111;
        end
        if(clk_cnt == 7'b1) begin
            BX_pipe <= BX_pipe + 1'b1;
            first_clk_pipe <= 1'b1;
        end
        else begin
            first_clk_pipe <= 1'b0;
        end
    end
    
    wire [11:0] pre_data_out;
    
    always @(posedge clk) begin
        if(first_clk_pipe) begin
            //data_in_dly <= 12'hfff;
            wr_add <= 6'h3f;
            number_out <= wr_add + 1'b1;
        end
        else begin
            //number_out <= 0;
            data_in_dly <= data_in;
            if(data_in != 12'hfff & data_in != data_in_dly) begin
                wr_add <= wr_add + 1'b1;
                wr_en <= 1'b1;
            end
            else begin
                wr_add <= wr_add;
                wr_en <= 1'b0;
            end
        end
        data_out <= pre_data_out;
    end

    Memory #(12,9,"D:/GLIB Firmware/branches/jectest/prj/viv_1/project_2/full.txt") Match(
        // Output
        .output_data(pre_data_out),
        // Input
        .clock(clk),
        .write_address({BX_pipe-3'b011,wr_add}),
        .write_enable(wr_en),
        .read_address({BX_pipe-3'b100,read_add}),
        .input_data(data_in_dly)
    );
endmodule
