library ieee;
use ieee.std_logic_1164.all;

entity somador is
    port (
        in_A  : in  integer range 0 to 255;
        in_B  : in  integer range 0 to 255;
        out_S : out integer range 0 to 255
    );
end entity somador;

architecture Behavioral of somador is
begin
    out_S <= in_A + in_B;
end architecture Behavioral;