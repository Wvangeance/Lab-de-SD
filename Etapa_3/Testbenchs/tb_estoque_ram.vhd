library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_estoque_ram is
end entity tb_estoque_ram;

architecture test of tb_estoque_ram is
    -- Componente
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

    -- Sinais
    signal s_clk          : std_logic := '0';
    signal s_write_enable : std_logic;
    signal s_decrementa   : std_logic;
    signal s_endereco     : std_logic_vector(1 downto 0);
    signal s_data_in      : integer range 0 to 255;
    signal s_data_out     : integer range 0 to 255;

    -- Clock
    constant CLK_PERIOD : time := 10 ns;
begin
    -- Instância
    uut: Estoque_RAM port map (
        clk          => s_clk,
        write_enable => s_write_enable,
        decrementa   => s_decrementa,
        endereco     => s_endereco,
        data_in      => s_data_in,
        data_out     => s_data_out
    );

    -- Geração de clock
    s_clk <= not s_clk after CLK_PERIOD / 2;

    -- Processo de estímulo
    stimulus: process
    begin
        report "Iniciando teste da Estoque_RAM...";
        
        -- Estado inicial
        s_write_enable <= '0';
        s_decrementa <= '0';
        s_data_in <= 0;
        
        -- 1. Teste de Leitura Inicial
        s_endereco <= "00";
        wait for CLK_PERIOD;
        assert (s_data_out = 10) report "Falha na leitura inicial. Esperado: 10" severity error;
        
        -- 2. Teste de Decremento
        report "Testando decremento...";
        s_endereco <= "01";
        s_decrementa <= '1';
        wait for CLK_PERIOD;
        s_decrementa <= '0';
        wait for CLK_PERIOD;
        assert (s_data_out = 9) report "Falha no decremento. Esperado: 9, Recebido: " & integer'image(s_data_out) severity error;
        
        -- 3. Teste de Reposição (Escrita)
        report "Testando reposicao...";
        s_endereco <= "02";
        s_data_in <= 25; -- Repondo 25 unidades
        s_write_enable <= '1';
        wait for CLK_PERIOD;
        s_write_enable <= '0';
        s_data_in <= 0;
        wait for CLK_PERIOD;
        assert (s_data_out = 25) report "Falha na escrita. Esperado: 25, Recebido: " & integer'image(s_data_out) severity error;
        
        report "Teste da Estoque_RAM concluido.";
        wait;
    end process stimulus;

end architecture test;