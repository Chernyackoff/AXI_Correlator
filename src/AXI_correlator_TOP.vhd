
LIBRARY IEEE;--! standard library IEEE (Institute of Electrical and Electronics Engineers)
USE IEEE.std_logic_1164.ALL;--! standard unresolved logic UX01ZWLH-
USE IEEE.numeric_std.ALL;--! for the signed, unsigned types and arithmetic ops

ENTITY AXI_correlator_TOP IS
  PORT (
    axi_aresetn : IN  STD_LOGIC;
    result      : OUT STD_LOGIC;
    refclk      : IN  STD_LOGIC;--! reference clock expect 250Mhz
    rst         : IN  STD_LOGIC--! sync active high reset. sync -> refclk
  );
END ENTITY AXI_correlator_TOP;
ARCHITECTURE rtl OF AXI_correlator_TOP IS
  COMPONENT AXI_CORR_design_wrapper IS
    PORT (
      axi_aresetn : IN  STD_LOGIC;
      refclk      : IN  STD_LOGIC;
      result      : OUT STD_LOGIC;
      rst         : IN  STD_LOGIC
    );
  END COMPONENT;
BEGIN

  wrapper : AXI_CORR_design_wrapper PORT MAP(
    axi_aresetn => axi_aresetn,
    refclk      => refclk,
    result      => result,
    rst         => rst
  );

END ARCHITECTURE rtl;
