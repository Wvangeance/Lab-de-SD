library ieee;
use ieee.std_logic_1164.all;

entity fsm is
    port (
        -- === Sinais Globais ===
        clk   : in std_logic;
        reset : in std_logic;

        -- === Entradas de Botões (do usuário) ===
        COMPRA   : in std_logic;
        REP      : in std_logic;
        SELECT_C : in std_logic;
        PAG      : in std_logic;
        ESC      : in std_logic;
        ESQ      : in std_logic;

        -- === Entradas de Status (vindos do Datapath) ===
        QTD_ok           : in std_logic;
        valor_suficiente : in std_logic;

        -- === Saídas de Controle (para o Datapath) ===
        sel_op_compra           : out std_logic;
        load_sel_compra_enable  : out std_logic;
        load_sel_repo_enable    : out std_logic;
        acumulador_add_enable   : out std_logic;
        acumulador_reset        : out std_logic;
        estoque_write_enable    : out std_logic;
        estoque_decrementa      : out std_logic;
        
        -- === Saída para Atuador Externo ===
        motor_enable : out std_logic -- Ativa o motor de entrega 
    );
end entity fsm;

architecture Behavioral of fsm is

    -- Definição dos estados da FSM, conforme o diagrama 
    type state_type is (WAIT, SELECAO_C, SELECAO_R, ENTREGA);

    -- Sinais para o estado atual e o próximo estado
    signal current_state, next_state : state_type;

begin

    -- Processo Sequencial: Atualiza o estado atual na borda de subida do clock
    -- e lida com o reset síncrono.
    process(clk, reset)
    begin
        if reset = '1' then
            current_state <= WAIT; -- No reset, vai para o estado inicial WAIT 
        elsif rising_edge(clk) then
            current_state <= next_state;
        end if;
    end process;

    -- Processo Combinacional: Determina o próximo estado e as saídas de controle
    -- com base no estado atual e nas entradas.
    process(current_state, COMPRA, REP, SELECT_C, PAG, ESC, ESQ, QTD_ok, valor_suficiente)
    begin
        -- --- Comportamento Padrão ---
        -- Para evitar a inferência de latches, definimos um valor padrão para todas as saídas.
        -- Por padrão, todos os sinais de controle estão inativos.
        next_state               <= current_state; -- Permanece no mesmo estado a menos que uma transição ocorra
        sel_op_compra            <= '0';
        load_sel_compra_enable   <= '0';
        load_sel_repo_enable     <= '0';
        acumulador_add_enable    <= '0';
        acumulador_reset         <= '0';
        estoque_write_enable     <= '0';
        estoque_decrementa       <= '0';
        motor_enable             <= '0';

        -- --- Lógica da Máquina de Estados ---
        case current_state is

            -- ESTADO DE ESPERA
            when WAIT =>
                sel_op_compra <= '1'; -- Permite visualizar preço do produto do cliente
                if COMPRA = '1' then
                    next_state <= SELECAO_C; -- Transição para o estado de compra 
                elsif REP = '1' then
                    next_state <= SELECAO_R; -- Transição para o estado de reposição 
                end if;

            -- ESTADO DE SELEÇÃO DE COMPRA
            when SELECAO_C =>
                sel_op_compra <= '1';
                acumulador_add_enable <= '1'; -- Permite que o cliente insira dinheiro 

                if PAG = '1' and QTD_ok = '1' and valor_suficiente = '1' then
                    next_state <= ENTREGA; -- Condição para realizar o pagamento e entregar 
                elsif SELECT_C = '1' then
                    next_state <= SELECAO_C; -- Permite nova seleção 
                    load_sel_compra_enable <= '1'; -- Carrega o novo produto selecionado
                elsif ESC = '1' then
                    next_state <= WAIT; -- Cancela a compra 
                    acumulador_reset <= '1'; -- Zera o dinheiro inserido
                end if;

            -- ESTADO DE SELEÇÃO DE REPOSIÇÃO
            when SELECAO_R =>
                sel_op_compra <= '0'; -- Permite visualizar o produto que o operador está selecionando
                if REP = '1' then
                    next_state <= SELECAO_R; -- Confirma a reposição 
                    load_sel_repo_enable <= '1'; -- Carrega o produto a ser reposto
                    estoque_write_enable <= '1'; -- Habilita a escrita da nova quantidade no datapath
                elsif ESQ = '1' then
                    next_state <= WAIT; -- Sai do modo de reposição 
                end if;
                
            -- ESTADO DE ENTREGA DO PRODUTO
            when ENTREGA =>
                motor_enable <= '1'; -- Ativa o motor por um ciclo de clock 
                estoque_decrementa <= '1'; -- Decrementa o estoque do produto vendido
                acumulador_reset <= '1'; -- Zera o valor para a próxima compra
                next_state <= WAIT; -- Retorna ao estado inicial 

        end case;
    end process;

end architecture Behavioral;