library ieee;
use ieee.std_logic_1164.all;

entity tb_subtrator is
end entity tb_subtrator;

architecture test of tb_subtrator is
    component subtrator is
        port (
            in_A  : in  integer range 0 to 255;
            in_B  : in  integer range 0 to 255;
            out_S : out integer range 0 to 255
        );
    end component;

    signal s_in_A, s_in_B, s_out_S : integer range 0 to 255;

begin
    uut: subtrator port map (s_in_A, s_in_B, s_out_S);

    stimulus: process
    begin
        report "Iniciando teste do Subtrator...";
        
        s_in_A <= 200;
        s_in_B <= 75;
        wait for 10 ns;
        assert (s_out_S = 125) report "Falha: 200 - 75 = 125" severity error;
        
        -- Teste de caso limite (underflow)
        s_in_A <= 50;
        s_in_B <= 100;
        wait for 10 ns;
        assert (s_out_S = 0) report "Falha: subtracao com underflow deveria resultar em 0" severity error;
        
        report "Teste do Subtrator concluido.";
        wait;
    end process;
end architecture test;