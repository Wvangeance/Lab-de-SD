library ieee;
use ieee.std_logic_1164.all;

entity tb_maquina_vendas_top is
end entity tb_maquina_vendas_top;

architecture test of tb_maquina_vendas_top is

    -- Componente a ser testado
    component maquina_vendas_top is
        port (
            clk                      : in std_logic;
            reset                    : in std_logic;
            COMPRA                   : in std_logic;
            REP                      : in std_logic;
            SELECT_C                 : in std_logic;
            PAG                      : in std_logic;
            ESC                      : in std_logic;
            ESQ                      : in std_logic;
            product_select_buy       : in std_logic_vector(1 downto 0);
            product_select_replenish : in std_logic_vector(1 downto 0);
            money_in                 : in integer range 0 to 255;
            replenish_quantity       : in integer range 0 to 255;
            motor_enable             : out std_logic;
            price_display            : out integer range 0 to 255;
            quantity_display         : out integer range 0 to 255
        );
    end component;

    -- Sinais para o testbench
    signal s_clk                      : std_logic := '0';
    signal s_reset                    : std_logic;
    signal s_COMPRA                   : std_logic := '0';
    signal s_REP                      : std_logic := '0';
    signal s_SELECT_C                 : std_logic := '0';
    signal s_PAG                      : std_logic := '0';
    signal s_ESC                      : std_logic := '0';
    signal s_ESQ                      : std_logic := '0';
    signal s_product_select_buy       : std_logic_vector(1 downto 0) := "00";
    signal s_product_select_replenish : std_logic_vector(1 downto 0) := "00";
    signal s_money_in                 : integer range 0 to 255 := 0;
    signal s_replenish_quantity       : integer range 0 to 255 := 0;
    signal s_motor_enable             : std_logic;
    signal s_price_display            : integer range 0 to 255;
    signal s_quantity_display         : integer range 0 to 255;

    constant CLK_PERIOD : time := 10 ns; -- Para simulação

begin
    -- Instância da máquina completa
    UUT: maquina_vendas_top
        port map (
            clk                      => s_clk,
            reset                    => s_reset,
            COMPRA                   => s_COMPRA,
            REP                      => s_REP,
            SELECT_C                 => s_SELECT_C,
            PAG                      => s_PAG,
            ESC                      => s_ESC,
            ESQ                      => s_ESQ,
            product_select_buy       => s_product_select_buy,
            product_select_replenish => s_product_select_replenish,
            money_in                 => s_money_in,
            replenish_quantity       => s_replenish_quantity,
            motor_enable             => s_motor_enable,
            price_display            => s_price_display,
            quantity_display         => s_quantity_display
        );

    -- Geração de clock
    s_clk <= not s_clk after CLK_PERIOD / 2;

    -- Processo de estímulo
    stimulus : process
    begin
        report ">>> INICIANDO TESTE COMPLETO DA MÁQUINA DE VENDAS <<<";
        
        -- Reset inicial
        s_reset <= '1';
        wait for CLK_PERIOD;
        s_reset <= '0';
        wait for CLK_PERIOD;
        
        report "Verificando estado inicial. Produto 0: Preco=" & integer'image(s_price_display) & ", Qtd=" & integer'image(s_quantity_display);
        
        -------------------------------------------
        report "--- CENÁRIO 1: Compra bem-sucedida do produto 1 ---";
        s_product_select_buy <= "01";
        s_SELECT_C <= '1';
        wait for CLK_PERIOD;
        s_SELECT_C <= '0';
        wait for CLK_PERIOD;
        report "Produto 1 selecionado. Preco=" & integer'image(s_price_display) & ", Qtd=" & integer'image(s_quantity_display);
        assert s_price_display = 7 report "Falha: preco incorreto para produto 1" severity error;
        
        s_COMPRA <= '1';
        wait for CLK_PERIOD;
        s_COMPRA <= '0';
        
        report "Inserindo dinheiro...";
        s_money_in <= 5;
        wait for CLK_PERIOD;
        s_money_in <= 2;
        wait for CLK_PERIOD;
        s_money_in <= 0; -- Para de inserir dinheiro

        report "Pressionando PAG...";
        s_PAG <= '1';
        wait for CLK_PERIOD;
        s_PAG <= '0';
        wait for CLK_PERIOD;
        report "Venda processada. motor_enable=" & std_logic'image(s_motor_enable);
        assert s_motor_enable = '1' report "Falha: motor nao ativado" severity error;
        wait for CLK_PERIOD;
        report "Verificando se o estoque diminuiu...";
        assert s_quantity_display = 9 report "Falha: estoque nao decrementou" severity error;
        
        wait for CLK_PERIOD * 5;

        -------------------------------------------
        report "--- CENÁRIO 2: Reposição do produto 3 ---";
        s_product_select_replenish <= "11";
        s_replenish_quantity <= 50;
        
        s_REP <= '1'; -- Entra no modo de reposição
        wait for CLK_PERIOD;
        s_REP <= '0';
        wait for CLK_PERIOD;

        s_REP <= '1'; -- Confirma a reposição
        wait for CLK_PERIOD;
        s_REP <= '0';
        wait for CLK_PERIOD;
        
        report "Produto 3 reposto. Nova Qtd=" & integer'image(s_quantity_display);
        assert s_quantity_display = 50 report "Falha: reposicao nao funcionou" severity error;
        
        s_ESQ <= '1'; -- Sai do modo de reposição
        wait for CLK_PERIOD;
        s_ESQ <= '0';
        wait for CLK_PERIOD;

        report ">>> TESTE FINALIZADO <<<";
        wait;
    end process;

end architecture;