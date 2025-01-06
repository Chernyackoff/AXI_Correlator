
LIBRARY IEEE;--! standard library IEEE (Institute of Electrical and Electronics Engineers)
USE IEEE.std_logic_1164.ALL;--! standard unresolved logic UX01ZWLH-
USE IEEE.numeric_std.ALL;--! for the signed, unsigned types and arithmetic ops

ENTITY correlator IS
  PORT (
    refclk : IN STD_LOGIC;--! reference clock expect 250Mhz
    rst    : IN STD_LOGIC;--! sync active high reset. sync -> refclk
    en     : IN STD_LOGIC;

    ref_input    : IN STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
    signal_input : IN STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');

    valid    : IN  STD_LOGIC;
    ref_addr : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
    bram_re  : OUT STD_LOGIC := '0';

    result   : OUT STD_LOGIC;
    corr_end : OUT STD_LOGIC := '0'
  );
END ENTITY correlator;
ARCHITECTURE rtl OF correlator IS

  SIGNAL corr_sum : INTEGER;
  SIGNAL ref_sum  : INTEGER;
  SIGNAL counter  : INTEGER RANGE 0 TO 14;

  TYPE STATE_T IS (idle, working, result_stage); -- for state machine
  SIGNAL cur_state, next_state : STATE_T;

  SIGNAL load_ended, work_ended, data_ready : BOOLEAN;

  SIGNAL data_sig, data_ref : STD_LOGIC_VECTOR(31 DOWNTO 0);
BEGIN

  -- state switcher
  PROCESS (refclk, rst)
  BEGIN
    IF (rst = '1') THEN
      cur_state <= idle;
    ELSIF (rising_edge(refclk)) THEN
      cur_state <= next_state;
    END IF;
  END PROCESS;

  -- state machine
  PROCESS (refclk)
  BEGIN
    IF (rising_edge(refclk)) THEN
      IF (en) THEN
        CASE(cur_state) IS
          WHEN idle =>
          next_state <= working;

          WHEN working =>
          IF (work_ended) THEN
            next_state <= result_stage;
          END IF;

          WHEN result_stage =>
          next_state <= idle;

          WHEN OTHERS =>
          next_state <= idle;

        END CASE;
      ELSE
        next_state <= idle;
      END IF;
    END IF;
  END PROCESS;

  -- get data
  PROCESS (refclk)
  BEGIN
    IF (rising_edge(refclk)) THEN
      IF (cur_state /= working) THEN
        ref_addr <= 4B"Z";
        bram_re  <= '0';
      ELSE
        IF (counter <= 14) THEN
          ref_addr <= STD_LOGIC_VECTOR(to_unsigned(counter, 4));
          bram_re  <= '1';
          IF (valid) THEN
            data_ready <= true;
            data_ref   <= ref_input;
            data_sig   <= signal_input;
          ELSE
            data_ready <= false;
          END IF;
        END IF;
      END IF;
    END IF;
  END PROCESS;

  -- count summs 
  PROCESS (refclk, cur_state)
    VARIABLE req : BOOLEAN := true;
  BEGIN
    IF (rising_edge(refclk)) THEN
      IF (cur_state = idle) THEN
        corr_sum <= 0;
        ref_sum  <= 0;
        counter  <= 0;
      END IF;

      IF (cur_state = working AND data_ready AND NOT work_ended) THEN
        counter  <= counter + 1;
        corr_sum <= corr_sum + to_integer(signed(data_ref)) * to_integer(signed(data_sig));
        ref_sum  <= ref_sum + to_integer(signed(data_ref)) * to_integer(signed(data_ref));

        IF (counter > 13) THEN
          work_ended <= true;
        END IF;
      ELSE
        work_ended <= false;
      END IF;
    END IF;
  END PROCESS;

  -- result to output
  PROCESS (corr_sum, ref_sum, cur_state, refclk, en)
    VARIABLE ref_pivot : INTEGER;
  BEGIN
    IF rising_edge(refclk) THEN
      IF (en) THEN
        IF (cur_state = result_stage) THEN
          corr_end <= '1';
          ref_pivot := ref_sum * 8 / 10;
          IF (ABS(corr_sum) >= ABS(ref_pivot) AND ABS(corr_sum) <= ABS(ref_sum)) THEN
            result <= '1';
          ELSE
            result <= '0';
          END IF;
        ELSIF (cur_state = working) THEN
          result <= 'Z';
        ELSE
          corr_end <= '0';
        END IF;
      ELSE
        corr_end <= '0';
      END IF;

    END IF;
  END PROCESS;
END ARCHITECTURE rtl;
