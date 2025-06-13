// ---------------------------------------------------------------------------
// Module      : Testbench for Synchronous FIFO
// Author      : Ananya Vaidya
// ---------------------------------------------------------------------------
module sync_fifo_TB;

  parameter DATA_WIDTH = 8; // Width of FIFO data

  // ------------------------------------------------------------------------
  // DUT interface signals
  reg  clk, rst_n;
  reg  w_en, r_en;
  reg  [DATA_WIDTH-1:0] data_in;
  wire [DATA_WIDTH-1:0] data_out;
  wire full, empty;

  // ------------------------------------------------------------------------
  // Software-side queue for verification
  // Used to store written values to compare with what comes out of FIFO
  reg [DATA_WIDTH-1:0] wdata_q[$], wdata;

  // ------------------------------------------------------------------------
  // Instantiate the Device Under Test (DUT)
  synchronous_fifo #(
    .DEPTH(8),
    .DATA_WIDTH(DATA_WIDTH)
  ) s_fifo (
    .clk(clk),
    .rst_n(rst_n),
    .w_en(w_en),
    .r_en(r_en),
    .data_in(data_in),
    .data_out(data_out),
    .full(full),
    .empty(empty)
  );

  // ------------------------------------------------------------------------
  // Clock generation: 10ns clock period
  initial clk = 0;
  always #5 clk = ~clk;

  // ------------------------------------------------------------------------
  // Write logic — feeds random data into FIFO conditionally
  initial begin
    rst_n   = 0;
    w_en    = 0;
    data_in = 0;

    // Hold reset for a few cycles
    repeat(5) @(posedge clk);
    rst_n = 1;

    // Write loop: attempts to write every alternate cycle
    for (int i = 0; i < 30; i++) begin
      @(posedge clk);
      w_en = (i % 2 == 0) && !full;
      if (w_en) begin
        data_in = $urandom_range(0, 255);
        wdata_q.push_back(data_in); // save expected output
        $display("Time = %0t: 📝 Write -> %0h", $time, data_in);
      end
    end

    w_en = 0; // stop writing
  end

  // ------------------------------------------------------------------------
  // Read logic — starts later and attempts to match output to expected data
  initial begin
    r_en = 0;

    // Wait for reset to deassert and delay to allow writes
    wait(rst_n == 1);
    repeat(20) @(posedge clk);

    // Read loop: tries to read every alternate cycle
    for (int i = 0; i < 30; i++) begin
      @(posedge clk);
      r_en = (i % 2 == 0) && !empty;

      if (r_en) begin
        #1; // slight delay to allow data_out to stabilize
        wdata = wdata_q.pop_front(); // get expected value

        if (data_out !== wdata)
          $error("Time = %0t: ❌ Mismatch! Expected: %0h, Got: %0h", $time, wdata, data_out);
        else
          $display("Time = %0t: ✅ Match: %0h", $time, data_out);
      end
    end

    r_en = 0;
    #50;
    $finish; // end simulation
  end

  // ------------------------------------------------------------------------
  // Dump signals for GTKWave/VCD viewing
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, sync_fifo_TB);
  end

endmodule
