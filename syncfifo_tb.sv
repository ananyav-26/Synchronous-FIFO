module sync_fifo_TB;

  parameter DATA_WIDTH = 8;

  // DUT interface
  reg clk, rst_n;
  reg w_en, r_en;
  reg [DATA_WIDTH-1:0] data_in;
  wire [DATA_WIDTH-1:0] data_out;
  wire full, empty;

  // Queue to track written data for comparison
  reg [DATA_WIDTH-1:0] wdata_q[$], wdata;

  // DUT Instantiation
  synchronous_fifo #(.DEPTH(8), .DATA_WIDTH(DATA_WIDTH)) s_fifo (
    .clk(clk), .rst_n(rst_n),
    .w_en(w_en), .r_en(r_en),
    .data_in(data_in),
    .data_out(data_out),
    .full(full), .empty(empty)
  );

  // Clock generation
  initial clk = 0;
  always #5 clk = ~clk; // 10ns clock period

  // Write process
  initial begin
    rst_n = 0;
    w_en  = 0;
    data_in = 0;
    repeat(5) @(posedge clk); // hold reset
    rst_n = 1;

    // Write data with gaps
    for (int i = 0; i < 30; i++) begin
      @(posedge clk);
      w_en = (i % 2 == 0) && !full;
      if (w_en) begin
        data_in = $urandom_range(0, 255);
        wdata_q.push_back(data_in);
        $display("Time = %0t: Write -> %0h", $time, data_in);
      end
    end
    w_en = 0;
  end

  // Read process
  initial begin
    r_en = 0;
    wait(rst_n == 1); // wait until reset deasserts
    repeat(20) @(posedge clk); // delay before starting reads

    for (int i = 0; i < 30; i++) begin
      @(posedge clk);
      r_en = (i % 2 == 0) && !empty;
      if (r_en) begin
        #1; // small delay to capture data_out change
        wdata = wdata_q.pop_front();
        if (data_out !== wdata)
          $error("Time = %0t: ❌ Mismatch: expected %0h, got %0h", $time, wdata, data_out);
        else
          $display("Time = %0t: ✅ Match: %0h", $time, data_out);
      end
    end
    r_en = 0;
    #50;
    $finish;
  end

  // Dump for waveform analysis
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, sync_fifo_TB);
  end

endmodule
