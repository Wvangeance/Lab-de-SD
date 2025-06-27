library ieee;
use ieee.std_logic_1164.all;

entity tb_moedeiro is
end entity tb_moedeiro;

architecture test of tb_moedeiro is
    component moedeiro is
        port (
            habilita_moedeiro   : in  std_logic;
            sinal_moeda_25c     : in  std_logic;
            sinal_moeda_50c     : in  std_logic;
            sinal_moeda_1real   : in  std_logic;
            valor_moeda         : out integer range 0 to 255
        );
    end component;

    signal s_habilita    : std_logic := '0';
    signal s_moeda_25c   : std_logic := '0';
    signal s_moeda_50c   : std_logic := '0';
    signal s_moeda_1real : std_logic := '0';
    signal s_valor_moeda : integer range 0 to 255;
begin
    uut: moedeiro port map (s_habilita, s_moeda_25c, s_moeda_50c, s_moeda_1real, s_valor_moeda);
    stimulus: process
    begin
        report "Iniciando teste do Moedeiro...";
        s_habilita <= '1';
        wait for 10 ns;
        s_moeda_50c <= '1';
        wait for 10 ns;
        assert (s_valor_moeda = 50) report "Falha: Moeda de 50c" severity error;
        s_moeda_50c <= '0';
        wait for 10 ns;
        report "Teste do Moedeiro concluido.";
        wait;
    end process;
end architecture test;