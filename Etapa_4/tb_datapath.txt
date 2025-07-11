library ieee;
use ieee.std_logic_1164.all;

entity tb_caminho_dados_atualizado is
end entity tb_caminho_dados_atualizado;

architecture test of tb_caminho_dados_atualizado is

    -- Componente
    component caminho_dados_atualizado is
        port (
            clk: in std_logic; rst: in std_logic; product_code_in: in std_logic_vector(1 downto 0);
            sinal_moeda_25c: in std_logic; sinal_moeda_50c: in std_logic; sinal_moeda_1real: in std_logic;
            habilita_moedeiro: in std_logic; load_product_reg: in std_logic; credita: in std_logic;
            reset_credito: in std_logic; entrega_prod: in std_logic;
            valor_moeda_detectada: out integer range 0 to 255; saldo_suficiente: out std_logic;
            estoque_disponivel: out std_logic; display_saldo: out integer range 0 to 255;
            display_preco: out integer range 0 to 255; display_estoque: out integer range 0 to 255
        );
    end component;

    -- Sinais do Testbench
    signal s_clk              : std_logic := '0';
    signal s_rst              : std_logic;
    signal s_product_code_in  : std_logic_vector(1 downto 0) := (others => '0');
    signal s_moeda_25c        : std_logic := '0';
    signal s_moeda_50c        : std_logic := '0';
    signal s_moeda_1real      : std_logic := '0';
    signal s_habilita_moedeiro: std_logic;
    signal s_load_product_reg : std_logic;
    signal s_credita          : std_logic;
    signal s_reset_credito    : std_logic;
    signal s_entrega_prod     : std_logic;
    signal s_valor_moeda      : integer range 0 to 255;
    signal s_saldo_suficiente : std_logic;
    signal s_estoque_disp     : std_logic;
    signal s_disp_saldo       : integer range 0 to 255;
    signal s_disp_preco       : integer range 0 to 255;
    signal s_disp_estoque     : integer range 0 to 255;

    constant CLK_PERIOD : time := 10 ns;

begin
    -- Instancia
    UUT: caminho_dados_atualizado port map (
        s_clk, s_rst, s_product_code_in, s_moeda_25c, s_moeda_50c, s_moeda_1real,
        s_habilita_moedeiro, s_load_product_reg, s_credita, s_reset_credito, s_entrega_prod,
        s_valor_moeda, s_saldo_suficiente, s_estoque_disp, s_disp_saldo, s_disp_preco, s_disp_estoque
    );

    s_clk <= not s_clk after CLK_PERIOD / 2;

    stimulus: process
    begin
        report ">>> INICIANDO TESTE DO CAMINHO DE DADOS ATUALIZADO <<<";
        
        -- Reset inicial
        s_rst <= '1'; wait for CLK_PERIOD; s_rst <= '0';
        
        -- Inicializa controles
        s_habilita_moedeiro <= '0'; s_load_product_reg <= '0'; s_credita <= '0';
        s_reset_credito <= '0'; s_entrega_prod <= '0';
        wait for CLK_PERIOD;
        
        -------------------------------------------
        report "--- CENARIO: Compra do produto 0 (Preco 125) ---";
        
        report "Passo 1: Seleciona produto 0";
        s_product_code_in <= "00";
        s_load_product_reg <= '1';
        wait for CLK_PERIOD;
        s_load_product_reg <= '0';
        wait for CLK_PERIOD;
        report "Display: Preco=" & integer'image(s_disp_preco) & ", Qtd=" & integer'image(s_disp_estoque);
        assert s_disp_preco = 125 report "Falha: preco do produto 0" severity error;
        
        report "Passo 2: Insere moedas (1 real + 25 centavos)";
        s_habilita_moedeiro <= '1';
        -- Insere 1 real
        s_moeda_1real <= '1';
        wait for CLK_PERIOD;
        s_moeda_1real <= '0';
        s_credita <= '1'; -- FSM comanda o credito
        wait for CLK_PERIOD;
        s_credita <= '0';
        -- Insere 25 centavos
        s_moeda_25c <= '1';
        wait for CLK_PERIOD;
        s_moeda_25c <= '0';
        s_credita <= '1';
        wait for CLK_PERIOD;
        s_credita <= '0';
        s_habilita_moedeiro <= '0';
        wait for CLK_PERIOD;
        
        report "Saldo Acumulado: " & integer'image(s_disp_saldo);
        assert s_disp_saldo = 125 report "Falha: saldo acumulado" severity error;
        assert s_saldo_suficiente = '1' report "Falha: saldo deveria ser suficiente" severity error;
        
        report "Passo 3: FSM comanda a entrega do produto";
        s_entrega_prod <= '1';
        wait for CLK_PERIOD;
        s_entrega_prod <= '0';
        wait for CLK_PERIOD;
        
        report "Verificando estoque apos a venda: " & integer'image(s_disp_estoque);
        assert s_disp_estoque = 9 report "Falha: estoque nao decrementou" severity error;
        
        report "Passo 4: FSM comanda o reset do credito";
        s_reset_credito <= '1';
        wait for CLK_PERIOD;
        s_reset_credito <= '0';
        wait for CLK_PERIOD;
        report "Saldo final: " & integer'image(s_disp_saldo);
        assert s_disp_saldo = 0 report "Falha: credito nao foi resetado" severity error;
        
        report ">>> TESTE CONCLUIDO <<<";
        wait;
    end process;
    
end architecture test;