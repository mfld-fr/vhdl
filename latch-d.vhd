library ieee;
use ieee.std_logic_1164.all;


entity latch_d is

	port (
		D : in std_logic;  -- data in

		E : in std_logic;  -- enable

		Q  : out std_logic;
		NQ : out std_logic
	);

end entity;


architecture behavior of latch_d is

	signal T : std_logic;

begin

	T <= D when E = '1';

	Q  <= T;
	NQ <= not T;

end architecture;
