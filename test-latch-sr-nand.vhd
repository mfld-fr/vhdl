library ieee;
use ieee.std_logic_1164.all;


entity test_latch_sr_nand is
end entity;


architecture behavior of test_latch_sr_nand is

	component latch_sr_nand is

		port (
			S : in std_logic;  -- set on low
			R : in std_logic;  -- reset on low

			Q  : inout std_logic;
			NQ : inout std_logic
		);

	end component;

	signal S : std_logic;
	signal R : std_logic;

	signal Q  : std_logic;

begin

	latch_0: latch_sr_nand port map (S => S, R => R, Q => Q);

	process

		variable T : boolean := false;

	begin
		wait for 10 ms;
		S <= '0';
		wait for 1 ms;
		if T = true then assert Q = '1'; end if;
		S <= '1';
		wait for 1 ms;
		if T = true then assert Q = '1'; end if;
		wait for 10 ms;
		R <= '0';
		wait for 1 ms;
		assert Q = '0';
		T := true;  -- safe reset as R has priority
		R <= '1';
		wait for 1 ms;
		assert Q = '0';
	end process;

end architecture;
