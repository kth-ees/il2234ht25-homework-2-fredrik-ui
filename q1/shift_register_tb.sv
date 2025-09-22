module shift_register_tb;

  // complete here
  localparam N = 4;
  logic clk;
  logic rst_n;
  logic serial_parallel;
  logic load_enable;
  logic serial_in;
  logic [N-1:0] parallel_in;
  logic [N-1:0] parallel_out;
  logic serial_out;

  shift_regiter #(
      .N(N)
  ) uut (
      .clk(clk),
      .rst_n(rst_n),
      .serial_parallel(serial_parallel),
      .load_enable(load_enable),
      .serial_in(serial_in),
      .parallel_in(parallel_in),
      .parallel_out(parallel_out),
      .serial_out(serial_out)
  );

  initial begin
    clk = 0;
    forever #1 clk = ~clk;
  end

  sequence serial_parallel_true; load_enable && serial_parallel; endsequence

  sequence serial_parallel_false; load_enable && !serial_parallel; endsequence

  property load_parallel;
    @(posedge clk) disable iff (!rst_n) serial_parallel_true |=> parallel_out == $past(
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

  property load_serial;
    @(posedge clk) disable iff (!rst_n) serial_parallel_false |=> parallel_out == $past(
        {parallel_out[N-2:0], serial_in}
    );
  endproperty

  assert property (load_serial)
  else
    $error(
        "parallel_out was not shifted properly. Expected:%d, Got:%d",
        {
          parallel_out[N-2:0], serial_in
        },
        parallel_out
    );

  property reset_clears;
    @(posedge clk) (!rst_n) |=> parallel_out == '0;
  endproperty

  assert property (reset_clears)
  else $error("Parallel out is not rested on low rst_n. Expected: 0, Got:%d", parallel_out);

  initial begin
    rst_n           = 0;
    serial_parallel = 0;
    load_enable     = 0;
    serial_in       = 0;
    parallel_in     = 0;

    @(posedge clk);
    rst_n = 1;

    // parallel load 10
    @(posedge clk);
    load_enable     = 1;
    serial_parallel = 1;
    parallel_in     = 4'b1010;

    @(posedge clk);
    $display("Parallel load 10 random 4 bit numbers");
    for (int i = 0; i < 10; i++) begin
      // randomly generate a 4 bit number and parallel load it
      parallel_in = $urandom_range(15, 0);
      @(posedge clk);
    end

    @(posedge clk);
    $display("Serial load randomly generated 1 and 0");
    serial_parallel = 0;
    for (int i = 0; i < 10; i++) begin
      // randomly generate 0 and 1
      serial_in = $urandom_range(1, 0);
      @(posedge clk);
    end

    // parallel load 6 after a serial load, this should overwrit the previous result
    @(posedge clk);
    serial_parallel = 1;
    parallel_in = 6;

    @(posedge clk);
    $display("DONE!");
    load_enable = 0;
    // When rst_n is set to 0 parallel_out == 0
    rst_n = 0;
  end

  initial begin
    $monitor(
        "serial_parallel=%0b, load_enable=%0b, serial_in=%0b, parallel_in=%0b, parallel_out=%0b, serial_out=%0b",
        serial_parallel, load_enable, serial_in, parallel_in, parallel_out, serial_out);
  end

endmodule

