module synchronous_fifo #(
  parameter DEPTH = 8,
  parameter DATA_WIDTH = 8,
  parameter PTR_WIDTH = $clog2(DEPTH)
)(
  input  logic                   clk,
  input  logic                   rst_n,
  input  logic                   w_en,
  input  logic                   r_en,
  input  logic [DATA_WIDTH-1:0]  data_in,
  output logic [DATA_WIDTH-1:0]  data_out,
  output logic                   full,
  output logic                   empty
);

  // Internal FIFO memory
  logic [DATA_WIDTH-1:0] fifo_mem [0:DEPTH-1];

  // Read/Write pointers with extra MSB for full/empty detection
  logic [PTR_WIDTH:0] w_ptr, r_ptr;
  logic wrap_around;

  // Reset logic
  integer i;
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      w_ptr    <= '0;
      r_ptr    <= '0;
      data_out <= '0;
      for (i = 0; i < DEPTH; i = i + 1)
        fifo_mem[i] <= '0;
    end
    else begin
      // Write operation
      if (w_en && !full) begin
        fifo_mem[w_ptr[PTR_WIDTH-1:0]] <= data_in;
        w_ptr <= w_ptr + 1;
      end

      // Read operation
      if (r_en && !empty) begin
        data_out <= fifo_mem[r_ptr[PTR_WIDTH-1:0]];
        r_ptr <= r_ptr + 1;
      end
    end
  end

  // Pointer MSB difference for wrap-around
  assign wrap_around = w_ptr[PTR_WIDTH] ^ r_ptr[PTR_WIDTH];

  // Full: MSBs different and rest of pointer same
  assign full  = wrap_around && (w_ptr[PTR_WIDTH-1:0] == r_ptr[PTR_WIDTH-1:0]);

  // Empty: pointers exactly equal
  assign empty = (w_ptr == r_ptr);

endmodule
