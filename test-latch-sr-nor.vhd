library ieee;
use ieee.std_logic_1164.all;


entity test_latch_sr_nor is
end entity;


architecture behavior of test_latch_sr_nor is

    component latch_sr_nor is
	    port (
	    S : in std_logic;
	    R : in std_logic;

	    Q : inout std_logic;
	    NQ : inout std_logic
	    );

    end component;

    signal S : std_logic := '0';
    signal R : std_logic := '0';

    signal Q : std_logic;
    signal NQ : std_logic;

begin

    latch_1: latch_sr_nor port map (S => S, R => R, Q => Q, NQ => NQ);

    process
        begin
        wait for 10 ms;
        S <= '1';
        wait for 1 ms;
        S <= '0';
        wait for 10 ms;
        R <= '1';
        wait for 1 ms;
        R <= '0';
      end process;

end architecture;
