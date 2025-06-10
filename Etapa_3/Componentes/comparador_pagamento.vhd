library ieee;
use ieee.std_logic_1164.all;

entity Comparador_Pagamento is
    port (
        valor_acumulado : in  integer range 0 to 255;
        preco_produto   : in  integer range 0 to 255;
        valor_suficiente: out std_logic
    );
end entity Comparador_Pagamento;

architecture Behavioral of Comparador_Pagamento is
begin
    -- A saída é '1' se o valor acumulado for maior ou igual ao preço.
    valor_suficiente <= '1' when valor_acumulado >= preco_produto else '0';
end architecture Behavioral;