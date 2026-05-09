module ibex_mini_soc_top import ibex_pkg::*; (
  input  logic        clk_i,
  input  logic        rst_ni,
  input  logic        imem_we_i,
  input  logic [31:0] imem_waddr_i,
  input  logic [31:0] imem_wdata_i,
  input  logic [31:0] gpio_i,
  output logic [31:0] gpio_o
);

  logic instr_req;
  logic instr_gnt;
  logic instr_rvalid;
  logic [31:0] instr_addr;
  logic [31:0] instr_rdata;
  logic instr_err;

  logic data_req;
  logic data_gnt;
  logic data_rvalid;
  logic data_we;
  logic [3:0] data_be;
  logic [31:0] data_addr;
  logic [31:0] data_wdata;
  logic [31:0] data_rdata;
  logic data_err;

  logic sel_dmem;
  logic sel_gpio;
  logic sel_timer;
  logic sel_unmapped;

  logic dmem_rvalid;
  logic gpio_rvalid;
  logic timer_rvalid;
  logic unmapped_rvalid_q;
  logic [31:0] dmem_rdata;
  logic [31:0] gpio_rdata;
  logic [31:0] timer_rdata;
  logic timer_irq;

  prim_ram_1p_pkg::ram_1p_cfg_rsp_t [IC_NUM_WAYS-1:0] ram_cfg_rsp_icache_tag;
  prim_ram_1p_pkg::ram_1p_cfg_rsp_t [IC_NUM_WAYS-1:0] ram_cfg_rsp_icache_data;
  logic scramble_req;
  crash_dump_t crash_dump;
  logic double_fault_seen;
  logic alert_minor;
  logic alert_major_internal;
  logic alert_major_bus;
  logic core_sleep;
  ibex_mubi_t lockstep_cmp_en;
  logic data_req_shadow;
  logic data_we_shadow;
  logic [3:0] data_be_shadow;
  logic [31:0] data_addr_shadow;
  logic [31:0] data_wdata_shadow;
  logic [6:0] data_wdata_intg_shadow;
  logic instr_req_shadow;
  logic [31:0] instr_addr_shadow;
  logic [6:0] data_wdata_intg;

  simple_imem u_imem (
    .clk_i,
    .rst_ni,
    .req_i   (instr_req),
    .addr_i  (instr_addr),
    .preload_we_i   (imem_we_i),
    .preload_addr_i (imem_waddr_i),
    .preload_wdata_i(imem_wdata_i),
    .gnt_o   (instr_gnt),
    .rvalid_o(instr_rvalid),
    .rdata_o (instr_rdata),
    .err_o   (instr_err)
  );

  simple_decoder u_decoder (
    .addr_i        (data_addr),
    .sel_dmem_o    (sel_dmem),
    .sel_gpio_o    (sel_gpio),
    .sel_timer_o   (sel_timer),
    .sel_unmapped_o(sel_unmapped)
  );

  simple_dmem u_dmem (
    .clk_i,
    .rst_ni,
    .req_i   (data_req & sel_dmem),
    .we_i    (data_we),
    .be_i    (data_be),
    .addr_i  (data_addr),
    .wdata_i (data_wdata),
    .rvalid_o(dmem_rvalid),
    .rdata_o (dmem_rdata)
  );

  gpio u_gpio (
    .clk_i,
    .rst_ni,
    .req_i   (data_req & sel_gpio),
    .we_i    (data_we),
    .be_i    (data_be),
    .addr_i  (data_addr),
    .wdata_i (data_wdata),
    .gpio_i,
    .gpio_o,
    .rvalid_o(gpio_rvalid),
    .rdata_o (gpio_rdata)
  );

  timer u_timer (
    .clk_i,
    .rst_ni,
    .req_i   (data_req & sel_timer),
    .we_i    (data_we),
    .be_i    (data_be),
    .addr_i  (data_addr),
    .wdata_i (data_wdata),
    .irq_o   (timer_irq),
    .rvalid_o(timer_rvalid),
    .rdata_o (timer_rdata)
  );

  assign data_gnt = data_req;

  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      unmapped_rvalid_q <= 1'b0;
    end else begin
      unmapped_rvalid_q <= data_req & sel_unmapped;
    end
  end

  always_comb begin
    data_rvalid = dmem_rvalid | gpio_rvalid | timer_rvalid | unmapped_rvalid_q;
    data_rdata  = 32'h0;
    data_err    = unmapped_rvalid_q;

    if (dmem_rvalid) begin
      data_rdata = dmem_rdata;
    end else if (gpio_rvalid) begin
      data_rdata = gpio_rdata;
    end else if (timer_rvalid) begin
      data_rdata = timer_rdata;
    end
  end

  ibex_top #(
    .PMPEnable       (1'b0),
    .PMPGranularity  (0),
    .PMPNumRegions   (4),
    .MHPMCounterNum  (0),
    .MHPMCounterWidth(40),
    .RV32E           (1'b0),
    .RV32M           (ibex_pkg::RV32MFast),
    .RV32B           (ibex_pkg::RV32BNone),
    .RV32ZC          (ibex_pkg::RV32ZcaZcbZcmp),
    .RegFile         (ibex_pkg::RegFileFF),
    .BranchTargetALU (1'b0),
    .WritebackStage  (1'b0),
    .ICache          (1'b0),
    .ICacheECC       (1'b0),
    .BranchPredictor (1'b0),
    .DbgTriggerEn    (1'b0),
    .DbgHwBreakNum   (1),
    .SecureIbex      (1'b0),
    .MemECC          (1'b0),
    .ICacheScramble  (1'b0)
  ) u_ibex_top (
    .clk_i,
    .rst_ni,
    .test_en_i                  (1'b0),
    .ram_cfg_icache_tag_i       (prim_ram_1p_pkg::RAM_1P_CFG_DEFAULT),
    .ram_cfg_rsp_icache_tag_o   (ram_cfg_rsp_icache_tag),
    .ram_cfg_icache_data_i      (prim_ram_1p_pkg::RAM_1P_CFG_DEFAULT),
    .ram_cfg_rsp_icache_data_o  (ram_cfg_rsp_icache_data),
    .hart_id_i                  (32'h0),
    .boot_addr_i                (32'h0000_0000),
    .instr_req_o                (instr_req),
    .instr_gnt_i                (instr_gnt),
    .instr_rvalid_i             (instr_rvalid),
    .instr_addr_o               (instr_addr),
    .instr_rdata_i              (instr_rdata),
    .instr_rdata_intg_i         (7'h0),
    .instr_err_i                (instr_err),
    .data_req_o                 (data_req),
    .data_gnt_i                 (data_gnt),
    .data_rvalid_i              (data_rvalid),
    .data_we_o                  (data_we),
    .data_be_o                  (data_be),
    .data_addr_o                (data_addr),
    .data_wdata_o               (data_wdata),
    .data_wdata_intg_o          (data_wdata_intg),
    .data_rdata_i               (data_rdata),
    .data_rdata_intg_i          (7'h0),
    .data_err_i                 (data_err),
    .irq_software_i             (1'b0),
    .irq_timer_i                (timer_irq),
    .irq_external_i             (1'b0),
    .irq_fast_i                 (15'h0),
    .irq_nm_i                   (1'b0),
    .scramble_key_valid_i       (1'b0),
    .scramble_key_i             ('0),
    .scramble_nonce_i           ('0),
    .scramble_req_o             (scramble_req),
    .debug_req_i                (1'b0),
    .crash_dump_o               (crash_dump),
    .double_fault_seen_o        (double_fault_seen),
    .fetch_enable_i             (ibex_pkg::IbexMuBiOn),
    .alert_minor_o              (alert_minor),
    .alert_major_internal_o     (alert_major_internal),
    .alert_major_bus_o          (alert_major_bus),
    .core_sleep_o               (core_sleep),
    .scan_rst_ni                (rst_ni),
    .lockstep_cmp_en_o          (lockstep_cmp_en),
    .data_req_shadow_o          (data_req_shadow),
    .data_we_shadow_o           (data_we_shadow),
    .data_be_shadow_o           (data_be_shadow),
    .data_addr_shadow_o         (data_addr_shadow),
    .data_wdata_shadow_o        (data_wdata_shadow),
    .data_wdata_intg_shadow_o   (data_wdata_intg_shadow),
    .instr_req_shadow_o         (instr_req_shadow),
    .instr_addr_shadow_o        (instr_addr_shadow)
  );

endmodule
