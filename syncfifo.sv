// ---------------------------------------------------------------------------
// Module      : Synchronous FIFO
// Author      : Ananya Vaidya
// ---------------------------------------------------------------------------
module synchronous_fifo #(
  parameter DEPTH       = 8,                       // Number of FIFO entries
  parameter DATA_WIDTH  = 8,                       // Width of each data entry
  parameter PTR_WIDTH   = $clog2(DEPTH)            // Pointer width based on depth
)(
  input  logic                   clk,              // Clock input
  input  logic                   rst_n,            // Active-low reset
  input  logic                   w_en,             // Write enable
  input  logic                   r_en,             // Read enable
  input  logic [DATA_WIDTH-1:0]  data_in,          // Input data
  output logic [DATA_WIDTH-1:0]  data_out,         // Output data
  output logic                   full,             // FIFO full flag
  output logic                   empty             // FIFO empty flag
);

  // ------------------------------------------------------------------------
  // Internal FIFO storage
  logic [DATA_WIDTH-1:0] fifo_mem [0:DEPTH-1];     // Memory array for FIFO

  // Pointers with extra MSB bit to distinguish full vs empty state
  logic [PTR_WIDTH:0] w_ptr;                       // Write pointer
  logic [PTR_WIDTH:0] r_ptr;                       // Read pointer

  // Optional helper for debugging wrap-around (not used here)
  logic wrap_around;

  // ------------------------------------------------------------------------
  // Reset and synchronous logic block
  integer i;
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      // Reset all control logic and memory
      w_ptr    <= '0;
      r_ptr    <= '0;
      data_out <= '0;

      // Clear FIFO memory (synthesizable but not efficient)
      for (i = 0; i < DEPTH; i = i + 1)
        fifo_mem[i] <= '0;
    end
    else begin
      // ----------------------
      // Write operation
      if (w_en && !full) begin
        fifo_mem[w_ptr[PTR_WIDTH-1:0]] <= data_in; // Write data to FIFO
        w_ptr <= w_ptr + 1;                        // Increment write pointer
      end

      // ----------------------
      // Read operation
      if (r_en && !empty) begin
        data_out <= fifo_mem[r_ptr[PTR_WIDTH-1:0]]; // Read data from FIFO
        r_ptr <= r_ptr + 1;                         // Increment read pointer
      end
    end
  end

  // ------------------------------------------------------------------------
  // Full and Empty flag logic
  assign full  = (w_ptr[PTR_WIDTH] != r_ptr[PTR_WIDTH]) &&
                 (w_ptr[PTR_WIDTH-1:0] == r_ptr[PTR_WIDTH-1:0]);

  assign empty = (w_ptr == r_ptr);

endmodule
