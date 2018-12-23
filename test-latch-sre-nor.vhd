library ieee;
use ieee.std_logic_1164.all;


entity test_latch_sre_nor is
end entity test_latch_sre_nor;


architecture behavior of test_latch_sre_nor is

    component latch_sre_nor is

	    port (
	        S : in std_logic;
	        R : in std_logic;
	        E : in std_logic;

	        Q  : out std_logic;
	        NQ : out std_logic
	        );

    end component;

    signal S : std_logic := '0';
    signal R : std_logic := '0';
    
    signal E : std_logic := '0';

    signal Q  : std_logic;
    signal NQ : std_logic;

begin

    latch_1: latch_sre_nor port map (S => S, R => R, E => E, Q => Q, NQ => NQ);

    process
    begin
        wait for 5 ms;
        S <= '1';
        wait for 1 ms;
        S <= '0';
        wait for 5 ms;
        E <= '1';
        wait for 5 ms;
        S <= '1';
        wait for 1 ms;
        S <= '0';
        wait for 5 ms;
        E <= '0';
        wait for 5 ms;
        R <= '1';
        wait for 1 ms;
        R <= '0';
        wait for 5 ms;
        E <= '1';
        wait for 5 ms;
        R <= '1';
        wait for 1 ms;
        R <= '0';
        wait for 5 ms;
        E <= '0';
      end process;

end architecture behavior;
