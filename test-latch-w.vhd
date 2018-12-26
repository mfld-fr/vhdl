library ieee;
use ieee.std_logic_1164.all;


entity test_latch_w is

	generic (N : positive := 4);

end entity;


architecture behavior of test_latch_w is

	component latch_w is

		generic (N : positive);

		port (
			I : in std_logic_vector (N-1 downto 0);
			O : out std_logic_vector (N-1 downto 0);

			E : in std_logic
		);

	end component;

	signal I : std_logic_vector (N-1 downto 0);
	signal O : std_logic_vector (N-1 downto 0);

	signal E : std_logic;

begin

	latch_0: latch_w
		generic map (N => N)
		port map (I => I, O => O, E => E);

	process

		variable T : boolean := false;

	begin
		wait for 10 ms;
		I <= (N-1 downto 0 => '0');
		wait for 1 ms;
		if T = true then assert O = (N-1 downto 0 => '1'); end if;
		E <= '1';
		wait for 1 ms;
		assert O = (N-1 downto 0 => '0');
		T := true;
		E <= '0';
		wait for 1 ms;
		assert O = (N-1 downto 0 => '0');
		wait for 10 ms;
		I <= (N-1 downto 0 => '1');
		wait for 1 ms;
		assert O = (N-1 downto 0 => '0');
		E <= '1';
		wait for 1 ms;
		assert O = (N-1 downto 0 => '1');
		E <= '0';
		wait for 1 ms;
		assert O = (N-1 downto 0 => '1');
	end process;

end architecture;

