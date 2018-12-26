library ieee;
use ieee.std_logic_1164.all;


entity latch_sre_nand is

	port (
		S : in std_logic;  -- set
		R : in std_logic;  -- reset

		E : in std_logic;  -- enable

		PS : in std_logic;  -- preset
		PR : in std_logic;  -- prereset

		Q  : inout std_logic;
		NQ : inout std_logic
	);

end entity;


architecture behavior of latch_sre_nand is

	signal T  : std_logic;
	signal NT : std_logic;

	signal U  : std_logic;
	signal NU : std_logic;

begin

	T  <= S and E after 100 us;
	NT <= R and E after 100 us;

	U  <= T  nor PS after 100 us;
	NU <= NT nor PR after 100 us;

	-- this order for R priority

	Q  <= U nand NQ after 100 us;
	NQ <= NU nand Q after 100 us;

end architecture;
