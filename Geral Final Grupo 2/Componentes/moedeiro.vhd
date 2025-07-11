library ieee;
use ieee.std_logic_1164.all;

entity moedeiro is
    port (
        habilita_moedeiro   : in  std_logic;
        sinal_moeda_25c     : in  std_logic;
        sinal_moeda_50c     : in  std_logic;
        sinal_moeda_1real   : in  std_logic;
        valor_moeda         : out integer range 0 to 255
    );
end entity moedeiro;

architecture Behavioral of moedeiro is
begin
    -- Processo combinacional para determinar o valor da moeda
    process(habilita_moedeiro, sinal_moeda_25c, sinal_moeda_50c, sinal_moeda_1real)
    begin
        valor_moeda <= 0; -- Valor padrao
        if habilita_moedeiro = '1' then
            if sinal_moeda_1real = '1' then
                valor_moeda <= 100; -- 1 Real = 100
            elsif sinal_moeda_50c = '1' then
                valor_moeda <= 50;
            elsif sinal_moeda_25c = '1' then
                valor_moeda <= 25;
            end if;
        end if;
    end process;
end architecture Behavioral;