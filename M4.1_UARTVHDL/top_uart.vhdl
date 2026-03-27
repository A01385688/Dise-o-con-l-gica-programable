library ieee;
use ieee.std_logic_1164.all;

entity top_uart is
    port(
        clk      : in  std_logic;
        rst      : in  std_logic; -- KEY0
        key1     : in  std_logic; -- KEY1
        sw       : in  std_logic_vector(7 downto 0);
        ledr     : out std_logic_vector(7 downto 0);
        tx       : out std_logic
    );
end entity;

architecture rtl of top_uart is
    signal tick        : std_logic;
    signal tx_start    : std_logic;
    signal rst_internal : std_logic;
begin
    ledr <= sw;

    -- CORRECCIÓN DE LÓGICA:
    -- Los botones mandan '0' al presionar. 
    -- 'not rst' hace que el reset sea '1' (activo) solo cuando presionas KEY0.
    rst_internal <= not rst; 
    
    -- 'not key1' hace que la transmisión empiece al presionar KEY1.
    tx_start <= not key1;

    baud_unit: entity work.baudrate_gen
        port map(
            clk   => clk,
            reset => rst_internal, 
            tick  => tick
        );

    uart_unit: entity work.uart
        port map(
            s_tick       => tick,
            tx_start     => tx_start,
            clk          => clk,
            rst          => rst_internal,
            d_in         => sw,
            tx           => tx,
            tx_done_tick => open
        );
end architecture;
