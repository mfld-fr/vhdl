library ieee;
use ieee.std_logic_1164.all;


entity test_latch_sre is
end entity;


architecture behavior of test_latch_sre is

	component latch_sre is

		port (
		S : in std_logic;
		R : in std_logic;

		E : in std_logic;

		Q : out std_logic;
		NQ : out std_logic
	);

	end component;

	signal S : std_logic;
	signal R : std_logic;

	signal E : std_logic;

	signal Q  : std_logic;
	signal NQ : std_logic;

begin

	latch_0: latch_sre port map (S => S, R => R, E => E, Q => Q, NQ => NQ);

	process

		variable T : boolean := false;

	begin
		wait for 10 ms;
		E <= '0';
		wait for 10 ms;
		if T = true then assert Q = '0'; end if;
		S <= '1';
		wait for 1 ms;
		if T = true then assert Q = '0'; end if;
		S <= '0';
		wait for 10 ms;
		if T = true then assert Q = '0'; end if;
		E <= '1';
		wait for 10 ms;
		if T = true then assert Q = '0'; end if;
		S <= '1';
		wait for 1 ms;
		assert Q = '1';
		T := true;  -- initialized
		S <= '0';
		wait for 1 ms;
		assert Q = '1';
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
		wait for 1 ms;
		assert Q = '0';
		wait for 10 ms;
	end process;

end architecture;
