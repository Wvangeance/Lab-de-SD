library ieee;
use ieee.std_logic_1164.all;

entity subtrator is
    port (
        in_A  : in  integer range 0 to 255;
        in_B  : in  integer range 0 to 255;
        out_S : out integer range 0 to 255
    );
end entity subtrator;

architecture Behavioral of subtrator is
begin
    process(in_A, in_B)
    begin
        if in_A >= in_B then
            out_S <= in_A - in_B;
        else
            out_S <= 0; -- Evita underflow
        end if;
    end process;
end architecture Behavioral;