library ieee;
use ieee.std_logic_1164.all;

entity fsm_atualizada is
    port (
        -- === Sinais Globais ===
        clk   : in std_logic;
        rst   : in std_logic; -- Reset geral do sistema

        -- === Entradas de Botões e Status (do Datapath/Usuário) ===
        valor_moeda_in   : in  integer range 0 to 255; -- Entrada 'val' do moedeiro
        rst_cred         : in  std_logic; -- Botão para resetar o crédito
        saldo_suficiente : in  std_logic; -- Condição 'cod_ok' do comparador

        -- === Saídas de Controle (para o Datapath) ===
        zera_tudo           : out std_logic; -- Ação do estado s_idle
        habilita_moedeiro   : out std_logic; -- Ação do estado s_wait
        load_product_reg    : out std_logic; -- Ação 'le_prod' do estado s_le
        credita             : out std_logic; -- Ação do estado s_cred
        entrega_prod        : out std_logic  -- Ação do estado s_prod
    );
end entity fsm_atualizada;

architecture Behavioral of fsm_atualizada is

    -- Definição dos novos estados da FSM
    type state_type is (s_idle, s_wait, s_le, s_cred, s_prod);

    -- Sinais para o estado atual e o próximo estado
    signal current_state, next_state : state_type;

begin

    -- PROCESSO 1: Lógica Sequencial (Atualiza o estado na borda do clock)
    state_register: process(clk, rst)
    begin
        if rst = '1' then
            current_state <= s_idle; -- Estado inicial de reset
        elsif rising_edge(clk) then
            current_state <= next_state;
        end if;
    end process state_register;

    -- PROCESSO 2: Lógica Combinacional (Define o próximo estado e as saídas)
    state_logic: process(current_state, valor_moeda_in, rst_cred, saldo_suficiente)
    begin
        -- Valores padrão para todas as saídas (evita latches)
        zera_tudo           <= '0';
        habilita_moedeiro   <= '0';
        load_product_reg    <= '0';
        credita             <= '0';
        entrega_prod        <= '0';

        -- Lógica de transição e saídas para cada estado
        case current_state is
            when s_idle =>
                zera_tudo <= '1';  -- Ação: zera tudo
                next_state <= s_wait; -- Transição incondicional para s_wait

            when s_wait =>
                habilita_moedeiro <= '1'; -- Ação: habilita o moedeiro
                if valor_moeda_in > 0 then
                    next_state <= s_le; -- Transição: moeda detectada
                else
                    next_state <= s_wait; -- Permanece esperando
                end if;

            when s_le =>
                load_product_reg <= '1'; -- Ação: permite a seleção/leitura do produto
                if valor_moeda_in > 0 then
                    next_state <= s_cred; -- Transição: credita a moeda detectada
                elsif rst_cred = '1' then
                    next_state <= s_wait; -- Transição: usuário pede devolução/reset do crédito
                    zera_tudo <= '1';     -- Ação associada: zera o crédito
                elsif saldo_suficiente = '1' then
                    next_state <= s_prod; -- Transição: saldo é suficiente para o produto selecionado
                else
                    next_state <= s_wait; -- Transição padrão: volta a esperar se nada acontecer
                end if;

            when s_cred =>
                credita <= '1'; -- Ação: comanda o datapath para somar o valor da moeda
                next_state <= s_le; -- Retorna para 's_le' para continuar o processo

            when s_prod =>
                entrega_prod <= '1'; -- Ação: comanda a entrega do produto e debita o valor
                zera_tudo <= '1';    -- Ação extra: zera o saldo restante
                next_state <= s_idle; -- Retorna ao estado inicial para um novo ciclo

        end case;
    end process state_logic;

end architecture Behavioral;