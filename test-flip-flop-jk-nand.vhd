library ieee;
use ieee.std_logic_1164.all;


entity test_flip_flop_jk_nand is
end entity;


architecture behavior of test_flip_flop_jk_nand is

	component flip_flop_jk_nand is

		port (
			J : in std_logic;
			K : in std_logic;

			E : in std_logic;

			PS : in std_logic;
			PR : in std_logic;

			CK : in std_logic := '0';

			Q  : inout std_logic;
			NQ : inout std_logic
		);

	end component;

	signal J : std_logic := '0';
	signal K : std_logic := '0';

	signal E : std_logic := '0';

	signal PS : std_logic := '0';
	signal PR : std_logic := '0';

	signal CK : std_logic := '0';

	signal Q  : std_logic;
	signal NQ : std_logic;

begin

	flip_flop_0: flip_flop_jk_nand port map (J => J, K => K, E => E, PS => PS, PR => PR, CK => CK, Q => Q, NQ => NQ);

	process
	begin
		wait for 10 ms;
		PR <= '1';
		wait for 10 ms;
		PR <= '0';
		wait for 10 ms;
		J <= '1';
		wait for 10 ms;
		J <= '0';
		wait for 10 ms;
		E <= '1';
		wait for 10 ms;
		J <= '1';
		wait for 10 ms;
		J <= '0';
		wait for 10 ms;
		E <= '0';
		wait for 10 ms;
		K <= '1';
		wait for 10 ms;
		K <= '0';
		wait for 10 ms;
		E <= '1';
		wait for 10 ms;
		K <= '1';
		wait for 10 ms;
		K <= '0';
		wait for 10 ms;
		J <= '1';
		K <= '1';
		wait for 10 ms;
		E <= '0';
		J <= '0';
		K <= '0';
	end process;

	process
	begin
		wait for 1 ms;
		CK <= '1';
		wait for 1 ms;
		CK <= '0';
	end process;

end architecture;
