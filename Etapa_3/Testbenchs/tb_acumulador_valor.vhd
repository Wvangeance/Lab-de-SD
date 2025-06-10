library ieee;
use ieee.std_logic_1164.all;

entity tb_acumulador_valor is
end entity tb_acumulador_valor;

architecture test of tb_acumulador_valor is
    -- Componente
    component Acumulador_Valor is
        port (
            clk        : in  std_logic;
            reset      : in  std_logic;
            add_enable : in  std_logic;
            valor_in   : in  integer range 0 to 255;
            valor_total: out integer range 0 to 255
        );
    end component;

    -- Sinais
    signal s_clk        : std_logic := '0';
    signal s_reset      : std_logic;
    signal s_add_enable : std_logic;
    signal s_valor_in   : integer range 0 to 255;
    signal s_valor_total: integer range 0 to 255;
    
    constant CLK_PERIOD : time := 10 ns;
begin
    -- Instância
    uut: Acumulador_Valor port map (
        clk        => s_clk,
        reset      => s_reset,
        add_enable => s_add_enable,
        valor_in   => s_valor_in,
        valor_total=> s_valor_total
    );

    -- Clock
    s_clk <= not s_clk after CLK_PERIOD / 2;

    -- Estímulo
    stimulus: process
    begin
        report "Iniciando teste do Acumulador_Valor...";

        -- 1. Teste de Reset
        s_reset <= '1';
        s_add_enable <= '0';
        s_valor_in <= 5;
        wait for CLK_PERIOD;
        s_reset <= '0';
        assert (s_valor_total = 0) report "Falha no reset. Esperado: 0" severity error;

        -- 2. Teste de Acumulação
        report "Testando acumulacao...";
        s_add_enable <= '1';
        s_valor_in <= 2;
        wait for CLK_PERIOD; -- Acumula 2
        assert (s_valor_total = 2) report "Falha na soma 1" severity error;

        s_valor_in <= 3;
        wait for CLK_PERIOD; -- Acumula 3 (total 5)
        assert (s_valor_total = 5) report "Falha na soma 2" severity error;
        
        -- 3. Teste de 'Hold' (não somar)
        s_add_enable <= '0';
        s_valor_in <= 10;
        wait for CLK_PERIOD; -- Não deve somar 10
        assert (s_valor_total = 5) report "Falha no hold. Valor deveria ser 5." severity error;

        report "Teste do Acumulador_Valor concluido.";
        wait;
    end process stimulus;

end architecture test;