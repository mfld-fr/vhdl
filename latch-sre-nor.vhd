library ieee;
use ieee.std_logic_1164.all;


entity latch_sre_nor is

	port (
		S : in std_logic;  -- set
		R : in std_logic;  -- reset

		E : in std_logic;  -- enable

		Q  : out std_logic;
		NQ : out std_logic
	    );

end entity;


architecture behavior of latch_sre_nor is

	-- use internal signal to avoid 'inout'

	signal T  : std_logic;
	signal NT : std_logic;

begin

	T  <= (R and E) nor NT;
	NT <= (S and E) nor T;

	Q  <= T;
	NQ <= NT;

end architecture;
