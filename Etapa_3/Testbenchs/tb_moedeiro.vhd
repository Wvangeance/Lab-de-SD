library ieee;
use ieee.std_logic_1164.all;

entity tb_moedeiro is
end entity tb_moedeiro;

architecture test of tb_moedeiro is
    component Moedeiro is
        port (
            habilita_moedeiro   : in  std_logic;
            sinal_moeda_25c     : in  std_logic;
            sinal_moeda_50c     : in  std_logic;
            sinal_moeda_1real   : in  std_logic;
            valor_moeda         : out integer range 0 to 255
        );
    end component;

    signal s_habilita         : std_logic := '0';
    signal s_moeda_25c        : std_logic := '0';
    signal s_moeda_50c        : std_logic := '0';
    signal s_moeda_1real      : std_logic := '0';
    signal s_valor_moeda      : integer range 0 to 255;
begin
    uut: Moedeiro port map (s_habilita, s_moeda_25c, s_moeda_50c, s_moeda_1real, s_valor_moeda);

    stimulus: process
    begin
        report "Iniciando teste do Moedeiro...";
        -- Teste 1: Moedeiro desabilitado
        s_habilita <= '0';
        s_moeda_1real <= '1';
        wait for 10 ns;
        assert (s_valor_moeda = 0) report "Falha: Moedeiro desabilitado deveria sair 0" severity error;
        s_moeda_1real <= '0';
        
        -- Teste 2: Moedeiro habilitado
        s_habilita <= '1';
        wait for 10 ns;
        
        s_moeda_25c <= '1';
        wait for 10 ns;
        assert (s_valor_moeda = 25) report "Falha: Moeda de 25c" severity error;
        s_moeda_25c <= '0';
        wait for 10 ns;
        
        s_moeda_1real <= '1';
        wait for 10 ns;
        assert (s_valor_moeda = 100) report "Falha: Moeda de 1 real" severity error;
        s_moeda_1real <= '0';
        wait for 10 ns;
        
        report "Teste do Moedeiro concluido.";
        wait;
    end process;
end architecture test;