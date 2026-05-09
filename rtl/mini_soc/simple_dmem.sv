module simple_dmem #(
  parameter int unsigned DepthWords = 512
) (
  input  logic        clk_i,
  input  logic        rst_ni,
  input  logic        req_i,
  input  logic        we_i,
  input  logic [3:0]  be_i,
  input  logic [31:0] addr_i,
  input  logic [31:0] wdata_i,
  output logic        rvalid_o,
  output logic [31:0] rdata_o
);

  localparam int unsigned AddrLsb = 2;
  localparam int unsigned AddrW   = $clog2(DepthWords);

  logic [31:0] mem [DepthWords];
  logic [31:0] rdata_q;
  logic        rvalid_q;
  logic [AddrW-1:0] word_idx;

  assign word_idx = addr_i[AddrLsb +: AddrW];

  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      rvalid_q <= 1'b0;
      rdata_q  <= '0;
    end else begin
      rvalid_q <= req_i;

      if (req_i) begin
        rdata_q <= mem[word_idx];

        if (we_i) begin
          if (be_i[0]) mem[word_idx][7:0]   <= wdata_i[7:0];
          if (be_i[1]) mem[word_idx][15:8]  <= wdata_i[15:8];
          if (be_i[2]) mem[word_idx][23:16] <= wdata_i[23:16];
          if (be_i[3]) mem[word_idx][31:24] <= wdata_i[31:24];
        end
      end
    end
  end

  assign rvalid_o = rvalid_q;
  assign rdata_o  = rdata_q;

endmodule
