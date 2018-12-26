library ieee;
use ieee.std_logic_1164.all;


entity latch_sr_nor is

	port (
		S : in std_logic;  -- set on high
		R : in std_logic;  -- reset on high

		Q  : out std_logic;
		NQ : out std_logic
		);

end entity;


architecture behavior of latch_sr_nor is

	-- use internal signal to avoid 'inout'

	signal T  : std_logic;
	signal NT : std_logic;

begin

	T  <= R nor NT;
	NT <= S nor T;

	Q  <= T;
	NQ <= NT;

end architecture;
