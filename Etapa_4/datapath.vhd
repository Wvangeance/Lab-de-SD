library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity datapath is
    port (
        -- === Sinais Globais ===
        clk   : in std_logic;
        reset : in std_logic;

        -- === Entradas de Dados do Mundo Externo ===
        product_select_buy      : in std_logic_vector(1 downto 0); -- Seleção do cliente 
        product_select_replenish: in std_logic_vector(1 downto 0); -- Seleção do operador 
        money_in                : in integer range 0 to 255;       -- Dinheiro inserido 
        replenish_quantity      : in integer range 0 to 255;       -- Quantidade para repor 

        -- === Entradas de Controle (vindos da FSM) ===
        sel_op_compra           : in std_logic; -- '1' para selecionar o produto do cliente, '0' para o do operador
        load_sel_compra_enable  : in std_logic; -- Habilita o registro da seleção de compra
        load_sel_repo_enable    : in std_logic; -- Habilita o registro da seleção de reposição
        acumulador_add_enable   : in std_logic; -- Habilita a soma de dinheiro no acumulador
        acumulador_reset        : in std_logic; -- Zera o valor acumulado
        estoque_write_enable    : in std_logic; -- Habilita a escrita no estoque (reposição)
        estoque_decrementa      : in std_logic; -- Habilita o decremento do estoque (venda)

        -- === Saídas de Status (para a FSM) ===
        QTD_ok                  : out std_logic; -- '1' se quantidade do produto selecionado > 0 
        valor_suficiente        : out std_logic; -- '1' se o dinheiro inserido é suficiente

        -- === Saídas de Display (para o Mundo Externo) ===
        price_display    : out integer range 0 to 255; -- Mostra o preço 
        quantity_display : out integer range 0 to 255  -- Mostra a quantidade 
    );
end entity datapath;

architecture structural of datapath is

    -- Declaração dos componentes da Etapa 3
    component Preco_ROM is
        port (
            endereco  : in  std_logic_vector(1 downto 0);
            preco_out : out integer range 0 to 255
        );
    end component;

    component Estoque_RAM is
        port (
            clk          : in  std_logic;
            write_enable : in  std_logic;
            decrementa   : in  std_logic;
            endereco     : in  std_logic_vector(1 downto 0);
            data_in      : in  integer range 0 to 255;
            data_out     : out integer range 0 to 255
        );
    end component;
    
    component Acumulador_Valor is
        port (
            clk        : in  std_logic;
            reset      : in  std_logic;
            add_enable : in  std_logic;
            valor_in   : in  integer range 0 to 255;
            valor_total: out integer range 0 to 255
        );
    end component;

    component Comparador_Pagamento is
        port (
            valor_acumulado : in  integer range 0 to 255;
            preco_produto   : in  integer range 0 to 255;
            valor_suficiente: out std_logic
        );
    end component;
    
    -- Componente para registrar a seleção do produto
    component Registrador_Generico is
        port(
            clk         : in std_logic;
            load_enable : in std_logic;
            data_in     : in std_logic_vector(1 downto 0);
            data_out    : out std_logic_vector(1 downto 0)
        );
    end component;

    -- Sinais internos para conectar os componentes
    signal s_sel_compra_out      : std_logic_vector(1 downto 0);
    signal s_sel_repo_out        : std_logic_vector(1 downto 0);
    signal s_endereco_memorias   : std_logic_vector(1 downto 0);
    signal s_preco_produto_atual : integer range 0 to 255;
    signal s_qtd_produto_atual   : integer range 0 to 255;
    signal s_valor_acumulado     : integer range 0 to 255;
    
begin

    -- Instância do registrador para a seleção do cliente
    REG_COMPRA: Registrador_Generico
        port map(
            clk         => clk,
            load_enable => load_sel_compra_enable,
            data_in     => product_select_buy,
            data_out    => s_sel_compra_out
        );
        
    -- Instância do registrador para a seleção do operador
    REG_REPO: Registrador_Generico
        port map(
            clk         => clk,
            load_enable => load_sel_repo_enable,
            data_in     => product_select_replenish,
            data_out    => s_sel_repo_out
        );

    -- Multiplexador para selecionar o endereço que vai para as memórias
    -- Se sel_op_compra = '1', usa o endereço do cliente. Senão, usa o do operador.
    s_endereco_memorias <= s_sel_compra_out when sel_op_compra = '1' else s_sel_repo_out;

    -- Instância da ROM de Preços
    ROM_PRECOS: Preco_ROM
        port map(
            endereco  => s_endereco_memorias,
            preco_out => s_preco_produto_atual
        );

    -- Instância da RAM de Estoque
    RAM_ESTOQUE: Estoque_RAM
        port map(
            clk          => clk,
            write_enable => estoque_write_enable,
            decrementa   => estoque_decrementa,
            endereco     => s_endereco_memorias,
            data_in      => replenish_quantity,
            data_out     => s_qtd_produto_atual
        );
        
    -- Instância do Acumulador de Dinheiro
    ACUMULADOR: Acumulador_Valor
        port map(
            clk        => clk,
            reset      => acumulador_reset,
            add_enable => acumulador_add_enable,
            valor_in   => money_in,
            valor_total=> s_valor_acumulado
        );
        
    -- Instância do Comparador de Pagamento
    COMPARADOR: Comparador_Pagamento
        port map(
            valor_acumulado  => s_valor_acumulado,
            preco_produto    => s_preco_produto_atual,
            valor_suficiente => valor_suficiente -- Conectado diretamente à saída
        );

    -- Lógica para as saídas de status e display
    QTD_ok           <= '1' when s_qtd_produto_atual > 0 else '0';
    price_display    <= s_preco_produto_atual;
    quantity_display <= s_qtd_produto_atual;


end architecture structural;


-- OBS: Adicione este código para o Registrador_Generico em src/datapath/ ou
-- compile-o na mesma biblioteca 'work' para que o datapath o encontre.
-- Salve como 'registrador_generico.vhd'
library ieee;
use ieee.std_logic_1164.all;

entity Registrador_Generico is
    port(
        clk         : in std_logic;
        load_enable : in std_logic;
        data_in     : in std_logic_vector(1 downto 0);
        data_out    : out std_logic_vector(1 downto 0)
    );
end entity Registrador_Generico;

architecture Behavioral of Registrador_Generico is
    signal reg_interno: std_logic_vector(1 downto 0) := "00";
begin
    process(clk)
    begin
        if rising_edge(clk) then
            if load_enable = '1' then
                reg_interno <= data_in;
            end if;
        end if;
    end process;
    data_out <= reg_interno;
end architecture Behavioral;