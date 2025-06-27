library ieee;
use ieee.std_logic_1164.all;

entity comparador is
    port (
        in_A  : in  integer range 0 to 255;
        in_B  : in  integer range 0 to 255;
        out_S : out std_logic -- '1' se A >= B
    );
end entity comparador;

architecture Behavioral of comparador is
begin
    out_S <= '1' when in_A >= in_B else '0';
end architecture Behavioral;