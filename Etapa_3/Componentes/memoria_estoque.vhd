library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity memoria_estoque is
    port (
        clk        : in  std_logic;
        rst        : in  std_logic;
        wr         : in  std_logic; -- Write Enable
        decrementa : in  std_logic; -- Sinal para decrementar (venda)
        endereco   : in  std_logic_vector(1 downto 0);
        dado_in    : in  integer range 0 to 255;
        dado_out   : out integer range 0 to 255
    );
end entity memoria_estoque;

architecture Behavioral of memoria_estoque is
    type array_estoque is array (0 to 3) of integer range 0 to 255;
    signal estoque_interno : array_estoque := (10, 10, 10, 10);
begin
    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                estoque_interno <= (10, 10, 10, 10);
            elsif wr = '1' then
                estoque_interno(to_integer(unsigned(endereco))) <= dado_in;
            elsif decrementa = '1' and estoque_interno(to_integer(unsigned(endereco))) > 0 then
                estoque_interno(to_integer(unsigned(endereco))) <= estoque_interno(to_integer(unsigned(endereco))) - 1;
            end if;
        end if;
    end process;
    dado_out <= estoque_interno(to_integer(unsigned(endereco)));
end architecture Behavioral;