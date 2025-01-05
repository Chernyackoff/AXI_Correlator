LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY planner IS

  PORT (
    refclk        : IN  STD_LOGIC;--! reference clock expect 250Mhz
    rst           : IN  STD_LOGIC;--! sync active high reset. sync -> refclk
    read_complete : IN  STD_LOGIC;--! when data(seq\ref) is reading
    corr_DONE     : IN  STD_LOGIC;--! когда корреляция завершилось (принимаем этот сигнал от коррелятора, когда он закончил обработку)
    axi_address   : OUT STD_LOGIC_VECTOR(31 DOWNTO 0); --! 
    axi_enabl     : OUT STD_LOGIC;
    flag          : OUT STD_LOGIC; -- ref\seq flag
    corr_enable   : OUT STD_LOGIC
    --   buff_ref         : IN STD_LOGIC; --! пустой ли буфер для референса
    --   buff_seq         : IN STD_LOGIC --! пустой ли буфер для последовательности
  );
END ENTITY planner;

ARCHITECTURE planner OF planner IS
  --! state machine
  TYPE state IS (idle, read_seq, read_ref, corr);
  SIGNAL fsm : state;

BEGIN
  clk_main : PROCESS (refclk, rst)
  BEGIN
    IF rst = '0' THEN
      fsm         <= idle;
      axi_address <= 32X"0";
      axi_enabl   <= '0';
      flag        <= '0';
      corr_enable <= '0';
    ELSIF rising_edge(refclk) THEN
      CASE fsm IS
        WHEN idle =>
          axi_address <= (OTHERS => '0');
          axi_enabl   <= '0';
          flag        <= '0';
          corr_enable <= '0';
          -- if (buff_ref = '1' and buff_seq = '1') then
          fsm <= read_seq;
          -- end if; 
        WHEN read_seq =>
          axi_address <= "00100000001000000010000000100000"; --! i don`t know :()
          axi_enabl   <= '1';
          flag        <= '1';           --! seq flag
          IF (read_complete = '1') THEN --! мастер считал нужное кол-во данных
            fsm       <= read_ref;
            axi_enabl <= '0';
          END IF;
        WHEN read_ref =>
          axi_address <= "00100000001000000110001000101000"; --! i don`t know :()
          axi_enabl   <= '1';
          flag        <= '0';           --! ref flag
          IF (read_complete = '1') THEN --! мастер считал нужное кол-во данных
            fsm       <= corr;
            axi_enabl <= '0';

          END IF;

        WHEN corr =>
          corr_enable <= '1';
          fsm         <= idle;

        WHEN OTHERS => fsm <= idle;
      END CASE;
    END IF;
  END PROCESS;

END ARCHITECTURE planner;
