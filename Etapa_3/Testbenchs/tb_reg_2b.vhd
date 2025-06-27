library ieee;
use ieee.std_logic_1164.all;

entity tb_reg_2b is
end entity;

architecture test of tb_reg_2b is
    component reg_2b is
        port (clk: in std_logic; rst: in std_logic; enable: in std_logic; in_D: in std_logic_vector(1 downto 0); out_Q: out std_logic_vector(1 downto 0));
    end component;
    
    signal s_clk, s_rst, s_enable : std_logic := '0';
    signal s_in_D, s_out_Q : std_logic_vector(1 downto 0);
begin
    uut: reg_2b port map(s_clk, s_rst, s_enable, s_in_D, s_out_Q);
    s_clk <= not s_clk after 5 ns;
    stimulus: process
    begin
        s_rst <= '1'; wait for 10 ns; s_rst <= '0';
        s_in_D <= "11"; s_enable <= '1'; wait for 10 ns;
        assert (s_out_Q = "11") report "Falha enable" severity error;
        s_enable <= '0'; s_in_D <= "01"; wait for 10 ns;
        assert (s_out_Q = "11") report "Falha hold" severity error;
        wait;
    end process;
end architecture test;