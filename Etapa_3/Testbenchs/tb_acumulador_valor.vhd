library ieee;
use ieee.std_logic_1164.all;

entity tb_acumulador_valor is
end entity tb_acumulador_valor;

architecture test of tb_acumulador_valor is
    component Acumulador_Valor is
        port (
            clk        : in  std_logic;
            reset      : in  std_logic;
            add_enable : in  std_logic;
            valor_in   : in  integer range 0 to 255;
            valor_total: out integer range 0 to 255
        );
    end component;

    signal s_clk        : std_logic := '0';
    signal s_reset      : std_logic;
    signal s_add_enable : std_logic;
    signal s_valor_in   : integer range 0 to 255;
    signal s_valor_total: integer range 0 to 255;
    
    constant CLK_PERIOD : time := 10 ns;
begin
    uut: Acumulador_Valor port map (clk, s_reset, s_add_enable, s_valor_in, s_valor_total);
    s_clk <= not s_clk after CLK_PERIOD / 2;

    stimulus: process
    begin
        report "Iniciando teste do Acumulador_Valor...";
        s_reset <= '1';
        s_add_enable <= '0';
        s_valor_in <= 5;
        wait for CLK_PERIOD;
        s_reset <= '0';
        assert (s_valor_total = 0) report "Falha no reset" severity error;

        s_add_enable <= '1';
        s_valor_in <= 25; -- Simula moeda de 25
        wait for CLK_PERIOD;
        assert (s_valor_total = 25) report "Falha na soma 1" severity error;

        s_valor_in <= 50; -- Simula moeda de 50
        wait for CLK_PERIOD;
        assert (s_valor_total = 75) report "Falha na soma 2" severity error;
        
        report "Teste do Acumulador_Valor concluido.";
        wait;
    end process stimulus;
end architecture test;