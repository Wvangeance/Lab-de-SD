library ieee;
use ieee.std_logic_1164.all;

entity tb_fsm is
end entity tb_fsm;

architecture test of tb_fsm is

    -- Instanciação do componente a ser testado
    component fsm is
        port (
            clk                  : in  std_logic;
            reset                : in  std_logic;
            COMPRA               : in  std_logic;
            REP                  : in  std_logic;
            SELECT_C             : in  std_logic;
            PAG                  : in  std_logic;
            ESC                  : in  std_logic;
            ESQ                  : in  std_logic;
            QTD_ok               : in  std_logic;
            valor_suficiente     : in  std_logic;
            sel_op_compra          : out std_logic;
            load_sel_compra_enable : out std_logic;
            load_sel_repo_enable   : out std_logic;
            acumulador_add_enable  : out std_logic;
            acumulador_reset       : out std_logic;
            estoque_write_enable   : out std_logic;
            estoque_decrementa     : out std_logic;
            motor_enable         : out std_logic
        );
    end component;

    -- Sinais para conectar aos ports da FSM
    signal s_clk                  : std_logic := '0';
    signal s_reset                : std_logic;
    signal s_COMPRA               : std_logic := '0';
    signal s_REP                  : std_logic := '0';
    signal s_SELECT_C             : std_logic := '0';
    signal s_PAG                  : in std_logic := '0';
    signal s_ESC                  : std_logic := '0';
    signal s_ESQ                  : std_logic := '0';
    signal s_QTD_ok               : std_logic := '0';
    signal s_valor_suficiente     : std_logic := '0';
    signal s_sel_op_compra        : std_logic;
    signal s_load_sel_compra_enable: std_logic;
    signal s_load_sel_repo_enable : std_logic;
    signal s_acumulador_add_enable: std_logic;
    signal s_acumulador_reset     : std_logic;
    signal s_estoque_write_enable : std_logic;
    signal s_estoque_decrementa   : std_logic;
    signal s_motor_enable         : std_logic;
    
    -- Configuração do Clock
    constant CLK_PERIOD : time := 10 ns;

begin
    -- Conectando os sinais à instância do componente (Unit Under Test)
    uut: fsm port map (
        clk                    => s_clk,
        reset                  => s_reset,
        COMPRA                 => s_COMPRA,
        REP                    => s_REP,
        SELECT_C               => s_SELECT_C,
        PAG                    => s_PAG,
        ESC                    => s_ESC,
        ESQ                    => s_ESQ,
        QTD_ok                 => s_QTD_ok,
        valor_suficiente       => s_valor_suficiente,
        sel_op_compra          => s_sel_op_compra,
        load_sel_compra_enable => s_load_sel_compra_enable,
        load_sel_repo_enable   => s_load_sel_repo_enable,
        acumulador_add_enable  => s_acumulador_add_enable,
        acumulador_reset       => s_acumulador_reset,
        estoque_write_enable   => s_estoque_write_enable,
        estoque_decrementa     => s_estoque_decrementa,
        motor_enable           => s_motor_enable
    );

    -- Geração de clock contínuo
    s_clk <= not s_clk after CLK_PERIOD / 2;

    -- Processo de estímulo para testar os cenários
    stimulus: process
    begin
        report ">>> Iniciando Testbench da FSM <<<";

        -- 1. Pulso de Reset inicial
        s_reset <= '1';
        wait for CLK_PERIOD;
        s_reset <= '0';
        wait for CLK_PERIOD;
        
        -------------------------------------------------------------
        report "--- CENARIO 1: Compra bem-sucedida ---";
        -------------------------------------------------------------
        -- Pressiona COMPRA para iniciar
        s_COMPRA <= '1';
        wait for CLK_PERIOD;
        s_COMPRA <= '0';
        wait for CLK_PERIOD;
        -- Neste ponto, a FSM deve estar em SELECAO_C
        report "FSM em SELECAO_C, acumulador_add_enable = " & std_logic'image(s_acumulador_add_enable);
        assert s_acumulador_add_enable = '1' report "Falha: add_enable deveria ser '1'" severity error;

        -- Simula que o produto está disponível e o dinheiro é suficiente
        s_QTD_ok <= '1';
        s_valor_suficiente <= '1';

        -- Pressiona PAG para pagar
        s_PAG <= '1';
        wait for CLK_PERIOD;
        s_PAG <= '0';
        s_QTD_ok <= '0'; -- Reseta os status para o próximo teste
        s_valor_suficiente <= '0';
        wait for CLK_PERIOD;
        -- Neste ponto, a FSM deve estar em ENTREGA e ativar os sinais corretos
        report "FSM em ENTREGA, motor_enable = " & std_logic'image(s_motor_enable);
        assert s_motor_enable = '1' and s_estoque_decrementa = '1' and s_acumulador_reset = '1' report "Falha: Sinais de entrega incorretos" severity error;
        
        -- No próximo ciclo, a FSM volta para WAIT
        wait for CLK_PERIOD;
        report "FSM retornou para WAIT, motor_enable = " & std_logic'image(s_motor_enable);
        assert s_motor_enable = '0' report "Falha: motor_enable deveria ser '0' apos a entrega" severity error;
        wait for CLK_PERIOD * 5; -- Pausa entre os cenários

        -------------------------------------------------------------
        report "--- CENARIO 2: Compra cancelada ---";
        -------------------------------------------------------------
        -- Pressiona COMPRA para iniciar
        s_COMPRA <= '1';
        wait for CLK_PERIOD;
        s_COMPRA <= '0';
        wait for CLK_PERIOD;
        
        -- Pressiona ESC para cancelar
        s_ESC <= '1';
        wait for CLK_PERIOD;
        s_ESC <= '0';
        wait for CLK_PERIOD;
        -- Neste ponto, a FSM deve ter voltado para WAIT e resetado o acumulador
        report "FSM cancelou a compra, acumulador_reset = " & std_logic'image(s_acumulador_reset);
        assert s_acumulador_reset = '1' report "Falha: acumulador_reset deveria ser '1' ao cancelar" severity error;
        wait for CLK_PERIOD * 5; -- Pausa entre os cenários

        -------------------------------------------------------------
        report "--- CENARIO 3: Ciclo de reposicao ---";
        -------------------------------------------------------------
        -- Pressiona REP para entrar no modo de reposição
        s_REP <= '1';
        wait for CLK_PERIOD;
        s_REP <= '0';
        wait for CLK_PERIOD;
        report "FSM em SELECAO_R";
        
        -- Pressiona REP novamente para confirmar a reposição
        s_REP <= '1';
        wait for CLK_PERIOD;
        s_REP <= '0';
        wait for CLK_PERIOD;
        -- Verifica se os sinais de controle de reposição foram ativados
        report "FSM confirmou reposicao, estoque_write_enable = " & std_logic'image(s_estoque_write_enable);
        assert s_estoque_write_enable = '1' and s_load_sel_repo_enable = '1' report "Falha: Sinais de reposicao incorretos" severity error;

        -- Pressiona ESQ para sair do modo de reposição
        s_ESQ <= '1';
        wait for CLK_PERIOD;
        s_ESQ <= '0';
        wait for CLK_PERIOD;
        report "FSM saiu do modo de reposicao e voltou para WAIT";
        
        report ">>> Testbench da FSM concluido. <<<";
        wait; -- Fim da simulação
    end process stimulus;

end architecture test;