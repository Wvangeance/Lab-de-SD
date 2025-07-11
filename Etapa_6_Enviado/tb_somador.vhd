library ieee;
use ieee.std_logic_1164.all;

entity tb_somador is
end entity tb_somador;

architecture test of tb_somador is
    component somador is
        port (
            in_A  : in  integer range 0 to 255;
            in_B  : in  integer range 0 to 255;
            out_S : out integer range 0 to 255
        );
    end component;

    signal s_in_A, s_in_B, s_out_S : integer range 0 to 255;

begin
    uut: somador port map (s_in_A, s_in_B, s_out_S);

    stimulus: process
    begin
        report "Iniciando teste do Somador...";
        
        s_in_A <= 50;
        s_in_B <= 75;
        wait for 10 ns;
        assert (s_out_S = 125) report "Falha: 50 + 75 = 125" severity error;
        
        s_in_A <= 200;
        s_in_B <= 55;
        wait for 10 ns;
        assert (s_out_S = 255) report "Falha: 200 + 55 = 255" severity error;
        
        report "Teste do Somador concluido.";
        wait;
    end process;
end architecture test;