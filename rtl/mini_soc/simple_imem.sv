module simple_imem #(
  parameter int unsigned DepthWords = 512
) (
  input  logic        clk_i,
  input  logic        rst_ni,
  input  logic        req_i,
  input  logic [31:0] addr_i,
  input  logic        preload_we_i,
  input  logic [31:0] preload_addr_i,
  input  logic [31:0] preload_wdata_i,
  output logic        gnt_o,
  output logic        rvalid_o,
  output logic [31:0] rdata_o,
  output logic        err_o
);

  localparam int unsigned AddrLsb = 2;
  localparam int unsigned AddrW   = $clog2(DepthWords);

  logic [31:0] mem [DepthWords];
  logic [31:0] rdata_q;
  logic        rvalid_q;
  logic        err_q;
  logic        in_range;
  logic [AddrW-1:0] word_idx;
  logic [AddrW-1:0] preload_word_idx;

  assign word_idx = addr_i[AddrLsb +: AddrW];
  assign preload_word_idx = preload_addr_i[AddrLsb +: AddrW];
  assign in_range = (addr_i[31:11] == 21'h0);
  assign gnt_o    = req_i;

  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      rvalid_q <= 1'b0;
      rdata_q  <= '0;
      err_q    <= 1'b0;
    end else begin
      rvalid_q <= req_i;
      err_q    <= req_i & ~in_range;
      if (req_i && in_range) begin
        rdata_q <= mem[word_idx];
      end else begin
        rdata_q <= 32'h0000_0013; // RISC-V NOP.
      end

      if (preload_we_i) begin
        mem[preload_word_idx] <= preload_wdata_i;
      end
    end
  end

  assign rvalid_o = rvalid_q;
  assign rdata_o  = rdata_q;
  assign err_o    = err_q;

endmodule
