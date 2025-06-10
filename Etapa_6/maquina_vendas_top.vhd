library ieee;
use ieee.std_logic_1164.all;

-- Entidade principal da máquina de vendas.
-- As portas aqui são as entradas e saídas físicas da máquina.
entity maquina_vendas_top is
    port (
        -- === Entradas Globais ===
        clk   : in std_logic; -- Clock de 1 Hz 
        reset : in std_logic; -- Reset síncrono 

        -- === Entradas de Botões e Dados ===
        COMPRA                   : in std_logic; -- Inicia processo de compra 
        REP                      : in std_logic; -- Inicia ou confirma reposição 
        SELECT_C                 : in std_logic; -- Confirma seleção de compra 
        PAG                      : in std_logic; -- Confirma pagamento 
        ESC                      : in std_logic; -- Cancela compra 
        ESQ                      : in std_logic; -- Sai do processo atual 
        product_select_buy       : in std_logic_vector(1 downto 0); -- Seleção de produto (cliente)
        product_select_replenish : in std_logic_vector(1 downto 0); -- Seleção de produto (operador)
        money_in                 : in integer range 0 to 255;       -- Valor em dinheiro inserido 
        replenish_quantity       : in integer range 0 to 255;       -- Quantidade a ser adicionada 

        -- === Saídas para Displays e Atuadores ===
        motor_enable     : out std_logic; -- Ativa o motor de entrega 
        price_display    : out integer range 0 to 255; -- Mostra o preço do produto 
        quantity_display : out integer range 0 to 255  -- Mostra quantidade do produto 
    );
end entity maquina_vendas_top;

architecture structural of maquina_vendas_top is

    -- Declaração do componente FSM
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

    -- Declaração do componente Datapath
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

    -- Sinais de FIO para conectar a FSM e o Datapath
    -- Status (Datapath -> FSM)
    signal s_QTD_ok           : std_logic;
    signal s_valor_suficiente : std_logic;
    -- Controle (FSM -> Datapath)
    signal s_sel_op_compra        : std_logic;
    signal s_load_sel_compra_enable: std_logic;
    signal s_load_sel_repo_enable : std_logic;
    signal s_acumulador_add_enable: std_logic;
    signal s_acumulador_reset     : std_logic;
    signal s_estoque_write_enable : std_logic;
    signal s_estoque_decrementa   : std_logic;

begin

    -- Instância da Unidade de Controle (FSM)
    CONTROL_UNIT: fsm
        port map (
            clk                    => clk,
            reset                  => reset,
            COMPRA                 => COMPRA,
            REP                    => REP,
            SELECT_C               => SELECT_C,
            PAG                    => PAG,
            ESC                    => ESC,
            ESQ                    => ESQ,
            QTD_ok                 => s_QTD_ok,
            valor_suficiente       => s_valor_suficiente,
            sel_op_compra          => s_sel_op_compra,
            load_sel_compra_enable => s_load_sel_compra_enable,
            load_sel_repo_enable   => s_load_sel_repo_enable,
            acumulador_add_enable  => s_acumulador_add_enable,
            acumulador_reset       => s_acumulador_reset,
            estoque_write_enable   => s_estoque_write_enable,
            estoque_decrementa     => s_estoque_decrementa,
            motor_enable           => motor_enable -- Conectado diretamente à saída
        );

    -- Instância da Unidade de Operação (Datapath)
    OPERATION_UNIT: datapath
        port map (
            clk                      => clk,
            reset                    => reset,
            product_select_buy       => product_select_buy,
            product_select_replenish => product_select_replenish,
            money_in                 => money_in,
            replenish_quantity       => replenish_quantity,
            sel_op_compra            => s_sel_op_compra,
            load_sel_compra_enable   => s_load_sel_compra_enable,
            load_sel_repo_enable     => s_load_sel_repo_enable,
            acumulador_add_enable    => s_acumulador_add_enable,
            acumulador_reset         => s_acumulador_reset,
            estoque_write_enable     => s_estoque_write_enable,
            estoque_decrementa       => s_estoque_decrementa,
            QTD_ok                   => s_QTD_ok,
            valor_suficiente         => s_valor_suficiente,
            price_display            => price_display, -- Conectado diretamente à saída
            quantity_display         => quantity_display -- Conectado diretamente à saída
        );

end architecture structural;