library ieee;
use ieee.std_logic_1164.all;

entity tb_comparador is
end entity tb_comparador;

architecture test of tb_comparador is
    component comparador is
        port (
            in_A  : in  integer range 0 to 255;
            in_B  : in  integer range 0 to 255;
            out_S : out std_logic
        );
    end component;

    signal s_in_A, s_in_B : integer range 0 to 255;
    signal s_out_S : std_logic;

begin
    uut: comparador port map (s_in_A, s_in_B, s_out_S);

    stimulus: process
    begin
        report "Iniciando teste do Comparador...";
        
        -- Teste A > B
        s_in_A <= 100;
        s_in_B <= 50;
        wait for 10 ns;
        assert (s_out_S = '1') report "Falha: A > B deveria ser '1'" severity error;

        -- Teste A = B
        s_in_A <= 100;
        s_in_B <= 100;
        wait for 10 ns;
        assert (s_out_S = '1') report "Falha: A = B deveria ser '1'" severity error;
        
        -- Teste A < B
        s_in_A <= 50;
        s_in_B <= 100;
        wait for 10 ns;
        assert (s_out_S = '0') report "Falha: A < B deveria ser '0'" severity error;
        
        report "Teste do Comparador concluido.";
        wait;
    end process;
end architecture test;