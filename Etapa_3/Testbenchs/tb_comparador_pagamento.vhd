library ieee;
use ieee.std_logic_1164.all;

entity tb_comparador_pagamento is
end entity tb_comparador_pagamento;

architecture test of tb_comparador_pagamento is
    -- Componente
    component Comparador_Pagamento is
        port (
            valor_acumulado : in  integer range 0 to 255;
            preco_produto   : in  integer range 0 to 255;
            valor_suficiente: out std_logic
        );
    end component;

    -- Sinais
    signal s_valor_acumulado : integer range 0 to 255;
    signal s_preco_produto   : integer range 0 to 255;
    signal s_valor_suficiente: std_logic;

begin
    -- Instância
    uut: Comparador_Pagamento port map (
        valor_acumulado  => s_valor_acumulado,
        preco_produto    => s_preco_produto,
        valor_suficiente => s_valor_suficiente
    );

    -- Estímulo
    stimulus: process
    begin
        report "Iniciando teste do Comparador_Pagamento...";
        
        -- Caso 1: Valor menor
        s_preco_produto <= 10;
        s_valor_acumulado <= 5;
        wait for 10 ns;
        assert (s_valor_suficiente = '0') report "Falha: valor menor" severity error;

        -- Caso 2: Valor igual
        s_valor_acumulado <= 10;
        wait for 10 ns;
        assert (s_valor_suficiente = '1') report "Falha: valor igual" severity error;
        
        -- Caso 3: Valor maior
        s_valor_acumulado <= 15;
        wait for 10 ns;
        assert (s_valor_suficiente = '1') report "Falha: valor maior" severity error;

        report "Teste do Comparador_Pagamento concluido.";
        wait;
    end process stimulus;
end architecture test;