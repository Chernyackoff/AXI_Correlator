
library IEEE;--! standard library IEEE (Institute of Electrical and Electronics Engineers)
use IEEE.std_logic_1164.all;--! standard unresolved logic UX01ZWLH-
use IEEE.numeric_std.all;--! for the signed, unsigned types and arithmetic ops

entity AXI_correlator_TOP is
  port (
    refclk : in std_logic;--! reference clock expect 250Mhz
    rst    : in std_logic--! sync active high reset. sync -> refclk
  );
end entity AXI_correlator_TOP;
architecture rtl of AXI_correlator_TOP is
  component AXI_CORR_design_wrapper is
    port (
      axi_aresetn : in std_logic;
      refclk      : in std_logic;
      result      : out std_logic;
      rst         : in std_logic
    );
  end component;
begin
end architecture rtl;
