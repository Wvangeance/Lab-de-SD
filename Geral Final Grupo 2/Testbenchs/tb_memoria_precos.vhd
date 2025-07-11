library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_memoria_precos is
end entity;

architecture test of tb_memoria_precos is
    component memoria_precos is
        port (endereco: in std_logic_vector(1 downto 0); dado_out: out integer range 0 to 255);
    end component;
    
    signal s_endereco : std_logic_vector(1 downto 0);
    signal s_dado_out : integer range 0 to 255;
begin
    uut: memoria_precos port map (s_endereco, s_dado_out);
    stimulus: process
    begin
        s_endereco <= "01"; wait for 10 ns;
        assert (s_dado_out = 150) report "Falha end 01" severity error;
        s_endereco <= "11"; wait for 10 ns;
        assert (s_dado_out = 200) report "Falha end 11" severity error;
        wait;
    end process;
end architecture test;