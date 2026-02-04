`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04.02.2026 20:58:27
// Design Name: 
// Module Name: tb_single_stage_pipeline
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


 module tb_single_stage_pipeline();
 parameter DATA_WIDTH = 32;

  // Clock & reset
  logic clk;
  logic rst_n;

  // DUT signals
  logic                  in_valid;
  logic                  in_ready;
  logic [DATA_WIDTH-1:0] in_data;

  logic                  out_valid;
  logic                  out_ready;
  logic [DATA_WIDTH-1:0] out_data;

  // DUT instantiation
  single_stage_pipeline #(
    .DATA_WIDTH(DATA_WIDTH)
  ) dut (
    .clk       (clk),
    .rst_n     (rst_n),
    .in_valid  (in_valid),
    .in_ready  (in_ready),
    .in_data   (in_data),
    .out_valid (out_valid),
    .out_ready (out_ready),
    .out_data  (out_data)
  );

  // Clock generation (10ns period)
  always #5 clk = ~clk;

  // ---------------- TASKS ----------------

  // Reset task
  task automatic apply_reset();
    begin
      rst_n     = 0;
      in_valid  = 0;
      in_data   = '0;
      out_ready = 0;
      repeat (3) @(posedge clk);
      rst_n = 1;
    end
  endtask

  // Send one data beat
  task automatic send_data(input logic [DATA_WIDTH-1:0] data);
    begin
      @(posedge clk);
      in_valid <= 1;
      in_data  <= data;

      // HOLD valid HIGH until ready is asserted
    do begin
      @(posedge clk);   // Wait a cycle
    end while (!in_ready);  // Keep waiting if not ready
    
    // Only when in_ready is high do we deassert valid
    in_valid <= 0; 
    end
  endtask

  // Random backpressure generator
  task automatic random_backpressure(input int cycles);
    int i;
    begin
      for (i = 0; i < cycles; i++) begin
        @(posedge clk);
        out_ready <= $urandom_range(0,1);
      end
    end
  endtask

  // ---------------- TEST SEQUENCE ----------------

  initial begin
    clk = 0;

    apply_reset();

    // Enable output by default
    out_ready = 1;

    // ------------------------------------------------
    // Test 1: Random data without backpressure
    // ------------------------------------------------
    repeat (5) begin
      send_data($urandom);
    end

    // ------------------------------------------------
    // Test 2: Random data with backpressure
    // ------------------------------------------------
    fork
      random_backpressure(20);
      begin
        repeat (10) begin
          send_data($urandom);
        end
      end
    join

    // ------------------------------------------------
    // End simulation
    // ------------------------------------------------
    #50;
    $display("[%0t] Simulation completed", $time);
    $finish;
  end

  // ---------------- MONITOR ----------------
  always @(posedge clk) begin
    $display("[%0t] in_v=%b in_r=%b in_d=%h | out_v=%b out_r=%b out_d=%h",
              $time, in_valid, in_ready, in_data,
              out_valid, out_ready, out_data);
  end


endmodule
