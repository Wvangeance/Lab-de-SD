library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_preco_rom is
end entity tb_preco_rom;

architecture test of tb_preco_rom is
    -- Instanciação do componente a ser testado
    component Preco_ROM is
        port (
            endereco    : in  std_logic_vector(1 downto 0);
            preco_out   : out integer range 0 to 255
        );
    end component;

    -- Sinais para conectar ao componente
    signal s_endereco : std_logic_vector(1 downto 0);
    signal s_preco_out : integer range 0 to 255;

begin
    -- Conectando os sinais à instância do componente (Unit Under Test)
    uut: Preco_ROM port map (
        endereco    => s_endereco,
        preco_out   => s_preco_out
    );

    -- Processo de estímulo para testar todos os endereços
    stimulus: process
    begin
        report "Iniciando teste da Preco_ROM...";

        -- Testa endereço 00
        s_endereco <= "00";
        wait for 10 ns;
        assert (s_preco_out = 5) report "Falha no endereco 00. Esperado: 5, Recebido: " & integer'image(s_preco_out) severity error;

        -- Testa endereço 01
        s_endereco <= "01";
        wait for 10 ns;
        assert (s_preco_out = 7) report "Falha no endereco 01. Esperado: 7, Recebido: " & integer'image(s_preco_out) severity error;

        -- Testa endereço 10
        s_endereco <= "10";
        wait for 10 ns;
        assert (s_preco_out = 4) report "Falha no endereco 10. Esperado: 4, Recebido: " & integer'image(s_preco_out) severity error;
        
        -- Testa endereço 11
        s_endereco <= "11";
        wait for 10 ns;
        assert (s_preco_out = 8) report "Falha no endereco 11. Esperado: 8, Recebido: " & integer'image(s_preco_out) severity error;

        report "Teste da Preco_ROM concluido com sucesso." severity note;
        wait; -- Fim da simulação
    end process stimulus;

end architecture test;