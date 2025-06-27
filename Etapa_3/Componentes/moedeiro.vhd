library ieee;
use ieee.std_logic_1164.all;

-- Este eh um modelo conceitual de um validador de moedas.
entity Moedeiro is
    port (
        habilita_moedeiro   : in  std_logic; -- Sinal da FSM para ligar o moedeiro
        sinal_moeda_25c     : in  std_logic; -- Simula o sensor da moeda de 25 centavos
        sinal_moeda_50c     : in  std_logic; -- Simula o sensor da moeda de 50 centavos
        sinal_moeda_1real   : in  std_logic; -- Simula o sensor da moeda de 1 real
        valor_moeda         : out integer range 0 to 255 -- Saida 'val' para a FSM
    );
end entity Moedeiro;

architecture Behavioral of Moedeiro is
begin
    process(habilita_moedeiro, sinal_moeda_25c, sinal_moeda_50c, sinal_moeda_1real)
    begin
        -- Por padrao, nenhuma moeda eh detectada
        valor_moeda <= 0;
        
        if habilita_moedeiro = '1' then
            if sinal_moeda_1real = '1' then
                valor_moeda <= 100; -- 1 Real = 100 centavos
            elsif sinal_moeda_50c = '1' then
                valor_moeda <= 50;
            elsif sinal_moeda_25c = '1' then
                valor_moeda <= 25;
            end if;
        end if;
    end process;
end architecture Behavioral;