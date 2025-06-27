library ieee;
use ieee.std_logic_1164.all;

entity mux_2x1_2b is
    port (
        -- Nota: um MUX 2x1 usa um seletor de 1 bit. Implementado como tal.
        sel   : in  std_logic; 
        in_A  : in  std_logic_vector(1 downto 0);
        in_B  : in  std_logic_vector(1 downto 0);
        out_S : out std_logic_vector(1 downto 0)
    );
end entity mux_2x1_2b;

architecture Behavioral of mux_2x1_2b is
begin
    out_S <= in_A when sel = '0' else in_B;
end architecture Behavioral;