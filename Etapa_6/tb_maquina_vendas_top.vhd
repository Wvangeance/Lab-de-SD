library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_textio.all;
use std.textio.all;

entity tb_maquina_vendas_top is
end entity;

architecture test of tb_maquina_vendas_top is

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

    constant CLK_PERIOD : time := 10 ns;

begin

    -- Clock
    s_clk <= not s_clk after CLK_PERIOD / 2;

    -- Instância do DUT
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

    stimulus: process
        variable L : line;
    begin
        report ">>> INICIANDO TESTE COMPLETO DA MAQUINA DE VENDAS <<<";

        -- Reset
        s_reset <= '1';
        wait for CLK_PERIOD;
        s_reset <= '0';
        wait for CLK_PERIOD;

        -- Estado inicial
        write(L, string'("Produto 0 - Preco = "));
        write(L, s_price_display);
        write(L, string'(" | Qtd = "));
        write(L, s_quantity_display);
        writeline(output, L);

        -- CENÁRIO 1
        report "--- CENARIO 1: Compra bem sucedida do produto 1 ---";
        s_product_select_buy <= "01";
        s_SELECT_C <= '1';
        wait for CLK_PERIOD;
        s_SELECT_C <= '0';
        wait for CLK_PERIOD;

        write(L, string'("Produto 1 selecionado - Preco = "));
        write(L, s_price_display);
        write(L, string'(" | Qtd = "));
        write(L, s_quantity_display);
        writeline(output, L);

        assert s_price_display = 7
        report "Falha: preco incorreto para produto 1"
        severity error;

        -- Inserir dinheiro
        s_COMPRA <= '1';
        wait for CLK_PERIOD;
        s_COMPRA <= '0';

        s_money_in <= 5;
        wait for CLK_PERIOD;
        s_money_in <= 2;
        wait for CLK_PERIOD;
        s_money_in <= 0;

        -- Confirmar pagamento
        s_PAG <= '1';
        wait for CLK_PERIOD;
        s_PAG <= '0';

        wait for 10 * CLK_PERIOD;
        report ">>> FIM DO TESTE <<<";

        wait;
    end process;

end architecture;
