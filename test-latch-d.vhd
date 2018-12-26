library ieee;
use ieee.std_logic_1164.all;


entity test_latch_d is
end entity;


architecture behavior of test_latch_d is

	component latch_d is

		port (
			D : in std_logic;

			E : in std_logic;

			Q : out std_logic;
			NQ : out std_logic
			);

	end component;

	signal D : std_logic;

	signal E : std_logic;

	signal Q : std_logic;
	signal NQ : std_logic;

begin

	latch_0: latch_d port map (D => D, E => E, Q => Q, NQ => NQ);

	process

		variable T : boolean := false;

	begin
		wait for 10 ms;
		D <= '0';
		wait for 1 ms;
		if T = true then assert Q = '1'; end if;
		E <= '1';
		wait for 1 ms;
		assert Q = '0';
		T := true;
		E <= '0';
		wait for 1 ms;
		assert Q = '0';
		wait for 10 ms;
		D <= '1';
		wait for 1 ms;
		assert Q = '0';
		E <= '1';
		wait for 1 ms;
		assert Q = '1';
		E <= '0';
		wait for 1 ms;
		assert Q = '1';
	end process;

end architecture;
