library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity baudrate_gen is
    generic(
        M : integer := 434;  -- Divisor para 115200 baudios con clk de 50MHz
        N : integer := 9     -- Bits necesarios para representar 434
    );
    port(
        clk, reset : in std_logic;
        tick : out std_logic
    );
end baudrate_gen;

architecture behavior of baudrate_gen is
    signal clk_reg : unsigned(N-1 downto 0) := (others => '0');
begin

    process(clk, reset)
    begin
        if reset = '1' then
            clk_reg <= (others => '0');
        elsif rising_edge(clk) then
            if clk_reg = M-1 then
                clk_reg <= (others => '0');
            else
                clk_reg <= clk_reg + 1;
            end if;
        end if;
    end process;

    -- Genera un pulso (tick) de un ciclo de reloj cada vez que el contador llega a 0
    tick <= '1' when clk_reg = 0 else '0';

end architecture;
