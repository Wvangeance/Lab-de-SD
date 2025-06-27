library ieee;
use ieee.std_logic_1164.all;

entity tb_mux_2x1_2b is
end entity;

architecture test of tb_mux_2x1_2b is
    component mux_2x1_2b is
        port (sel: in std_logic; in_A: in std_logic_vector(1 downto 0); in_B: in std_logic_vector(1 downto 0); out_S: out std_logic_vector(1 downto 0));
    end component;
    
    signal s_sel : std_logic;
    signal s_in_A, s_in_B, s_out_S : std_logic_vector(1 downto 0);
begin
    uut: mux_2x1_2b port map (s_sel, s_in_A, s_in_B, s_out_S);
    stimulus: process
    begin
        s_in_A <= "01"; s_in_B <= "10";
        s_sel <= '0'; wait for 10 ns;
        assert (s_out_S = "01") report "Falha sel=0" severity error;
        s_sel <= '1'; wait for 10 ns;
        assert (s_out_S = "10") report "Falha sel=1" severity error;
        wait;
    end process;
end architecture test;