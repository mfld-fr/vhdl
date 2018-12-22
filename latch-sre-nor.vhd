library ieee;
use ieee.std_logic_1164.all;


entity latch_sre_nor is

	port (
	    S : in std_logic;
	    R : in std_logic;
        E : in std_logic;

	    Q : inout std_logic;
	    NQ : inout std_logic
	    );

end entity;


architecture behavior of latch_sre_nor is
begin

	Q <= (R and E) nor NQ;
	NQ <= (S and E) nor Q;

end architecture;

