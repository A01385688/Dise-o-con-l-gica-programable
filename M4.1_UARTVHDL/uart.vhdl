library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity uart is
    port(
        s_tick, tx_start, clk, rst : in std_logic;
        d_in : in std_logic_vector(7 downto 0);
        tx, tx_done_tick : out std_logic
    );
end entity;

architecture behavioral of uart is

    type state_type is (idle, start, data, stop);
    signal C_state, N_state : state_type;

    -- Rango ampliado para evitar errores de "out of range" en síntesis
    signal COUNT : integer range 0 to 15 := 0; 
    signal data_reg : std_logic_vector(7 downto 0);

begin

    -- Registro de estado y lógica secuencial
    process(clk, rst)
    begin
        if rst = '1' then
            C_state <= idle;
            COUNT <= 0;
            data_reg <= (others => '0');
        elsif rising_edge(clk) then
            if s_tick = '1' then
                C_state <= N_state;

                if C_state = idle and tx_start = '1' then
                    data_reg <= d_in;
                    COUNT <= 0;
                elsif C_state = data then
                    data_reg <= '0' & data_reg(7 downto 1); -- Desplazamiento a la derecha (LSB primero)
                    if COUNT < 7 then
                        COUNT <= COUNT + 1;
                    end if;
                end if;
            end if;
        end if;
    end process;

    -- Lógica de Próximo Estado (Combinacional)
    process(C_state, tx_start, COUNT)
    begin
        case C_state is
            when idle =>
                if tx_start = '1' then
                    N_state <= start;
                else
                    N_state <= idle;
                end if;

            when start =>
                N_state <= data;

            when data =>
                if COUNT = 7 then
                    N_state <= stop;
                else
                    N_state <= data;
                end if;

            when stop =>
                -- Espera a que se suelte el botón (tx_start = '0') para volver a IDLE
                -- Esto evita el envío infinito de caracteres
                if tx_start = '0' then 
                    N_state <= idle;
                else
                    N_state <= stop;
                end if;
        end case;
    end process;

    -- Lógica de Salida
    process(C_state, data_reg)
    begin
        case C_state is
            when idle =>
                tx <= '1'; -- Línea en alto (IDLE)
                tx_done_tick <= '0';
            when start =>
                tx <= '0'; -- Bit de inicio
                tx_done_tick <= '0';
            when data =>
                tx <= data_reg(0);
                tx_done_tick <= '0';
            when stop =>
                tx <= '1'; -- Bit de parada
                tx_done_tick <= '1';
        end case;
    end process;

end architecture;
