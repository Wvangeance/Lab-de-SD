library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_datapath is
end entity tb_datapath;

architecture test of tb_datapath is

    -- Declaração do componente a ser testado
    component datapath is
        port (
            clk                      : in  std_logic;
            reset                    : in  std_logic;
            product_select_buy       : in  std_logic_vector(1 downto 0);
            product_select_replenish : in  std_logic_vector(1 downto 0);
            money_in                 : in  integer range 0 to 255;
            replenish_quantity       : in  integer range 0 to 255;
            sel_op_compra            : in  std_logic;
            load_sel_compra_enable   : in  std_logic;
            load_sel_repo_enable     : in  std_logic;
            acumulador_add_enable    : in  std_logic;
            acumulador_reset         : in  std_logic;
            estoque_write_enable     : in  std_logic;
            estoque_decrementa       : in  std_logic;
            QTD_ok                   : out std_logic;
            valor_suficiente         : out std_logic;
            price_display            : out integer range 0 to 255;
            quantity_display         : out integer range 0 to 255
        );
    end component;

    -- Sinais para conectar ao componente
    signal s_clk                    : std_logic := '0';
    signal s_reset                  : std_logic;
    signal s_product_select_buy     : std_logic_vector(1 downto 0);
    signal s_product_select_replenish : std_logic_vector(1 downto 0);
    signal s_money_in               : integer range 0 to 255;
    signal s_replenish_quantity     : integer range 0 to 255;
    signal s_sel_op_compra          : std_logic;
    signal s_load_sel_compra_enable : std_logic;
    signal s_load_sel_repo_enable   : std_logic;
    signal s_acumulador_add_enable  : std_logic;
    signal s_acumulador_reset       : std_logic;
    signal s_estoque_write_enable   : std_logic;
    signal s_estoque_decrementa     : std_logic;
    signal s_QTD_ok                 : std_logic;
    signal s_valor_suficiente       : std_logic;
    signal s_price_display          : integer range 0 to 255;
    signal s_quantity_display       : integer range 0 to 255;
    
    constant CLK_PERIOD : time := 10 ns;

begin
    -- Instanciação do componente (Unit Under Test)
    UUT: datapath port map (
        clk                      => s_clk,
        reset                    => s_reset,
        product_select_buy       => s_product_select_buy,
        product_select_replenish => s_product_select_replenish,
        money_in                 => s_money_in,
        replenish_quantity       => s_replenish_quantity,
        sel_op_compra            => s_sel_op_compra,
        load_sel_compra_enable   => s_load_sel_compra_enable,
        load_sel_repo_enable     => s_load_sel_repo_enable,
        acumulador_add_enable    => s_acumulador_add_enable,
        acumulador_reset         => s_acumulador_reset,
        estoque_write_enable     => s_estoque_write_enable,
        estoque_decrementa       => s_estoque_decrementa,
        QTD_ok                   => s_QTD_ok,
        valor_suficiente         => s_valor_suficiente,
        price_display            => s_price_display,
        quantity_display         => s_quantity_display
    );

    -- Geração do sinal de clock
    s_clk <= not s_clk after CLK_PERIOD / 2;

    -- Processo de estímulo
    stimulus: process
    begin
        report ">>> INICIANDO TESTBENCH DO DATAPATH <<<";

        -- Inicializa todos os controles em '0'
        s_reset <= '1';
        s_sel_op_compra <= '0';
        s_load_sel_compra_enable <= '0';
        s_load_sel_repo_enable <= '0';
        s_acumulador_add_enable <= '0';
        s_acumulador_reset <= '0';
        s_estoque_write_enable <= '0';
        s_estoque_decrementa <= '0';
        wait for CLK_PERIOD;
        s_reset <= '0';
        wait for CLK_PERIOD;

        -------------------------------------------------------------
        report "--- CENÁRIO 1: Simulação de Compra ---";
        -------------------------------------------------------------
        report "Passo 1.1: Cliente seleciona produto '01'";
        s_sel_op_compra <= '1'; -- Modo de compra
        s_product_select_buy <= "01";
        s_load_sel_compra_enable <= '1';
        wait for CLK_PERIOD;
        s_load_sel_compra_enable <= '0';
        wait for CLK_PERIOD;
        
        report "Verificando display. Preco=" & integer'image(s_price_display) & ", Qtd=" & integer'image(s_quantity_display);
        assert (s_price_display = 7 and s_quantity_display = 10) report "Falha: Display inicial incorreto" severity error;
        assert (s_QTD_ok = '1') report "Falha: QTD_ok deveria ser '1'" severity error;
        
        report "Passo 1.2: Cliente insere dinheiro";
        s_acumulador_add_enable <= '1';
        s_money_in <= 5;
        wait for CLK_PERIOD; -- Total 5
        s_money_in <= 3;
        wait for CLK_PERIOD; -- Total 8
        s_acumulador_add_enable <= '0';
        s_money_in <= 0;
        wait for CLK_PERIOD;
        
        report "Verificando se valor eh suficiente. Valor_suficiente=" & std_logic'image(s_valor_suficiente);
        assert s_valor_suficiente = '1' report "Falha: valor_suficiente deveria ser '1'" severity error;
        
        report "Passo 1.3: FSM processa a venda";
        s_estoque_decrementa <= '1';
        s_acumulador_reset <= '1';
        wait for CLK_PERIOD;
        s_estoque_decrementa <= '0';
        s_acumulador_reset <= '0';
        wait for CLK_PERIOD;
        
        report "Verificando estoque apos a venda. Qtd=" & integer'image(s_quantity_display);
        assert s_quantity_display = 9 report "Falha: Estoque nao decrementou" severity error;
        
        wait for CLK_PERIOD * 5; -- Pausa
        
        -------------------------------------------------------------
        report "--- CENÁRIO 2: Simulação de Reposição ---";
        -------------------------------------------------------------
        report "Passo 2.1: Operador seleciona produto '11'";
        s_sel_op_compra <= '0'; -- Modo de reposição
        s_product_select_replenish <= "11";
        s_load_sel_repo_enable <= '1';
        wait for CLK_PERIOD;
        s_load_sel_repo_enable <= '0';
        wait for CLK_PERIOD;
        
        report "Verificando display. Preco=" & integer'image(s_price_display) & ", Qtd=" & integer'image(s_quantity_display);
        assert (s_price_display = 8 and s_quantity_display = 10) report "Falha: Display de reposicao incorreto" severity error;
        
        report "Passo 2.2: Operador insere nova quantidade e confirma";
        s_replenish_quantity <= 50;
        s_estoque_write_enable <= '1';
        wait for CLK_PERIOD;
        s_estoque_write_enable <= '0';
        s_replenish_quantity <= 0;
        wait for CLK_PERIOD;

        report "Verificando estoque apos reposicao. Qtd=" & integer'image(s_quantity_display);
        assert s_quantity_display = 50 report "Falha: Reposicao falhou" severity error;

        report ">>> TESTBENCH DO DATAPATH CONCLUÍDO <<<";
        wait; -- Fim da simulação
    end process stimulus;

end architecture test;