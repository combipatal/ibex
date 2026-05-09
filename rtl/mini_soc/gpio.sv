module gpio (
  input  logic        clk_i,
  input  logic        rst_ni,
  input  logic        req_i,
  input  logic        we_i,
  input  logic [3:0]  be_i,
  input  logic [31:0] addr_i,
  input  logic [31:0] wdata_i,
  input  logic [31:0] gpio_i,
  output logic [31:0] gpio_o,
  output logic        rvalid_o,
  output logic [31:0] rdata_o
);

  logic [31:0] gpio_out_q;
  logic [31:0] rdata_q;
  logic        rvalid_q;

  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      gpio_out_q <= '0;
      rdata_q    <= '0;
      rvalid_q   <= 1'b0;
    end else begin
      rvalid_q <= req_i;

      if (req_i) begin
        unique case (addr_i[5:2])
          4'h0: rdata_q <= gpio_out_q;
          4'h1: rdata_q <= gpio_i;
          default: rdata_q <= 32'h0;
        endcase

        if (we_i && (addr_i[5:2] == 4'h0)) begin
          if (be_i[0]) gpio_out_q[7:0]   <= wdata_i[7:0];
          if (be_i[1]) gpio_out_q[15:8]  <= wdata_i[15:8];
          if (be_i[2]) gpio_out_q[23:16] <= wdata_i[23:16];
          if (be_i[3]) gpio_out_q[31:24] <= wdata_i[31:24];
        end
      end
    end
  end

  assign gpio_o   = gpio_out_q;
  assign rvalid_o = rvalid_q;
  assign rdata_o  = rdata_q;

endmodule
