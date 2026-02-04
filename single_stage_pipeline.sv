`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04.02.2026 20:31:49
// Design Name: 
// Module Name: single_stage_pipeline
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


module single_stage_pipeline#(parameter WIDTH=32)(
//Global Signals
input logic clk,rst_n,

//Input Interface
input logic in_valid,
input logic [WIDTH-1:0] in_data,
output logic in_ready,

//Output Interface
output logic out_valid,
output logic [WIDTH-1:0] out_data,
input logic out_ready
 );
 
 // Pipeline registers
 logic [WIDTH-1:0] data_reg;
 logic valid_reg;
/* 
 assign in_ready = (~valid_reg) || out_ready ;
 
 // Output assignments
 assign out_data  = data_reg;
 assign out_valid = valid_reg;
 
 always_ff@(posedge clk or negedge rst_n) begin
 
 if(~rst_n)
 begin
 valid_reg <= 1'b0;          // Empty state on reset
 data_reg  <= '0;
 end

 else begin
 
 // Load new data when handshake occurs
 if (in_valid && in_ready) begin
 data_reg  <= in_data;
 valid_reg <= 1'b1;
 end
 // Clear valid when downstream accepts data
 else if (out_ready && out_valid && valid_reg) begin
 valid_reg <= 1'b0;
 //out_data  <= data_reg;
 //out_valid <= 1;
 end
 
 else if(~out_ready) in_ready <=0;

 end
 end

 */
 
 
    // Wire declarations
    logic will_accept_data;
    logic will_consume_data;
    
    // Determine what will happen on next clock edge
    assign will_accept_data = in_valid && in_ready;
    assign will_consume_data = out_valid && out_ready;
    
    // The register update
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            data_reg  <= '0;
            valid_reg <= 1'b0;
        end else begin
            case ({will_accept_data, will_consume_data})
                2'b00: begin // Nothing happens
                    // Keep current state
                end
                2'b01: begin // Only consumption
                    valid_reg <= 1'b0;
                end
                2'b10: begin // Only acceptance
                    data_reg  <= in_data;
                    valid_reg <= 1'b1;
                end
                2'b11: begin // Both accept and consume (pass-through)
                    data_reg  <= in_data;
                    valid_reg <= 1'b1;  // Stays valid with new data
                end
            endcase
        end
    end
    
    // Outputs
assign out_data  = data_reg;
assign out_valid = valid_reg;
    
    // Input ready logic - CRITICAL
    // We're ready when:
    // 1. Register is empty (no data)
    // 2. Data will be consumed this cycle (making room)
assign in_ready = !valid_reg || (out_ready);

endmodule
