library ieee;
use ieee.std_logic_1164.all;


entity test_count_flip_flop is

    generic (N : positive := 4);

end entity;


architecture behavior of test_count_flip_flop is

    component count_flip_flop is

        generic (N : positive);

        port (
            O : out std_logic_vector (N-1 downto 0);

            E : in std_logic;  -- enable
            R : in std_logic;  -- reset

            CK : in std_logic  -- clock
            );

    end component;

    signal CK : std_logic := '0';

    signal R : std_logic := '1';
    signal E : std_logic := '0';
    
    signal O : std_logic_vector (N-1 downto 0);

begin

    count_0: count_flip_flop
        generic map (N => N)
        port map (O => O, E => E, R => R, CK => CK);
    
    process
    begin
        CK <= '0';
        wait for 1 ms;
        CK <= '1' nand R;
        wait for 1 ms;
    end process;

    process
    begin
        wait for 10 ms;
        R <= '0';
        wait for 10 ms;
        E <= '1';
        wait for 50 ms;
        E <= '0';
        wait for 10 ms;
        R <= '1';
    end process;

end architecture;
