library ieee;
use ieee.std_logic_1164.all;


entity flip_flop_jk_nand is

	port (
		J : in std_logic;   -- set
		K : in std_logic;   -- reset

		E : in std_logic;   -- enable

		PS : in std_logic;  -- preset
		PR : in std_logic;  -- prereset

		CK : in std_logic;  -- clock

		Q  : inout std_logic;
		NQ : inout std_logic
	);

end entity;


architecture behavior of flip_flop_jk_nand is

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

	signal NCK : std_logic;

	signal T  : std_logic;
	signal NT : std_logic;

	signal U  : std_logic;
	signal NU : std_logic;

begin

	NCK <= not CK after 100 us;

	T  <= J and E and NQ after 100 us;
	NT <= K and E and Q  after 100 us;

	latch_0: latch_sre_nand port map (S => T, R => NT, PS => PS, PR => PR, E => CK, Q => U, NQ => NU);
	latch_1: latch_sre_nand port map (S => U, R => NU, PS => PS, PR => PR, E => NCK, Q => Q, NQ => NQ);

end architecture;
