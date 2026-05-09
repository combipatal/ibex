module simple_decoder (
  input  logic [31:0] addr_i,
  output logic        sel_dmem_o,
  output logic        sel_gpio_o,
  output logic        sel_timer_o,
  output logic        sel_unmapped_o
);

  always_comb begin
    sel_dmem_o     = 1'b0;
    sel_gpio_o     = 1'b0;
    sel_timer_o    = 1'b0;
    sel_unmapped_o = 1'b0;

    unique casez (addr_i)
      32'h0001_0???: sel_dmem_o  = 1'b1;
      32'h0002_00??: sel_gpio_o  = 1'b1;
      32'h0002_01??: sel_timer_o = 1'b1;
      default:       sel_unmapped_o = 1'b1;
    endcase
  end

endmodule
