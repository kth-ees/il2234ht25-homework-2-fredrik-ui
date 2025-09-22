module LFSR_6bit_tb;

  logic clk;
  logic rst_n;
  logic sel;
  logic [5:0] parallel_in;
  logic [5:0] parallel_out;

  LFSR_6bit uut (
      .clk(clk),
      .rst_n(rst_n),
      .sel(sel),
      .parallel_in(parallel_in),
      .parallel_out(parallel_out)
  );

  initial begin
    clk = 0;
    forever #1 clk = ~clk;
  end

  property load_parallel;
    @(posedge clk) disable iff (!rst_n) !sel |=> parallel_out == $past(
        parallel_in
    );
  endproperty

  assert property (load_parallel)
  else
    $error(
        "parallel_out did not match previous parallel_in after load. Expected:%d, Got:%d",
        parallel_in,
        parallel_out
    );

  property reset_clears;
    @(posedge clk) (!rst_n) |=> parallel_out == '0;
  endproperty

  assert property (reset_clears)
  else $error("Parallel out is not rested on low rst_n. Expected: 0, Got:%d", parallel_out);

  property LSFR_shift;
    @(posedge clk) disable iff (!rst_n) sel |=> parallel_out ==
        {
            $past(parallel_out[4]),
            $past(parallel_out[3]),
            $past(parallel_out[2]) ^ $past(parallel_out[5]),
            $past(parallel_out[1]),
            $past(parallel_out[0]) ^ $past(parallel_out[5]),
            $past(parallel_out[5])
        };
  endproperty

  assert property (LSFR_shift)
  else
    $error(
        "parallel_out was not shifted properly. Expected:%b, Got:%b",
        {
            $past(parallel_out[4]),
            $past(parallel_out[3]),
            $past(parallel_out[2]) ^ $past(parallel_out[5]),
            $past(parallel_out[1]),
            $past(parallel_out[0]) ^ $past(parallel_out[5]),
            $past(parallel_out[5])
        },
        parallel_out
    );


  initial begin
    clk = 0;
    rst_n = 0;
    parallel_in = 0;

    @(posedge clk);
    rst_n = 1;

    // 10 random numbers parallel loaded
    @(posedge clk);
    sel = 0;
    $display("Parallel load 10 random 6 bit numbers");
    for(int i = 0; i<10; i++) begin
      parallel_in = $urandom;
      @(posedge clk);
    end

    // 10 lsfr shfits
    @(posedge clk);
    sel = 1;
    $display("10 LSFR shifts");
    for(int i = 0; i<10; i++) begin
      @(posedge clk);
    end

    // Should overwrite the LSFR shift from before
    @(posedge clk);
    sel = 0;
    parallel_in = 4'b1010;

    @(posedge clk);
    $display("DONE!");
    // When rst_n is set to 0 parallel_out == 0
    rst_n = 0;

  end

  initial begin
    $monitor("sel=%0b, parallel_in=%0b, parallel_out=%0b", sel, parallel_in, parallel_out);
  end

endmodule
