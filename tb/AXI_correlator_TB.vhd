
LIBRARY IEEE;--! standard library IEEE (Institute of Electrical and Electronics Engineers)
USE IEEE.std_logic_1164.ALL;--! standard unresolved logic UX01ZWLH-
USE IEEE.numeric_std.ALL;--! for the signed, unsigned types and arithmetic ops

ENTITY AXI_correlator_TB IS
  GENERIC (
    EDGE_CLK : TIME := 2 ns
  );
END ENTITY AXI_correlator_TB;
ARCHITECTURE rtl OF AXI_correlator_TB IS
  SIGNAL rst            : STD_LOGIC := '1';
  SIGNAL refclk         : STD_LOGIC := '0';
  SIGNAL test_completed : BOOLEAN   := false;
  SIGNAL axi_reset      : STD_LOGIC := '1';
  SIGNAL res            : STD_LOGIC;
  COMPONENT AXI_correlator_TOP IS
    PORT (
      axi_aresetn : IN  STD_LOGIC;
      result      : OUT STD_LOGIC;
      refclk      : IN  STD_LOGIC;--! reference clock expect 250Mhz
      rst         : IN  STD_LOGIC--! sync active high reset. sync -> refclk
    );
  END COMPONENT;
BEGIN

  AXI_correlator_TOP_inst : AXI_correlator_TOP
  PORT MAP
  (
    axi_aresetn => axi_reset,
    result      => res,
    refclk      => refclk,
    rst         => rst
  );

  test_clk_generator : PROCESS
  BEGIN
    IF NOT test_completed THEN
      refclk <= NOT refclk;
      WAIT FOR EDGE_CLK;
    ELSE
      WAIT;
    END IF;
  END PROCESS test_clk_generator;

  test_bench_main : PROCESS
  BEGIN
    wait until rising_edge(refclk);
    IF (res = '1') THEN
      test_completed <= true;
      WAIT;
    END IF;
  END PROCESS test_bench_main;
END ARCHITECTURE rtl;
