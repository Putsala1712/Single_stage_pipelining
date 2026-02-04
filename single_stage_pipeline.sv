`timescale 1ns / 1ps

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
  
assign in_ready = !valid_reg || (out_ready);

endmodule
