library ieee;
use ieee.std_logic_1164.all;


entity test_count is

    generic (N : positive := 4);

end test_count;


architecture behavior of test_count is

    component count_flip_flop is

        generic (N : positive);

        port (
            Q : inout std_logic_vector (N-1 downto 0);

            E : in std_logic;  -- enable
            R : in std_logic;  -- reset

            CK : in std_logic  -- clock
            );

    end component;

    signal CK : std_logic := '0';
    signal R : std_logic := '1';
    signal E : std_logic := '0';
    
    signal Q : std_logic_vector (N-1 downto 0);

begin

    count_0: count_flip_flop
        generic map (N => N)
        port map (Q => Q, E => E, R => R, CK => CK);
    
    clock_1: process
    begin
        CK <= '0';
        wait for 1 ns;
        CK <= '1' nand R;
        wait for 1 ns;
    end process;

    test_1: process
    begin
        wait for 10 ns;
        R <= '0';
        wait for 10 ns;
        E <= '1';
        wait for 50 ns;
        E <= '0';
        wait for 10 ns;
        R <= '1';
    end process;

end behavior;
