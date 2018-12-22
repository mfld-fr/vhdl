library ieee;
use ieee.std_logic_1164.all;


entity latch_sr_nor is

	port (
	    S : in std_logic;
	    R : in std_logic;

	    Q : inout std_logic;
	    NQ : inout std_logic
	    );

end entity;


architecture behavior of latch_sr_nor is
begin

	Q <= R nor NQ;
	NQ <= S nor Q;

end architecture;

