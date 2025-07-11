library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_memoria_estoque is
end entity tb_memoria_estoque;

architecture test of tb_memoria_estoque is

    -- Declaração do componente a ser testado
    component memoria_estoque is
        port (
            clk        : in  std_logic;
            rst        : in  std_logic;
            wr         : in  std_logic;
            decrementa : in  std_logic;
            endereco   : in  std_logic_vector(1 downto 0);
            dado_in    : in  integer range 0 to 255;
            dado_out   : out integer range 0 to 255
        );
    end component;

    -- Sinais para conectar ao componente
    signal s_clk        : std_logic := '0';
    signal s_rst        : std_logic;
    signal s_wr         : std_logic;
    signal s_decrementa : std_logic;
    signal s_endereco   : std_logic_vector(1 downto 0);
    signal s_dado_in    : integer range 0 to 255;
    signal s_dado_out   : integer range 0 to 255;

    -- Constante de período do clock para a simulação
    constant CLK_PERIOD : time := 10 ns;

begin

    -- Instanciação do Componente (Unit Under Test)
    uut: memoria_estoque port map (
        clk        => s_clk,
        rst        => s_rst,
        wr         => s_wr,
        decrementa => s_decrementa,
        endereco   => s_endereco,
        dado_in    => s_dado_in,
        dado_out   => s_dado_out
    );

    -- Geração do sinal de clock
    s_clk <= not s_clk after CLK_PERIOD / 2;

    -- Processo de estímulo para testar todos os cenários
    stimulus: process
    begin
        report ">>> INICIANDO TESTBENCH DA MEMORIA_ESTOQUE <<<";

        -- Inicializa todos os controles em '0'
        s_rst <= '1'; -- Ativa o reset
        s_wr <= '0';
        s_decrementa <= '0';
        s_dado_in <= 0;
        s_endereco <= "00";
        
        report "--- Cenario 1: Teste de Reset ---";
        wait for CLK_PERIOD;
        s_rst <= '0'; -- Desativa o reset
        wait for CLK_PERIOD;
        
        report "Verificando valor inicial no endereco 00. Lido: " & integer'image(s_dado_out);
        assert (s_dado_out = 10) report "Falha no Reset. Valor esperado era 10." severity error;
        
        wait for CLK_PERIOD * 2;
        
        -------------------------------------------------------------
        report "--- Cenario 2: Teste de Escrita (Reposicao) ---";
        s_endereco <= "01";
        s_dado_in <= 42; -- Repondo produto no endereco 01 com 42 unidades
        s_wr <= '1';
        wait for CLK_PERIOD;
        s_wr <= '0';
        s_dado_in <= 0;
        wait for CLK_PERIOD;
        
        report "Verificando valor apos escrita no endereco 01. Lido: " & integer'image(s_dado_out);
        assert (s_dado_out = 42) report "Falha na Escrita. Valor esperado era 42." severity error;

        wait for CLK_PERIOD * 2;
        
        -------------------------------------------------------------
        report "--- Cenario 3: Teste de Decremento (Venda) ---";
        s_endereco <= "02"; -- Estoque inicial é 10
        s_decrementa <= '1';
        wait for CLK_PERIOD;
        s_decrementa <= '0';
        wait for CLK_PERIOD;
        
        report "Verificando valor apos 1 decremento no endereco 02. Lido: " & integer'image(s_dado_out);
        assert (s_dado_out = 9) report "Falha no Decremento. Valor esperado era 9." severity error;

        -- Decrementa mais uma vez para confirmar
        s_decrementa <= '1';
        wait for CLK_PERIOD;
        s_decrementa <= '0';
        wait for CLK_PERIOD;
        assert (s_dado_out = 8) report "Falha no segundo Decremento. Valor esperado era 8." severity error;

        report ">>> TESTBENCH DA MEMORIA_ESTOQUE CONCLUIDO <<<";
        wait; -- Fim da simulação
    end process stimulus;

end architecture test;