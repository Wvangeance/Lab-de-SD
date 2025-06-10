-- Bibliotecas padrão do IEEE
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Entidade do componente Preco_ROM
entity Preco_ROM is
    port (
        endereco    : in  std_logic_vector(1 downto 0);
        preco_out   : out integer range 0 to 255
    );
end entity Preco_ROM;

-- Arquitetura comportamental da ROM de preços
architecture Behavioral of Preco_ROM is
    -- Definindo um tipo para o array de preços
    type array_precos is array (0 to 3) of integer range 0 to 255;
    
    -- Constante que armazena os preços. Altere aqui se necessário.
    -- Produto 0: R$5, Produto 1: R$7, Produto 2: R$4, Produto 3: R$8
    constant PRECOS : array_precos := (5, 7, 4, 8);
    
begin
    -- A saída de preço é determinada diretamente pelo endereço de entrada.
    -- É um processo combinacional, não precisa de clock.
    preco_out <= PRECOS(to_integer(unsigned(endereco)));

end architecture Behavioral;