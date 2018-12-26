library ieee;
use ieee.std_logic_1164.all;


entity test_latch_sre_nand is
end entity;


architecture behavior of test_latch_sre_nand is

	component latch_sre_nand is

		port (
			S : in std_logic;
			R : in std_logic;

			E : in std_logic;

			PS : in std_logic;
			PR : in std_logic;

			Q  : inout std_logic;
			NQ : inout std_logic
			);

	end component;

	signal S : std_logic := '0';
	signal R : std_logic := '0';

	signal E : std_logic := '0';

	signal PS : std_logic := '0';
	signal PR : std_logic := '0';

	signal Q  : std_logic;
	signal NQ : std_logic;

begin

	latch_0: latch_sre_nand port map (S => S, R => R, E => E, PS => PS, PR => PR, Q => Q, NQ => NQ);

	process
	begin
		wait for 10 ms;
		PS <= '1';
		wait for 1 ms;
		assert Q = '1';
		PS <= '0';
		wait for 10 ms;
		assert Q = '1';
		PR <= '1';
		wait for 1 ms;
		assert Q = '0';
		PR <= '0';
		wait for 10 ms;
		assert Q = '0';
		S <= '1';
		wait for 1 ms;
		assert Q = '0';
		S <= '0';
		wait for 10 ms;
		assert Q = '0';
		E <= '1';
		wait for 10 ms;
		assert Q = '0';
		S <= '1';
		wait for 1 ms;
		assert Q = '1';
		S <= '0';
		wait for 10 ms;
		assert Q = '1';
		E <= '0';
		wait for 10 ms;
		assert Q = '1';
		R <= '1';
		wait for 1 ms;
		assert Q = '1';
		R <= '0';
		wait for 10 ms;
		assert Q = '1';
		E <= '1';
		wait for 10 ms;
		assert Q = '1';
		R <= '1';
		wait for 1 ms;
		assert Q = '0';
		R <= '0';
		wait for 10 ms;
		assert Q = '0';
		E <= '0';
	end process;

end architecture;
