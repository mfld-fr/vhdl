library ieee;
use ieee.std_logic_1164.all;


entity flip_flop_sr_nand is

	port (
		S : in std_logic;
		R : in std_logic;

		CK : in std_logic;

		Q  : inout std_logic;
		NQ : inout std_logic
	);

end entity;


architecture behavior of flip_flop_sr_nand is

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

	signal T  : std_logic;
	signal NT : std_logic;

	signal NCK : std_logic;

begin

	NCK <= not CK after 100 us;

	latch_0: latch_sre_nand port map (S => S, R => R,  E => CK,  PS => '0', PR => '0', Q => T, NQ => NT);
	latch_1: latch_sre_nand port map (S => T, R => NT, E => NCK, PS => '0', PR => '0', Q => Q, NQ => NQ);

end architecture;
