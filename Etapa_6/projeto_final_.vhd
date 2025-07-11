-- Bibliotecas globais necessarias para os tipos basicos
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--------------------------------------------------------------------------------
-- Componente 1: Divisor de Clock
-- Descricao: Converte o clock de 50 MHz da placa FPGA para um clock de 1 Hz,
--            tornando a maquina de estados lenta o suficiente para interacao humana.
--------------------------------------------------------------------------------
entity divisor_de_clock is
    port (
        clk_in  : in  std_logic;
        rst     : in  std_logic;
        clk_out : out std_logic
    );
end entity divisor_de_clock;

architecture Behavioral of divisor_de_clock is
    -- Contador para chegar a 25 milhoes (meio periodo de 1 Hz em 50 MHz)
    signal contador : integer range 0 to 25000000 := 0;
    signal s_clk_1hz: std_logic := '0';
begin
    process(clk_in, rst)
    begin
        if rst = '1' then
            contador <= 0;
            s_clk_1hz <= '0';
        elsif rising_edge(clk_in) then
            if contador = 24999999 then
                contador <= 0;
                s_clk_1hz <= not s_clk_1hz; -- Inverte o clock de saida
            else
                contador <= contador + 1;
            end if;
        end if;
    end process;
    clk_out <= s_clk_1hz;
end architecture Behavioral;

--------------------------------------------------------------------------------
-- Componente 2: Decodificador para Display de 7 Segmentos
-- Descricao: Converte um digito BCD de 4 bits (0-9) no padrao de 7 bits
--            para acender os segmentos corretos de um display.
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

entity decodificador_7seg is
    port (
        bcd_in  : in  std_logic_vector(3 downto 0);
        seg_out : out std_logic_vector(6 downto 0) -- Formato (g,f,e,d,c,b,a)
    );
end entity decodificador_7seg;

architecture Behavioral of decodificador_7seg is
begin
    -- Logica combinacional que mapeia cada valor BCD para os segmentos
    with bcd_in select
        seg_out <=
            "1000000" when "0000", -- 0
            "1111001" when "0001", -- 1
            "0100100" when "0010", -- 2
            "0110000" when "0011", -- 3
            "0011001" when "0100", -- 4
            "0010010" when "0101", -- 5
            "0000010" when "0110", -- 6
            "1111000" when "0111", -- 7
            "0000000" when "1000", -- 8
            "0010000" when "1001", -- 9
            "1111111" when others; -- Desligado
end architecture;

--------------------------------------------------------------------------------
-- Componente 3: Conversor Binario para BCD
-- Descricao: Usa o algoritmo "Double Dabble" para converter um numero
--            inteiro de 8 bits (0-255) em 3 digitos BCD (centena, dezena, unidade).
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity bin_para_bcd is
    port (
        bin_in       : in  integer range 0 to 255;
        bcd_centenas : out std_logic_vector(3 downto 0);
        bcd_dezenas  : out std_logic_vector(3 downto 0);
        bcd_unidades : out std_logic_vector(3 downto 0)
    );
end entity bin_para_bcd;

architecture Behavioral of bin_para_bcd is
begin
    process(bin_in)
        variable bin_vec : unsigned(7 downto 0);
        variable bcd_val : unsigned(11 downto 0);
    begin
        bin_vec := to_unsigned(bin_in, 8);
        bcd_val := (others => '0');
        for i in 0 to 7 loop
            -- Adiciona 3 a qualquer digito BCD que for 5 ou maior
            if i > 0 and bcd_val(3 downto 0) >= 5 then
                bcd_val(3 downto 0) := bcd_val(3 downto 0) + 3;
            end if;
            if i > 0 and bcd_val(7 downto 4) >= 5 then
                bcd_val(7 downto 4) := bcd_val(7 downto 4) + 3;
            end if;
            if i > 0 and bcd_val(11 downto 8) >= 5 then
                bcd_val(11 downto 8) := bcd_val(11 downto 8) + 3;
            end if;
            -- Desloca o valor BCD para a esquerda e insere o proximo bit do binario
            bcd_val := bcd_val(10 downto 0) & bin_vec(7-i);
        end loop;
        bcd_centenas <= std_logic_vector(bcd_val(11 downto 8));
        bcd_dezenas  <= std_logic_vector(bcd_val(7 downto 4));
        bcd_unidades <= std_logic_vector(bcd_val(3 downto 0));
    end process;
end architecture;

--------------------------------------------------------------------------------
-- Componentes Base do Datapath
--------------------------------------------------------------------------------
library ieee; use ieee.std_logic_1164.all; use ieee.numeric_std.all;
entity moedeiro is port (habilita_moedeiro: in std_logic; sinal_moeda_25c: in std_logic; sinal_moeda_50c: in std_logic; sinal_moeda_1real: in std_logic; valor_moeda: out integer range 0 to 255); end entity;
architecture a of moedeiro is begin process(all) begin valor_moeda <= 0; if habilita_moedeiro = '1' then if sinal_moeda_1real = '1' then valor_moeda <= 100; elsif sinal_moeda_50c = '1' then valor_moeda <= 50; elsif sinal_moeda_25c = '1' then valor_moeda <= 25; end if; end if; end process; end architecture;

library ieee; use ieee.std_logic_1164.all;
entity reg_2b is port (clk: in std_logic; rst: in std_logic; enable: in std_logic; in_D: in std_logic_vector(1 downto 0); out_Q: out std_logic_vector(1 downto 0)); end entity;
architecture a of reg_2b is begin process(clk) begin if rising_edge(clk) then if rst = '1' then out_Q <= "00"; elsif enable = '1' then out_Q <= in_D; end if; end if; end process; end architecture;

library ieee; use ieee.std_logic_1164.all; use ieee.numeric_std.all;
entity memoria_precos is port (endereco: in std_logic_vector(1 downto 0); dado_out: out integer range 0 to 255); end entity;
architecture a of memoria_precos is type array_precos is array (0 to 3) of integer; constant PRECOS : array_precos := (125, 150, 175, 200); begin dado_out <= PRECOS(to_integer(unsigned(endereco))); end architecture;

library ieee; use ieee.std_logic_1164.all; use ieee.numeric_std.all;
entity memoria_estoque is port (clk: in std_logic; rst: in std_logic; wr: in std_logic; decrementa: in std_logic; endereco: in std_logic_vector(1 downto 0); dado_in: in integer range 0 to 255; dado_out: out integer range 0 to 255); end entity;
architecture a of memoria_estoque is type array_estoque is array (0 to 3) of integer; signal estoque_interno : array_estoque := (10, 10, 10, 10); begin process(clk) begin if rising_edge(clk) then if rst = '1' then estoque_interno <= (10, 10, 10, 10); elsif wr = '1' then estoque_interno(to_integer(unsigned(endereco))) <= dado_in; elsif decrementa = '1' and estoque_interno(to_integer(unsigned(endereco))) > 0 then estoque_interno(to_integer(unsigned(endereco))) <= estoque_interno(to_integer(unsigned(endereco))) - 1; end if; end if; end process; dado_out <= estoque_interno(to_integer(unsigned(endereco))); end architecture;

entity somador is port (in_A: in integer range 0 to 255; in_B: in integer range 0 to 255; out_S: out integer range 0 to 255); end entity;
architecture a of somador is begin out_S <= in_A + in_B; end architecture;

library ieee; use ieee.std_logic_1164.all;
entity comparador is port (in_A: in integer range 0 to 255; in_B: in integer range 0 to 255; out_S: out std_logic); end entity;
architecture a of comparador is begin out_S <= '1' when in_A >= in_B else '0'; end architecture;

--------------------------------------------------------------------------------
-- Componente 4: Datapath Completo (a "calculadora" da maquina)
--------------------------------------------------------------------------------
library ieee; use ieee.std_logic_1164.all; use ieee.numeric_std.all;
entity caminho_dados_atualizado is
    port (clk: in std_logic; rst: in std_logic; product_code_in: in std_logic_vector(1 downto 0); sinal_moeda_25c: in std_logic; sinal_moeda_50c: in std_logic; sinal_moeda_1real: in std_logic; habilita_moedeiro: in std_logic; load_product_reg: in std_logic; credita: in std_logic; reset_credito: in std_logic; entrega_prod: in std_logic; valor_moeda_detectada: out integer range 0 to 255; saldo_suficiente: out std_logic; estoque_disponivel: out std_logic; display_saldo: out integer range 0 to 255; display_preco: out integer range 0 to 255; display_estoque: out integer range 0 to 255);
end entity caminho_dados_atualizado;

architecture structural of caminho_dados_atualizado is
    -- Sinais internos que conectam os componentes do datapath
    signal s_selected_product : std_logic_vector(1 downto 0); signal s_valor_moeda : integer range 0 to 255; signal s_saldo_acumulado : integer range 0 to 255; signal s_preco_atual : integer range 0 to 255; signal s_estoque_atual : integer range 0 to 255; signal s_proximo_saldo : integer range 0 to 255;
begin
    U1_MOEDEIRO: entity work.moedeiro port map(habilita_moedeiro, sinal_moeda_25c, sinal_moeda_50c, sinal_moeda_1real, s_valor_moeda);
    U2_REG_PROD: entity work.reg_2b port map(clk, rst, load_product_reg, product_code_in, s_selected_product);
    U3_SOMADOR_SALDO: entity work.somador port map(s_saldo_acumulado, s_valor_moeda, s_proximo_saldo);
    ACUMULADOR_PROC: process(clk) begin if rising_edge(clk) then if reset_credito = '1' or rst = '1' then s_saldo_acumulado <= 0; elsif credita = '1' then s_saldo_acumulado <= s_proximo_saldo; end if; end if; end process;
    U4_MEM_PRECOS: entity work.memoria_precos port map(s_selected_product, s_preco_atual);
    U5_MEM_ESTOQUE: entity work.memoria_estoque port map(clk, rst, '0', entrega_prod, s_selected_product, 0, s_estoque_atual);
    U6_COMPARADOR: entity work.comparador port map(s_saldo_acumulado, s_preco_atual, saldo_suficiente);
    -- Conecta os sinais internos as portas de saida do datapath
    valor_moeda_detectada <= s_valor_moeda; estoque_disponivel <= '1' when s_estoque_atual > 0 else '0'; display_saldo <= s_saldo_acumulado; display_preco <= s_preco_atual; display_estoque <= s_estoque_atual;
end architecture structural;

--------------------------------------------------------------------------------
-- Componente 5: FSM (o "cerebro" da maquina)
--------------------------------------------------------------------------------
library ieee; use ieee.std_logic_1164.all;
entity fsm_atualizada is
    port (clk: in std_logic; rst: in std_logic; valor_moeda_in: in integer range 0 to 255; rst_cred: in std_logic; saldo_suficiente: in std_logic; zera_tudo: out std_logic; habilita_moedeiro: out std_logic; load_product_reg: out std_logic; credita: out std_logic; entrega_prod: out std_logic);
end entity fsm_atualizada;

architecture Behavioral of fsm_atualizada is
    type state_type is (s_idle, s_wait, s_le, s_cred, s_prod);
    signal current_state, next_state : state_type;
begin
    state_register: process(clk, rst) begin if rst = '1' then current_state <= s_idle; elsif rising_edge(clk) then current_state <= next_state; end if; end process;
    state_logic: process(current_state, valor_moeda_in, rst_cred, saldo_suficiente)
    begin
        zera_tudo <= '0'; habilita_moedeiro <= '0'; load_product_reg <= '0'; credita <= '0'; entrega_prod <= '0';
        case current_state is
            when s_idle => zera_tudo <= '1'; next_state <= s_wait;
            when s_wait => habilita_moedeiro <= '1'; if valor_moeda_in > 0 then next_state <= s_le; else next_state <= s_wait; end if;
            when s_le => load_product_reg <= '1'; if valor_moeda_in > 0 then next_state <= s_cred; elsif rst_cred = '1' then next_state <= s_wait; zera_tudo <= '1'; elsif saldo_suficiente = '1' then next_state <= s_prod; else next_state <= s_wait; end if;
            when s_cred => credita <= '1'; next_state <= s_le;
            when s_prod => entrega_prod <= '1'; zera_tudo <= '1'; next_state <= s_idle;
        end case;
    end process state_logic;
end architecture Behavioral;

--------------------------------------------------------------------------------
-- ENTIDADE DE TOPO: Conecta tudo para a FPGA
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
entity maquina_vendas_fpga is
    port (
        -- Entradas Fisicas da Placa DE2
        CLOCK_50      : in  std_logic;
        KEY           : in  std_logic_vector(3 downto 0);
        SW            : in  std_logic_vector(17 downto 0);
        -- Saidas Fisicas da Placa DE2
        LEDR          : out std_logic_vector(17 downto 0);
        HEX0, HEX1, HEX2, HEX3, HEX4, HEX5 : out std_logic_vector(6 downto 0)
    );
end entity maquina_vendas_fpga;

architecture structural of maquina_vendas_fpga is
    -- Sinais internos para conectar todos os modulos
    signal s_rst            : std_logic;
    signal s_clk_1hz        : std_logic;
    signal s_product_code   : std_logic_vector(1 downto 0);
    signal s_rst_cred       : std_logic;
    signal s_moeda_25c      : std_logic;
    signal s_moeda_50c      : std_logic;
    signal s_moeda_1real    : std_logic;
    signal s_saldo_int      : integer range 0 to 255;
    signal s_preco_int      : integer range 0 to 255;
    signal s_estoque_int    : integer range 0 to 255;
    -- Sinais de controle entre FSM e Datapath
    signal s_zera           : std_logic;
    signal s_hab_moed       : std_logic;
    signal s_load_prod      : std_logic;
    signal s_credita        : std_logic;
    signal s_entrega        : std_logic;
    -- Sinais de status entre Datapath e FSM
    signal s_valor_moeda_int: integer range 0 to 255;
    signal s_saldo_suf      : std_logic;
    signal s_estoque_disp   : std_logic;
    
    -- Sinais BCD para os displays
    signal bcd_preco_c, bcd_preco_d, bcd_preco_u: std_logic_vector(3 downto 0);
    signal bcd_saldo_c, bcd_saldo_d, bcd_saldo_u: std_logic_vector(3 downto 0);
    signal bcd_estoque_c, bcd_estoque_d, bcd_estoque_u: std_logic_vector(3 downto 0);
begin
    -- === MAPEAMENTO DAS ENTRADAS FISICAS ===
    -- Botoes KEY sao ativos em baixo, entao invertemos a logica com 'not'
    s_rst         <= not KEY(0); -- Reset geral
    s_rst_cred    <= not KEY(1); -- Reset do credito
    s_moeda_25c   <= not KEY(2); -- Simula insercao de 25 centavos
    s_moeda_50c   <= not KEY(3); -- Simula insercao de 50 centavos
    s_moeda_1real <= SW(17);    -- Usa um switch para a moeda de 1 real
    s_product_code<= SW(1 downto 0); -- Usa 2 switches para selecionar o produto

    -- === INSTANCIACAO DOS MODULOS PRINCIPAIS ===
    -- 1. Gera o clock de 1Hz para o sistema principal
    CLOCK_DIV: entity work.divisor_de_clock port map (CLOCK_50, s_rst, s_clk_1hz);

    -- 2. Instancia a FSM (Unidade de Controle)
    CONTROL_UNIT: entity work.fsm_atualizada port map (
        clk              => s_clk_1hz, rst => s_rst, valor_moeda_in => s_valor_moeda_int,
        rst_cred         => s_rst_cred, saldo_suficiente => s_saldo_suf,
        zera_tudo        => s_zera, habilita_moedeiro => s_hab_moed,
        load_product_reg => s_load_prod, credita => s_credita, entrega_prod => s_entrega
    );
        
    -- 3. Instancia o Datapath (Unidade de Operacao)
    OPERATION_UNIT: entity work.caminho_dados_atualizado port map (
        clk => s_clk_1hz, rst => s_rst, product_code_in => s_product_code, 
        sinal_moeda_25c => s_moeda_25c, sinal_moeda_50c => s_moeda_50c, sinal_moeda_1real => s_moeda_1real,
        habilita_moedeiro => s_hab_moed, load_product_reg => s_load_prod, credita => s_credita,
        reset_credito => s_zera, entrega_prod => s_entrega,
        valor_moeda_detectada => s_valor_moeda_int, saldo_suficiente => s_saldo_suf,
        estoque_disponivel => s_estoque_disp, display_saldo => s_saldo_int,
        display_preco => s_preco_int, display_estoque => s_estoque_int
    );
    
    -- === LOGICA E MAPEAMENTO DAS SAIDAS ===
    -- 4. Converte os numeros inteiros do datapath para BCD e depois para 7 segmentos
    CONV_PRECO: entity work.bin_para_bcd port map (s_preco_int, bcd_preco_c, bcd_preco_d, bcd_preco_u);
    DECODE_PRECO_D: entity work.decodificador_7seg port map(bcd_preco_d, HEX1); -- Dezena do Preco
    DECODE_PRECO_U: entity work.decodificador_7seg port map(bcd_preco_u, HEX0); -- Unidade do Preco
    
    CONV_SALDO: entity work.bin_para_bcd port map (s_saldo_int, bcd_saldo_c, bcd_saldo_d, bcd_saldo_u);
    DECODE_SALDO_D: entity work.decodificador_7seg port map(bcd_saldo_d, HEX3); -- Dezena do Saldo
    DECODE_SALDO_U: entity work.decodificador_7seg port map(bcd_saldo_u, HEX2); -- Unidade do Saldo

    CONV_ESTOQUE: entity work.bin_para_bcd port map (s_estoque_int, bcd_estoque_c, bcd_estoque_d, bcd_estoque_u);
    DECODE_ESTOQUE_D: entity work.decodificador_7seg port map(bcd_estoque_d, HEX5); -- Dezena do Estoque
    DECODE_ESTOQUE_U: entity work.decodificador_7seg port map(bcd_estoque_u, HEX4); -- Unidade do Estoque

    -- Mapeia o sinal de entrega para o LED e desliga os outros
    LEDR(0) <= s_entrega;
    LEDR(17 downto 1) <= (others => '0');
end architecture;