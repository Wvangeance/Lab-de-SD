library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Acumulador_Valor is
    port (
        clk        : in  std_logic;
        reset      : in  std_logic; -- Usado por 'zera_tudo' ou 'devolve'
        add_enable : in  std_logic; -- Usado por 'credita'
        valor_in   : in  integer range 0 to 255;
        valor_total: out integer range 0 to 255
    );
end entity Acumulador_Valor;

architecture Behavioral of Acumulador_Valor is
    signal valor_interno : integer range 0 to 255 := 0;
begin
    process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                valor_interno <= 0;
            elsif add_enable = '1' then
                valor_interno <= valor_interno + valor_in;
            end if;
        end if;
    end process;

    valor_total <= valor_interno;
end architecture Behavioral;