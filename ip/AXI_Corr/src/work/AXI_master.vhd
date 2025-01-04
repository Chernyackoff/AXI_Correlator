library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity AXI_master is
  generic (
    axi_data_width_log2b    : natural range 5 to 255 := 6;
    axi_address_width_log2b : natural range 5 to 255 := 5
  );
  port (
    refclk : in std_logic;--! reference clock expect 250Mhz
    rst    : in std_logic;--! sync active high reset. sync -> refclk
    --сигналы для соединения с планировщиком и правильной работы (наверное :)
    read_data     : out std_logic_vector(31 downto 0); --!эти данные мы записываем в буффер
    read_start    : in std_logic; --! это соединяется с axi_enable от планировщика
    read_complete : out std_logic;
    read_result   : out std_logic_vector(1 downto 0);
    read_addr     : in std_logic_vector(31 downto 0);
    write_addr    : out std_logic_vector(3 downto 0);
    -- Global Signals
    M_AXI_ACLK : out std_logic;
    --  Read address channel signals
    M_AXI_ARID    : out std_logic_vector(2 downto 0);
    M_AXI_ARADDR  : out std_logic_vector(2 ** axi_address_width_log2b - 1 downto 0);
    M_AXI_ARLEN   : out std_logic_vector(3 downto 0);
    M_AXI_ARSIZE  : out std_logic_vector(2 downto 0);
    M_AXI_ARBURST : out std_logic_vector(1 downto 0);
    M_AXI_ARLOCK  : out std_logic_vector(1 downto 0);
    M_AXI_ARCACHE : out std_logic_vector(3 downto 0);
    M_AXI_ARPROT  : out std_logic_vector(2 downto 0);
    M_AXI_ARQOS   : out std_logic_vector(3 downto 0);
    M_AXI_ARUSER  : out std_logic_vector(4 downto 0);
    M_AXI_ARVALID : out std_logic;
    M_AXI_ARREADY : in std_logic;
    -- Read data channel signals
    M_AXI_RID    : in std_logic_vector(2 downto 0);
    M_AXI_RDATA  : in std_logic_vector(2 ** axi_data_width_log2b - 1 downto 0);
    M_AXI_RRESP  : in std_logic_vector(1 downto 0);
    M_AXI_RLAST  : in std_logic;
    M_AXI_RVALID : in std_logic;
    M_AXI_RREADY : out std_logic

  );
end entity AXI_master;

architecture master of AXI_master is
  signal read_complete_w          : std_logic;
  signal counter                  : integer range 0 to 14 := 0;
  signal read_addr_w, read_data_w : std_logic_vector(31 downto 0);
begin
  --нашла на просторах инета (мб как-то иначе надо)
  M_AXI_ACLK   <= refclk;
  M_AXI_ARQOS  <= (others => '0');
  M_AXI_ARLOCK <= (others => '0');
  M_AXI_ARPROT <= (others => '0');
  M_AXI_ARID   <= (others => '0');

  --ТУТ возможно надо что-то добавить (запись в буфер принятых данных, ответ планировщику ?)
  send_data : process (refclk, read_complete_w)
  begin
    if (rst = '1') then
      read_addr_w <= 32B"ZZZZ";
      write_addr <= "0000";
      read_data <= 32B"0";
      read_complete <= '0';
      counter <= 0;
    elsif (read_start) then
      read_addr_w   <= std_logic_vector(to_unsigned(to_integer(unsigned(read_addr)) + counter * 4, 32));
      write_addr    <= std_logic_vector(to_unsigned(counter, 4));
      read_data     <= read_data_w;
      read_complete <= '0';
      if (rising_edge(read_complete_w)) then
        if (counter = 14) then
          counter       <= 0;
          read_complete <= '1';
        else
          counter <= counter + 1;
        end if;
      end if;
    else
      read_addr_w   <= 32B"ZZZZ";
      read_complete <= '0';
    end if;
  end process;

  -- reader
  reader : entity work.reader
    generic map(
      axi_data_width_log2b    => axi_data_width_log2b,
      axi_address_width_log2b => axi_address_width_log2b
    )
    port map
    (
      refclk        => refclk,
      rst           => rst,
      read_addr     => read_addr_w,
      read_data     => read_data_w,
      read_start    => read_start,
      read_complete => read_complete_w,
      read_result   => read_result,
      M_AXI_ARADDR  => M_AXI_ARADDR,
      M_AXI_ARLEN   => M_AXI_ARLEN,
      M_AXI_ARSIZE  => M_AXI_ARSIZE,
      M_AXI_ARBURST => M_AXI_ARBURST,
      M_AXI_ARCACHE => M_AXI_ARCACHE,
      M_AXI_ARUSER  => M_AXI_ARUSER,
      M_AXI_ARVALID => M_AXI_ARVALID,
      M_AXI_ARREADY => M_AXI_ARREADY,
      M_AXI_RDATA   => M_AXI_RDATA,
      M_AXI_RRESP   => M_AXI_RRESP,
      M_AXI_RLAST   => M_AXI_RLAST,
      M_AXI_RVALID  => M_AXI_RVALID,
      M_AXI_RREADY  => M_AXI_RREADY
    );
end architecture master;