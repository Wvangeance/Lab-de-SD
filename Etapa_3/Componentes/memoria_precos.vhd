library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity memoria_precos is
    port (
        endereco  : in  std_logic_vector(1 downto 0);
        dado_out  : out integer range 0 to 255
    );
end entity memoria_precos;

architecture Behavioral of memoria_precos is
    type array_precos is array (0 to 3) of integer range 0 to 255;
    constant PRECOS : array_precos := (125, 150, 175, 200); -- Novos preços
begin
    dado_out <= PRECOS(to_integer(unsigned(endereco)));
end architecture Behavioral;