library ieee;
use ieee.std_logic_1164.all;

entity tb_fsm_atualizada is
end entity tb_fsm_atualizada;

architecture test of tb_fsm_atualizada is

    -- Componente a ser testado
    component fsm_atualizada is
        port (
            clk              : in  std_logic;
            rst              : in  std_logic;
            valor_moeda_in   : in  integer range 0 to 255;
            rst_cred         : in  std_logic;
            saldo_suficiente : in  std_logic;
            zera_tudo        : out std_logic;
            habilita_moedeiro: out std_logic;
            load_product_reg : out std_logic;
            credita          : out std_logic;
            entrega_prod     : out std_logic
        );
    end component;

    -- Sinais para conectar ao componente
    signal s_clk              : std_logic := '0';
    signal s_rst              : std_logic;
    signal s_valor_moeda_in   : integer range 0 to 255;
    signal s_rst_cred         : std_logic;
    signal s_saldo_suficiente : std_logic;
    signal s_zera_tudo        : std_logic;
    signal s_habilita_moedeiro: std_logic;
    signal s_load_product_reg : std_logic;
    signal s_credita          : std_logic;
    signal s_entrega_prod     : std_logic;

    constant CLK_PERIOD : time := 10 ns;

begin
    -- Instanciação da FSM (Unit Under Test)
    UUT: fsm_atualizada port map (
        clk              => s_clk,
        rst              => s_rst,
        valor_moeda_in   => s_valor_moeda_in,
        rst_cred         => s_rst_cred,
        saldo_suficiente => s_saldo_suficiente,
        zera_tudo        => s_zera_tudo,
        habilita_moedeiro=> s_habilita_moedeiro,
        load_product_reg => s_load_product_reg,
        credita          => s_credita,
        entrega_prod     => s_entrega_prod
    );

    -- Geração de clock
    s_clk <= not s_clk after CLK_PERIOD / 2;

    -- Processo de estímulo
    stimulus: process
    begin
        report ">>> INICIANDO TESTBENCH DA FSM ATUALIZADA <<<";
        
        -- Inicializa entradas
        s_valor_moeda_in <= 0;
        s_rst_cred <= '0';
        s_saldo_suficiente <= '0';
        
        -- Pulso de Reset
        s_rst <= '1';
        wait for CLK_PERIOD;
        s_rst <= '0';
        wait for CLK_PERIOD;
        report "FSM em s_idle, zera_tudo=" & std_logic'image(s_zera_tudo);
        assert s_zera_tudo = '1' report "Falha: FSM nao comecou em s_idle" severity error;
        
        wait for CLK_PERIOD;
        report "FSM em s_wait, habilita_moedeiro=" & std_logic'image(s_habilita_moedeiro);
        assert s_habilita_moedeiro = '1' report "Falha: FSM nao foi para s_wait" severity error;

        -------------------------------------------
        report "--- CENARIO 1: Insercao de Moeda ---";
        s_valor_moeda_in <= 50; -- Simula moeda detectada
        wait for CLK_PERIOD;
        report "FSM em s_le, load_product_reg=" & std_logic'image(s_load_product_reg);
        assert s_load_product_reg = '1' report "Falha: FSM nao foi para s_le" severity error;
        
        wait for CLK_PERIOD;
        report "FSM em s_cred, credita=" & std_logic'image(s_credita);
        assert s_credita = '1' report "Falha: FSM nao foi para s_cred" severity error;
        
        wait for CLK_PERIOD;
        s_valor_moeda_in <= 0; -- Para o ciclo de credito
        report "FSM de volta a s_le...";
        wait for CLK_PERIOD;
        report "FSM de volta a s_wait...";
        assert s_habilita_moedeiro = '1' report "Falha: FSM nao retornou para s_wait" severity error;
        
        wait for CLK_PERIOD * 3;
        
        -------------------------------------------
        report "--- CENARIO 2: Compra Bem-sucedida ---";
        s_valor_moeda_in <= 100; -- Insere credito
        wait for CLK_PERIOD * 3; -- Passa por s_le -> s_cred -> s_le
        s_valor_moeda_in <= 0;
        
        report "Saldo inserido. FSM em s_le. Simulando saldo suficiente...";
        s_saldo_suficiente <= '1';
        wait for CLK_PERIOD;
        
        report "FSM em s_prod, entrega_prod=" & std_logic'image(s_entrega_prod);
        assert s_entrega_prod = '1' report "Falha: FSM nao foi para s_prod" severity error;
        s_saldo_suficiente <= '0';
        
        wait for CLK_PERIOD;
        report "FSM de volta a s_idle...";
        assert s_zera_tudo = '1' report "Falha: FSM nao retornou a s_idle" severity error;
        
        wait for CLK_PERIOD * 3;
        
        -------------------------------------------
        report "--- CENARIO 3: Reset de Credito ---";
        s_valor_moeda_in <= 25; -- Insere credito
        wait for CLK_PERIOD * 3;
        s_valor_moeda_in <= 0;
        
        report "FSM em s_le. Pressionando botao de reset de credito...";
        s_rst_cred <= '1';
        wait for CLK_PERIOD;
        s_rst_cred <= '0';
        
        report "Verificando se credito foi zerado e FSM voltou a s_wait...";
        assert s_zera_tudo = '1' report "Falha: zera_tudo nao foi ativado no rst_cred" severity error;
        wait for CLK_PERIOD;
        assert s_habilita_moedeiro = '1' report "Falha: FSM nao retornou a s_wait apos rst_cred" severity error;
        
        report ">>> TESTBENCH DA FSM CONCLUIDO <<<";
        wait;
    end process;
    
end architecture test;