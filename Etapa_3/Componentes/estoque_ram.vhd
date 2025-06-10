library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Estoque_RAM is
    port (
        clk          : in  std_logic;
        write_enable : in  std_logic;
        decrementa   : in  std_logic;
        endereco     : in  std_logic_vector(1 downto 0);
        data_in      : in  integer range 0 to 255;
        data_out     : out integer range 0 to 255
    );
end entity Estoque_RAM;

architecture Behavioral of Estoque_RAM is
    -- Tipo para o array de armazenamento do estoque
    type array_estoque is array (0 to 3) of integer range 0 to 255;
    
    -- Sinal interno para o estoque. Inicializado com 10 unidades de cada.
    signal estoque_interno : array_estoque := (10, 10, 10, 10);

begin
    -- Processo síncrono para escrita e decremento
    process(clk)
    begin
        if rising_edge(clk) then
            -- Prioridade para escrita (reposição)
            if write_enable = '1' then
                estoque_interno(to_integer(unsigned(endereco))) <= data_in;
            -- Se não for escrita, verifica se é para decrementar
            elsif decrementa = '1' then
                -- Garante que o estoque não fique negativo
                if estoque_interno(to_integer(unsigned(endereco))) > 0 then
                    estoque_interno(to_integer(unsigned(endereco))) <= estoque_interno(to_integer(unsigned(endereco))) - 1;
                end if;
            end if;
        end if;
    end process;

    -- Leitura assíncrona do estoque
    data_out <= estoque_interno(to_integer(unsigned(endereco)));

end architecture Behavioral;