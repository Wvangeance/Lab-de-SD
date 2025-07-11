library ieee;
use ieee.std_logic_1164.all;

entity reg_2b is
    port (
        clk    : in  std_logic;
        rst    : in  std_logic;
        enable : in  std_logic;
        in_D   : in  std_logic_vector(1 downto 0);
        out_Q  : out std_logic_vector(1 downto 0)
    );
end entity reg_2b;

architecture Behavioral of reg_2b is
begin
    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                out_Q <= "00";
            elsif enable = '1' then
                out_Q <= in_D;
            end if;
        end if;
    end process;
end architecture Behavioral;