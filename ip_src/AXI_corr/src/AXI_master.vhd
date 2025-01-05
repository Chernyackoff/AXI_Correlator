LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY AXI_master IS
  GENERIC (
    axi_data_width_log2b    : NATURAL RANGE 5 TO 255 := 6;
    axi_address_width_log2b : NATURAL RANGE 5 TO 255 := 5
  );
  PORT (
    refclk : IN STD_LOGIC;--! reference clock expect 250Mhz
    rst    : IN STD_LOGIC;--! sync active high reset. sync -> refclk
    --сигналы для соединения с планировщиком и правильной работы (наверное :)
    read_data     : OUT STD_LOGIC_VECTOR(31 DOWNTO 0); --!эти данные мы записываем в буффер
    read_start    : IN  STD_LOGIC;                     --! это соединяется с axi_enable от планировщика
    read_complete : OUT STD_LOGIC;
    read_result   : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
    read_addr     : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
    write_addr    : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
    -- Global Signals
    M_AXI_ACLK : OUT STD_LOGIC;
    --  Read address channel signals
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
    -- Read data channel signals
    M_AXI_RID    : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
    M_AXI_RDATA  : IN  STD_LOGIC_VECTOR(2 ** axi_data_width_log2b - 1 DOWNTO 0);
    M_AXI_RRESP  : IN  STD_LOGIC_VECTOR(1 DOWNTO 0);
    M_AXI_RLAST  : IN  STD_LOGIC;
    M_AXI_RVALID : IN  STD_LOGIC;
    M_AXI_RREADY : OUT STD_LOGIC

  );
END ENTITY AXI_master;

ARCHITECTURE master OF AXI_master IS
  SIGNAL read_complete_w          : STD_LOGIC;
  SIGNAL counter                  : INTEGER RANGE 0 TO 14 := 0;
  SIGNAL read_addr_w, read_data_w : STD_LOGIC_VECTOR(31 DOWNTO 0);
BEGIN
  --нашла на просторах инета (мб как-то иначе надо)
  M_AXI_ACLK   <= refclk;
  M_AXI_ARQOS  <= (OTHERS => '0');
  M_AXI_ARLOCK <= (OTHERS => '0');
  M_AXI_ARPROT <= (OTHERS => '0');
  M_AXI_ARID   <= (OTHERS => '0');

  --ТУТ возможно надо что-то добавить (запись в буфер принятых данных, ответ планировщику ?)
  send_data : PROCESS (refclk, read_complete_w)
  BEGIN
    IF (rst = '1') THEN
      read_addr_w   <= 32B"ZZZZ";
      write_addr    <= "0000";
      read_data     <= 32B"0";
      read_complete <= '0';
      counter       <= 0;
    ELSIF (read_start) THEN
      read_addr_w   <= STD_LOGIC_VECTOR(to_unsigned(to_integer(unsigned(read_addr)) + counter * 4, 32));
      write_addr    <= STD_LOGIC_VECTOR(to_unsigned(counter, 4));
      read_data     <= read_data_w;
      read_complete <= '0';
      IF (rising_edge(read_complete_w)) THEN
        IF (counter = 14) THEN
          counter       <= 0;
          read_complete <= '1';
        ELSE
          counter <= counter + 1;
        END IF;
      END IF;
    ELSE
      read_addr_w   <= 32B"ZZZZ";
      read_complete <= '0';
    END IF;
  END PROCESS;

  -- reader
  reader : ENTITY work.reader
    GENERIC MAP(
      axi_data_width_log2b    => axi_data_width_log2b,
      axi_address_width_log2b => axi_address_width_log2b
    )
    PORT MAP
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
END ARCHITECTURE master;
