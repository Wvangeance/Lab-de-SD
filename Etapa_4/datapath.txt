library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity caminho_dados_atualizado is
    port (
        -- === Sinais Globais ===
        clk   : in std_logic;
        rst   : in std_logic;

        -- === Entradas do "Mundo Externo" ===
        product_code_in     : in std_logic_vector(1 downto 0);
        sinal_moeda_25c     : in std_logic;
        sinal_moeda_50c     : in std_logic;
        sinal_moeda_1real   : in std_logic;

        -- === Entradas de Controle (da FSM) ===
        habilita_moedeiro   : in std_logic;
        load_product_reg    : in std_logic; -- Corresponde a 'le_prod'
        credita             : in std_logic; -- Habilita a soma do valor da moeda
        reset_credito       : in std_logic; -- Zera o saldo acumulado
        entrega_prod        : in std_logic; -- Decrementa o estoque

        -- === Saídas de Status (para a FSM) ===
        valor_moeda_detectada : out integer range 0 to 255; -- Saida 'val'
        saldo_suficiente      : out std_logic; -- Condicao para 'cod_ok'
        estoque_disponivel    : out std_logic; -- '1' se qtd > 0

        -- === Saídas de Display (para o "Mundo Externo") ===
        display_saldo    : out integer range 0 to 255;
        display_preco    : out integer range 0 to 255;
        display_estoque  : out integer range 0 to 255
    );
end entity caminho_dados_atualizado;

architecture structural of caminho_dados_atualizado is

    -- Declaração dos componentes da Etapa 3 atualizada
    component moedeiro is
        port (habilita_moedeiro: in std_logic; sinal_moeda_25c: in std_logic; sinal_moeda_50c: in std_logic; sinal_moeda_1real: in std_logic; valor_moeda: out integer range 0 to 255);
    end component;
    component reg_2b is
        port (clk: in std_logic; rst: in std_logic; enable: in std_logic; in_D: in std_logic_vector(1 downto 0); out_Q: out std_logic_vector(1 downto 0));
    end component;
    component memoria_precos is
        port (endereco: in std_logic_vector(1 downto 0); dado_out: out integer range 0 to 255);
    end component;
    component memoria_estoque is
        port (clk: in std_logic; rst: in std_logic; wr: in std_logic; decrementa: in std_logic; endereco: in std_logic_vector(1 downto 0); dado_in: in integer range 0 to 255; dado_out: out integer range 0 to 255);
    end component;
    component somador is
        port (in_A: in integer range 0 to 255; in_B: in integer range 0 to 255; out_S: out integer range 0 to 255);
    end component;
    component comparador is
        port (in_A: in integer range 0 to 255; in_B: in integer range 0 to 255; out_S: out std_logic);
    end component;

    -- Sinais internos para conectar os componentes
    signal s_selected_product : std_logic_vector(1 downto 0);
    signal s_valor_moeda      : integer range 0 to 255;
    signal s_saldo_acumulado  : integer range 0 to 255;
    signal s_preco_atual      : integer range 0 to 255;
    signal s_estoque_atual    : integer range 0 to 255;
    signal s_proximo_saldo    : integer range 0 to 255;

begin

    -- Instancia do Moedeiro
    U1_MOEDEIRO: moedeiro port map(
        habilita_moedeiro => habilita_moedeiro,
        sinal_moeda_25c   => sinal_moeda_25c,
        sinal_moeda_50c   => sinal_moeda_50c,
        sinal_moeda_1real => sinal_moeda_1real,
        valor_moeda       => s_valor_moeda
    );

    -- Instancia do Registrador de seleção de produto
    U2_REG_PROD: reg_2b port map(
        clk    => clk,
        rst    => rst,
        enable => load_product_reg,
        in_D   => product_code_in,
        out_Q  => s_selected_product
    );

    -- Acumulador de Saldo (implementado com Somador + Registrador)
    U3_SOMADOR_SALDO: somador port map(
        in_A  => s_saldo_acumulado,
        in_B  => s_valor_moeda,
        out_S => s_proximo_saldo
    );

    ACUMULADOR_PROC: process(clk)
    begin
        if rising_edge(clk) then
            if reset_credito = '1' or rst = '1' then
                s_saldo_acumulado <= 0;
            elsif credita = '1' then
                s_saldo_acumulado <= s_proximo_saldo;
            end if;
        end if;
    end process;

    -- Instancia da Memoria de Precos
    U4_MEM_PRECOS: memoria_precos port map(
        endereco => s_selected_product,
        dado_out => s_preco_atual
    );

    -- Instancia da Memoria de Estoque
    U5_MEM_ESTOQUE: memoria_estoque port map(
        clk        => clk,
        rst        => rst,
        wr         => '0', -- Reposicao nao controlada por esta FSM
        decrementa => entrega_prod,
        endereco   => s_selected_product,
        dado_in    => 0,
        dado_out   => s_estoque_atual
    );

    -- Instancia do Comparador (Saldo vs Preco)
    U6_COMPARADOR: comparador port map(
        in_A  => s_saldo_acumulado,
        in_B  => s_preco_atual,
        out_S => saldo_suficiente
    );

    -- Atribuicao das saidas
    valor_moeda_detectada <= s_valor_moeda;
    estoque_disponivel    <= '1' when s_estoque_atual > 0 else '0';
    display_saldo         <= s_saldo_acumulado;
    display_preco         <= s_preco_atual;
    display_estoque       <= s_estoque_atual;

end architecture structural;