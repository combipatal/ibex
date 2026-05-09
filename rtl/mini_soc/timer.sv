module timer (
  input  logic        clk_i,
  input  logic        rst_ni,
  input  logic        req_i,
  input  logic        we_i,
  input  logic [3:0]  be_i,
  input  logic [31:0] addr_i,
  input  logic [31:0] wdata_i,
  output logic        irq_o,
  output logic        rvalid_o,
  output logic [31:0] rdata_o
);

  logic [31:0] count_q;
  logic [31:0] compare_q;
  logic        enable_q;
  logic [31:0] rdata_q;
  logic        rvalid_q;

  function automatic logic [31:0] apply_be(
    input logic [31:0] old_data,
    input logic [31:0] new_data,
    input logic [3:0]  be
  );
    apply_be = old_data;
    if (be[0]) apply_be[7:0]   = new_data[7:0];
    if (be[1]) apply_be[15:8]  = new_data[15:8];
    if (be[2]) apply_be[23:16] = new_data[23:16];
    if (be[3]) apply_be[31:24] = new_data[31:24];
  endfunction

  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      count_q   <= '0;
      compare_q <= 32'hffff_ffff;
      enable_q  <= 1'b0;
      rdata_q   <= '0;
      rvalid_q  <= 1'b0;
    end else begin
      rvalid_q <= req_i;

      if (enable_q) begin
        count_q <= count_q + 32'd1;
      end

      if (req_i) begin
        unique case (addr_i[5:2])
          4'h0: rdata_q <= count_q;
          4'h1: rdata_q <= compare_q;
          4'h2: rdata_q <= {31'b0, enable_q};
          default: rdata_q <= 32'h0;
        endcase

        if (we_i) begin
          unique case (addr_i[5:2])
            4'h0: count_q   <= apply_be(count_q, wdata_i, be_i);
            4'h1: compare_q <= apply_be(compare_q, wdata_i, be_i);
            4'h2: enable_q  <= wdata_i[0];
            default: begin
            end
          endcase
        end
      end
    end
  end

  assign irq_o    = enable_q & (count_q == compare_q);
  assign rvalid_o = rvalid_q;
  assign rdata_o  = rdata_q;

endmodule
