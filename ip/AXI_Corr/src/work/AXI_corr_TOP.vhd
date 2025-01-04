
LIBRARY IEEE;--! standard library IEEE (Institute of Electrical and Electronics Engineers)
USE IEEE.std_logic_1164.ALL;--! standard unresolved logic UX01ZWLH-
USE IEEE.numeric_std.ALL;--! for the signed, unsigned types and arithmetic ops

entity AXI_corr_TOP is
  PORT (
    refclk : IN STD_LOGIC;--! reference clock expect 250Mhz
    rst    : IN STD_LOGIC;--! sync active high reset. sync -> refclk
  
    -- Global Signals
    M_AXI_ACLK          :   out STD_LOGIC;
   --  Read address channel signals
    M_AXI_ARID          :   out STD_LOGIC_VECTOR(2 downto 0);
    M_AXI_ARADDR        :   out STD_LOGIC_VECTOR(31 downto 0);
    M_AXI_ARLEN         :   out STD_LOGIC_VECTOR(7 downto 0);
    M_AXI_ARSIZE        :   out STD_LOGIC_VECTOR(2 downto 0);
    M_AXI_ARBURST       :   out STD_LOGIC_VECTOR(1 downto 0);
    M_AXI_ARLOCK        :   out STD_LOGIC_VECTOR(1 downto 0);
    M_AXI_ARCACHE       :   out STD_LOGIC_VECTOR(3 downto 0);
    M_AXI_ARPROT        :   out STD_LOGIC_VECTOR(2 downto 0);
    M_AXI_ARQOS         :   out STD_LOGIC_VECTOR(3 downto 0);
    M_AXI_ARUSER        :   out STD_LOGIC_VECTOR(4 downto 0);
    M_AXI_ARVALID       :   out STD_LOGIC;
    M_AXI_ARREADY       :   in  STD_LOGIC;
   -- Read data channel signals
    M_AXI_RID           :   in  STD_LOGIC_VECTOR(2 downto 0);
    M_AXI_RDATA         :   in  STD_LOGIC_VECTOR(31 downto 0);
    M_AXI_RRESP         :   in  STD_LOGIC_VECTOR(1 downto 0);
    M_AXI_RLAST         :   in  STD_LOGIC;
    M_AXI_RVALID        :   in  STD_LOGIC;
    M_AXI_RREADY        :   out STD_LOGIC;

    
    -- Fake channels to meet AXI4 requirements
    -- M_AXI_AWADDR : OUT STD_LOGIC_VECTOR(14 downto 0);
    -- M_AXI_AWBURST: OUT STD_LOGIC_VECTOR(1 downto 0);
    -- M_AXI_AWCACHE: OUT STD_LOGIC_VECTOR(3 downto 0);
    -- M_AXI_AWLEN  : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
    -- M_AXI_AWLOCK : OUT STD_LOGIC;
    -- M_AXI_AWPROT : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
    -- M_AXI_AWREADY: IN STD_LOGIC;
    -- M_AXI_AWSIZE : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
    -- M_AXI_AWVALID: OUT STD_LOGIC;
    -- M_AXI_BREADY : OUT STD_LOGIC;
    -- M_AXI_BRESP  : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
    -- M_AXI_BVALID : IN STD_LOGIC;
    -- M_AXI_WDATA  : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    -- M_AXI_WLAST  : OUT STD_LOGIC;
    -- M_AXI_WREADY : IN STD_LOGIC;
    -- M_AXI_WSTRB  : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
    -- M_AXI_WVALID : OUT STD_LOGIC;
  
    result_o            :   out STD_LOGIC
  );
end entity AXI_corr_TOP;
architecture rtl of AXI_corr_TOP is
  component AXI_master is
    generic (
      axi_data_width_log2b    :   natural range 5 to 255 := 6;
      axi_address_width_log2b :   natural range 5 to 255 := 5
     );
  PORT (
    refclk              :   IN STD_LOGIC;--! reference clock expect 250Mhz
    rst                 :   IN STD_LOGIC;--! sync active high reset. sync -> refclk
    read_data           :   out STD_LOGIC_VECTOR(31 downto 0); --!эти данные мы записываем в буффер
    read_start          :   in  STD_LOGIC;  --! это соединяется с axi_enable от планировщика
    read_complete       :   out STD_LOGIC;
    read_result         :   out STD_LOGIC_VECTOR(1 downto 0);
    read_addr           :   IN STD_LOGIC_VECTOR(31 downto 0);
    write_addr          :   OUT STD_LOGIC_VECTOR(3 downto 0);
    M_AXI_ACLK          :   out STD_LOGIC;
    M_AXI_ARID          :   out STD_LOGIC_VECTOR(2 downto 0);
    M_AXI_ARADDR        :   out STD_LOGIC_VECTOR(2**axi_address_width_log2b - 1 downto 0);
    M_AXI_ARLEN         :   out STD_LOGIC_VECTOR(3 downto 0);
    M_AXI_ARSIZE        :   out STD_LOGIC_VECTOR(2 downto 0);
    M_AXI_ARBURST       :   out STD_LOGIC_VECTOR(1 downto 0);
    M_AXI_ARLOCK        :   out STD_LOGIC_VECTOR(1 downto 0);
    M_AXI_ARCACHE       :   out STD_LOGIC_VECTOR(3 downto 0);
    M_AXI_ARPROT        :   out STD_LOGIC_VECTOR(2 downto 0);
    M_AXI_ARQOS         :   out STD_LOGIC_VECTOR(3 downto 0);
    M_AXI_ARUSER        :   out STD_LOGIC_VECTOR(4 downto 0);
    M_AXI_ARVALID       :   out STD_LOGIC;
    M_AXI_ARREADY       :   in  STD_LOGIC;
    M_AXI_RID           :   in  STD_LOGIC_VECTOR(2 downto 0);
    M_AXI_RDATA         :   in  STD_LOGIC_VECTOR(2**axi_data_width_log2b - 1 downto 0);
    M_AXI_RRESP         :   in  STD_LOGIC_VECTOR(1 downto 0);
    M_AXI_RLAST         :   in  STD_LOGIC;
    M_AXI_RVALID        :   in  STD_LOGIC;
    M_AXI_RREADY        :   out STD_LOGIC
  );
  end component;
  
  component bram_buf is
    PORT (
      refclk : IN STD_LOGIC;--! reference clock expect 250Mhz
      rst    : IN STD_LOGIC;--! sync active high reset. sync -> refclk
    
      addr   : IN STD_LOGIC_VECTOR(3 downto 0); -- адрес ячейки в буфере (от 0 до 14)
      re     : IN STD_LOGIC;                    -- read enable
      we     : IN STD_LOGIC;                    -- write enable (поднять для записи)
    
      data_i : IN STD_LOGIC_VECTOR(31 downto 0);    -- data input
      data_o : OUT STD_LOGIC_VECTOR(31 downto 0);   -- data output
      valid  : OUT STD_LOGIC
    );
  end component;

  component correlator is
    PORT (
      refclk : IN STD_LOGIC;--! reference clock expect 250Mhz
      rst    : IN STD_LOGIC;--! sync active high reset. sync -> refclk
      en     : IN STD_LOGIC;
    
      ref_input   : IN STD_LOGIC_VECTOR(31 downto 0) := (OTHERS => '0');
      signal_input : IN STD_LOGIC_VECTOR(31 downto 0) := (OTHERS => '0');
    
      valid     : IN  STD_LOGIC;
      ref_addr  : OUT STD_LOGIC_VECTOR(3 downto 0);
      bram_re   : OUT STD_LOGIC := '0';
    
      result    : OUT STD_LOGIC := '0';
      corr_end  : OUT STD_LOGIC := '0'
    );
  end component;

  component planner is

    PORT (
      refclk           : IN STD_LOGIC;--! reference clock expect 250Mhz
      rst              : IN STD_LOGIC;--! sync active high reset. sync -> refclk
      read_complete    : IN STD_LOGIC;--! when data(ref\ref) is reading
      corr_DONE        : IN STD_LOGIC;--! когда корреляция завершилось (принимаем этот сигнал от коррелятора, когда он закончил обработку)
      axi_address      : OUT STD_LOGIC_VECTOR(31 downto 0); --! 
      axi_enabl        : OUT STD_LOGIC;
      flag             : OUT STD_LOGIC;
      corr_enable      : OUT STD_LOGIC;
      buff_ref         : IN STD_LOGIC; --! пустой ли буфер для референса
      buff_seq         : IN STD_LOGIC --! пустой ли буфер для последовательности
    );
  end component;
  
  -- logic wires planner to others
  signal read_cmplt_w, corr_DONE_w, axi_en_w, flag_w, corr_en_w, buff_ref_w, buff_seq_w : STD_LOGIC;
  signal axi_adr_w : STD_LOGIC_VECTOR(31 downto 0); 

  -- data wires
  signal data_from_axi_w : STD_LOGIC_VECTOR(31 downto 0); 

  -- wires to work with buffers
  signal ref_buf_adr_w, sig_buf_adr_w, both_adr_w, write_addr_w : STD_LOGIC_VECTOR(3 downto 0);
  signal ref_re_w, ref_we_w, ref_valid_w, sig_re_w, sig_we_w, sig_valid_w, both_re_w : STD_LOGIC;
  signal ref_data_i_w, ref_data_o_w, sig_data_i_w, sig_data_o_w : STD_LOGIC_VECTOR(31 downto 0);

begin
  -- port => wire 
  planer_module : planner port map (
    refclk        => refclk,
    rst           => rst,
    read_complete => read_cmplt_w,    
    corr_DONE     => corr_DONE_w,
    axi_address   => axi_adr_w,       
    axi_enabl     => axi_en_w,        
    flag          => flag_w,             
    corr_enable   => corr_en_w,      
    buff_ref      => buff_ref_w,         
    buff_seq      => buff_seq_w         
  ); 

  AXI_MM_module : AXI_master generic map ( axi_data_width_log2b => 5, axi_address_width_log2b => 5)
    port    map (
      refclk        =>refclk,
      rst           => rst,
      read_data     => data_from_axi_w,
      read_start    => axi_en_w,
      read_complete => read_cmplt_w,
      write_addr    => write_addr_w,
      -- => read_result,
      read_addr     => axi_adr_w,

      M_AXI_ACLK    => M_AXI_ACLK,
      M_AXI_ARID    => M_AXI_ARID,
      M_AXI_ARADDR  => M_AXI_ARADDR,
      M_AXI_ARLEN   => M_AXI_ARLEN,
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

  reference_buf : bram_buf port map (
    refclk  => refclk,  --! reference clock expect 250Mhz
    rst     => rst,     --! sync active high reset. sync -> refclk
    addr    => ref_buf_adr_w,    -- адрес ячейки в буфере (от 0 до 14)
    re      => ref_re_w,      -- read enable
    we      => ref_we_w,      -- write enable (поднять для записи)
    data_i  => ref_data_i_w,  -- data input
    data_o  => ref_data_o_w,  -- data output
    valid   => ref_valid_w  
  );

  signal_bufer : bram_buf port map (
    refclk => refclk,         --! reference clock expect 250Mhz
    rst    => rst,            --! sync active high reset. sync -> refclk
    addr   => sig_buf_adr_w,  -- адрес ячейки в буфере (от 0 до 14)
    re     => sig_re_w,       -- read enable
    we     => sig_we_w,       -- write enable (поднять для записи)
    data_i => sig_data_i_w,   -- data input
    data_o => sig_data_o_w,   -- data output
    valid  => sig_valid_w  
  );

  corr_module : correlator port map (
    refclk       => refclk,
    rst          => rst,
    en           => corr_en_w,
    ref_input    => ref_data_o_w,
    signal_input => sig_data_o_w,
    valid        => sig_valid_w and ref_valid_w,
    ref_addr     => both_adr_w,
    bram_re      => both_re_w,
    result       => result_o,
    corr_end     => corr_DONE_w
  );


  splitter_mux : process (refclk)
  begin
    if(rising_edge(refclk)) then
      if (axi_en_w = '1') then
        if (flag_w = '0') then
          ref_buf_adr_w <= write_addr_w;
          ref_we_w <= '1';
          ref_re_w <= '0';

          sig_buf_adr_w <= "ZZZZ";
          sig_we_w <= 'Z';
          sig_re_w <= 'Z';

        else
          ref_buf_adr_w <= "ZZZZ";
          ref_we_w <= 'Z';
          ref_re_w <= 'Z';

          sig_buf_adr_w <= write_addr_w;
          sig_we_w <= '1';
          sig_re_w <= '0';
        end if;
      elsif (corr_en_w = '1') then
        ref_buf_adr_w <= both_adr_w;
        ref_we_w <= '0';
        ref_re_w <= both_re_w;

        sig_buf_adr_w <= both_adr_w;
        sig_we_w <= '0';
        sig_re_w <= both_re_w;
      end if;
    end if;
  end process;

end architecture rtl;

