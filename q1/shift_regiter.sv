module shift_regiter #(
    parameter N = 4
) (
    input logic clk,
    input logic rst_n,
    input logic serial_parallel,
    input logic load_enable,
    input logic serial_in,
    input logic [N-1:0] parallel_in,
    output logic [N-1:0] parallel_out,
    output logic serial_out
);
  //complete here

  assign serial_out = parallel_out[N-1];

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      parallel_out <= '0;
    end else begin
      if (load_enable) begin
        if (serial_parallel) begin
          parallel_out <= parallel_in;
        end else begin
          parallel_out <= {parallel_out[N-2:0], serial_in};
        end
      end
    end
  end
endmodule
