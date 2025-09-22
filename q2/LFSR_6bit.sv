module LFSR_6bit (
    input logic clk,
    rst_n,
    input logic sel,
    input logic [5:0] parallel_in,
    output logic [5:0] parallel_out
);
  always_ff @(posedge clk or negedge rst_n) begin

    if (!rst_n) begin
      parallel_out <= '0;
    end else begin
      if (sel) begin
        parallel_out[0] <= parallel_out[5];
        parallel_out[1] <= parallel_out[0] ^ parallel_out[5];
        parallel_out[2] <= parallel_out[1];
        parallel_out[3] <= parallel_out[2] ^ parallel_out[5];
        parallel_out[4] <= parallel_out[3];
        parallel_out[5] <= parallel_out[4];
      end else begin
        parallel_out <= parallel_in;
      end
    end

  end
endmodule
