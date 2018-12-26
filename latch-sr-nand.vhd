library ieee;
use ieee.std_logic_1164.all;


entity latch_sr_nand is

	port (
		S : in std_logic;  -- set on low
		R : in std_logic;  -- reset on low

		Q  : inout std_logic;
		NQ : inout std_logic
	);

end entity;


architecture behavior of latch_sr_nand is

begin

	-- order for R priority

	Q  <= S nand NQ after 100 us;
	NQ <= R nand Q  after 100 us;

end architecture;
