
LIBRARY IEEE;--! standard library IEEE (Institute of Electrical and Electronics Engineers)
USE IEEE.std_logic_1164.ALL;--! standard unresolved logic UX01ZWLH-
USE IEEE.numeric_std.ALL;--! for the signed, unsigned types and arithmetic ops

ENTITY AXI_corr_TOP IS
  PORT (
    refclk : IN STD_LOGIC;--! reference clock expect 250Mhz
    rst    : IN STD_LOGIC;--! sync active high reset. sync -> refclk

    -- Global Signals
    M_AXI_ACLK : OUT STD_LOGIC;
    --  Read address channel signals
    M_AXI_ARID    : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
    M_AXI_ARADDR  : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    M_AXI_ARLEN   : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
    M_AXI_ARSIZE  : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
    M_AXI_ARBURST : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
    M_AXI_ARLOCK  : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
    M_AXI_ARCACHE : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
    M_AXI_ARPROT  : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
    M_AXI_ARQOS   : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
    M_AXI_ARUSER  : OUT STD_LOGIC_VECTOR(4 DOWNTO 0);
    M_AXI_ARVALID : OUT STD_LOGIC;
    M_AXI_ARREADY : IN  STD_LOGIC;
    -- Read data channel signals
    M_AXI_RID    : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
    M_AXI_RDATA  : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
    M_AXI_RRESP  : IN  STD_LOGIC_VECTOR(1 DOWNTO 0);
    M_AXI_RLAST  : IN  STD_LOGIC;
    M_AXI_RVALID : IN  STD_LOGIC;
    M_AXI_RREADY : OUT STD_LOGIC;

    result_o : OUT STD_LOGIC
  );
END ENTITY AXI_corr_TOP;
ARCHITECTURE rtl OF AXI_corr_TOP IS
  SIGNAL rst_w : STD_LOGIC;
  COMPONENT AXI_master IS
    GENERIC (
      axi_data_width_log2b    : NATURAL RANGE 5 TO 255 := 6;
      axi_address_width_log2b : NATURAL RANGE 5 TO 255 := 5
    );
    PORT (
      refclk        : IN  STD_LOGIC;--! reference clock expect 250Mhz
      rst           : IN  STD_LOGIC;--! sync active high reset. sync -> refclk
      read_data     : OUT STD_LOGIC_VECTOR(31 DOWNTO 0); --!эти данные мы записываем в буффер
      read_start    : IN  STD_LOGIC;                     --! это соединяется с axi_enable от планировщика
      read_complete : OUT STD_LOGIC;
      read_result   : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
      read_addr     : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
      write_addr    : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
      M_AXI_ACLK    : OUT STD_LOGIC;
      M_AXI_ARID    : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
      M_AXI_ARADDR  : OUT STD_LOGIC_VECTOR(2 ** axi_address_width_log2b - 1 DOWNTO 0);
      M_AXI_ARLEN   : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
      M_AXI_ARSIZE  : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
      M_AXI_ARBURST : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
      M_AXI_ARLOCK  : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
      M_AXI_ARCACHE : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
      M_AXI_ARPROT  : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
      M_AXI_ARQOS   : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
      M_AXI_ARUSER  : OUT STD_LOGIC_VECTOR(4 DOWNTO 0);
      M_AXI_ARVALID : OUT STD_LOGIC;
      M_AXI_ARREADY : IN  STD_LOGIC;
      M_AXI_RID     : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
      M_AXI_RDATA   : IN  STD_LOGIC_VECTOR(2 ** axi_data_width_log2b - 1 DOWNTO 0);
      M_AXI_RRESP   : IN  STD_LOGIC_VECTOR(1 DOWNTO 0);
      M_AXI_RLAST   : IN  STD_LOGIC;
      M_AXI_RVALID  : IN  STD_LOGIC;
      M_AXI_RREADY  : OUT STD_LOGIC
    );
  END COMPONENT;

  COMPONENT bram_buf IS
    PORT (
      refclk : IN STD_LOGIC;--! reference clock expect 250Mhz
      rst    : IN STD_LOGIC;--! sync active high reset. sync -> refclk

      addr : IN STD_LOGIC_VECTOR(3 DOWNTO 0); -- адрес ячейки в буфере (от 0 до 14)
      re   : IN STD_LOGIC;                    -- read enable
      we   : IN STD_LOGIC;                    -- write enable (поднять для записи)

      data_i : IN  STD_LOGIC_VECTOR(31 DOWNTO 0); -- data input
      data_o : OUT STD_LOGIC_VECTOR(31 DOWNTO 0); -- data output
      valid  : OUT STD_LOGIC
    );
  END COMPONENT;

  COMPONENT correlator IS
    PORT (
      refclk : IN STD_LOGIC;--! reference clock expect 250Mhz
      rst    : IN STD_LOGIC;--! sync active high reset. sync -> refclk
      en     : IN STD_LOGIC;

      ref_input    : IN STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
      signal_input : IN STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');

      valid    : IN  STD_LOGIC;
      ref_addr : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
      bram_re  : OUT STD_LOGIC := '0';

      result   : OUT STD_LOGIC := '0';
      corr_end : OUT STD_LOGIC := '0'
    );
  END COMPONENT;

  COMPONENT planner IS

    PORT (
      refclk        : IN  STD_LOGIC;--! reference clock expect 250Mhz
      rst           : IN  STD_LOGIC;--! sync active high reset. sync -> refclk
      read_complete : IN  STD_LOGIC;--! when data(ref\ref) is reading
      corr_DONE     : IN  STD_LOGIC;--! когда корреляция завершилось (принимаем этот сигнал от коррелятора, когда он закончил обработку)
      axi_address   : OUT STD_LOGIC_VECTOR(31 DOWNTO 0); --! 
      axi_enabl     : OUT STD_LOGIC;
      flag          : OUT STD_LOGIC;
      corr_enable   : OUT STD_LOGIC
      -- buff_ref         : IN STD_LOGIC; --! пустой ли буфер для референса
      -- buff_seq         : IN STD_LOGIC --! пустой ли буфер для последовательности
    );
  END COMPONENT;

  -- logic wires planner to others
  SIGNAL read_cmplt_w, corr_DONE_w, axi_en_w, flag_w, corr_en_w, buff_ref_w, buff_seq_w : STD_LOGIC;
  SIGNAL axi_adr_w                                                                      : STD_LOGIC_VECTOR(31 DOWNTO 0);
  SIGNAL ARLEN_W                                                                        : STD_LOGIC_VECTOR(3 DOWNTO 0);

  -- data wires
  SIGNAL data_from_axi_w : STD_LOGIC_VECTOR(31 DOWNTO 0);

  -- wires to work with buffers
  SIGNAL ref_buf_adr_w, sig_buf_adr_w, both_adr_w, write_addr_w                      : STD_LOGIC_VECTOR(3 DOWNTO 0);
  SIGNAL ref_re_w, ref_we_w, ref_valid_w, sig_re_w, sig_we_w, sig_valid_w, both_re_w : STD_LOGIC;
  SIGNAL ref_data_i_w, ref_data_o_w, sig_data_i_w, sig_data_o_w                      : STD_LOGIC_VECTOR(31 DOWNTO 0);

  SIGNAL valid_w : STD_LOGIC;

BEGIN
  -- port => wire 
  planer_module : planner PORT MAP(
    refclk        => refclk,
    rst           => rst_w,
    read_complete => read_cmplt_w,
    corr_DONE     => corr_DONE_w,
    axi_address   => axi_adr_w,
    axi_enabl     => axi_en_w,
    flag          => flag_w,
    corr_enable   => corr_en_w
    -- buff_ref      => buff_ref_w,         
    -- buff_seq      => buff_seq_w         
  );

  AXI_MM_module : AXI_master GENERIC MAP(axi_data_width_log2b => 5, axi_address_width_log2b => 5)
  PORT MAP(
    refclk        => refclk,
    rst           => rst_w,
    read_data     => data_from_axi_w,
    read_start    => axi_en_w,
    read_complete => read_cmplt_w,
    write_addr    => write_addr_w,
    -- => read_result,
    read_addr => axi_adr_w,

    M_AXI_ACLK    => M_AXI_ACLK,
    M_AXI_ARID    => M_AXI_ARID,
    M_AXI_ARADDR  => M_AXI_ARADDR,
    M_AXI_ARLEN   => ARLEN_W,
    M_AXI_ARSIZE  => M_AXI_ARSIZE,
    M_AXI_ARBURST => M_AXI_ARBURST,
    M_AXI_ARLOCK  => M_AXI_ARLOCK,
    M_AXI_ARCACHE => M_AXI_ARCACHE,
    M_AXI_ARPROT  => M_AXI_ARPROT,
    M_AXI_ARQOS   => M_AXI_ARQOS,
    M_AXI_ARUSER  => M_AXI_ARUSER,
    M_AXI_ARVALID => M_AXI_ARVALID,
    M_AXI_ARREADY => M_AXI_ARREADY,
    M_AXI_RID     => M_AXI_RID,
    M_AXI_RDATA   => M_AXI_RDATA,
    M_AXI_RRESP   => M_AXI_RRESP,
    M_AXI_RLAST   => M_AXI_RLAST,
    M_AXI_RVALID  => M_AXI_RVALID,
    M_AXI_RREADY  => M_AXI_RREADY
  );

  reference_buf : bram_buf PORT MAP(
    refclk => refclk,          --! reference clock expect 250Mhz
    rst    => rst_w,           --! sync active high reset. sync -> refclk
    addr   => ref_buf_adr_w,   -- адрес ячейки в буфере (от 0 до 14)
    re     => ref_re_w,        -- read enable
    we     => ref_we_w,        -- write enable (поднять для записи)
    data_i => data_from_axi_w, -- data input
    data_o => ref_data_o_w,    -- data output
    valid  => ref_valid_w
  );

  signal_bufer : bram_buf PORT MAP(
    refclk => refclk,          --! reference clock expect 250Mhz
    rst    => rst_w,           --! sync active high reset. sync -> refclk
    addr   => sig_buf_adr_w,   -- адрес ячейки в буфере (от 0 до 14)
    re     => sig_re_w,        -- read enable
    we     => sig_we_w,        -- write enable (поднять для записи)
    data_i => data_from_axi_w, -- data input
    data_o => sig_data_o_w,    -- data output
    valid  => sig_valid_w
  );

  valid_w <= sig_valid_w AND ref_valid_w;
  corr_module : correlator PORT MAP(
    refclk       => refclk,
    rst          => rst_w,
    en           => corr_en_w,
    ref_input    => ref_data_o_w,
    signal_input => sig_data_o_w,
    valid        => valid_w,
    ref_addr     => both_adr_w,
    bram_re      => both_re_w,
    result       => result_o,
    corr_end     => corr_DONE_w
  );

  reset_polarity_changer : PROCESS (rst)
  BEGIN
    rst_w <= NOT rst;
  END PROCESS reset_polarity_changer;

  splitter_mux : PROCESS (refclk)
  BEGIN
    IF (rising_edge(refclk)) THEN
      IF (axi_en_w = '1') THEN
        IF (flag_w = '0') THEN
          ref_buf_adr_w <= write_addr_w;
          ref_we_w      <= '1';
          ref_re_w      <= '0';

          sig_buf_adr_w <= "ZZZZ";
          sig_we_w      <= 'Z';
          sig_re_w      <= 'Z';

        ELSE
          ref_buf_adr_w <= "ZZZZ";
          ref_we_w      <= 'Z';
          ref_re_w      <= 'Z';

          sig_buf_adr_w <= write_addr_w;
          sig_we_w      <= '1';
          sig_re_w      <= '0';
        END IF;
      ELSIF (corr_en_w = '1') THEN
        ref_buf_adr_w <= both_adr_w;
        ref_we_w      <= '0';
        ref_re_w      <= both_re_w;

        sig_buf_adr_w <= both_adr_w;
        sig_we_w      <= '0';
        sig_re_w      <= both_re_w;
      END IF;
    END IF;
  END PROCESS;

  output_assign : PROCESS (ARLEN_W)
  BEGIN
    M_AXI_ARLEN <= "0000" & ARLEN_W;
  END PROCESS output_assign;
END ARCHITECTURE rtl;
