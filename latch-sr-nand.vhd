library ieee;
use ieee.std_logic_1164.all;


entity latch_sr_nand is

	port (
	    S : in std_logic;
	    R : in std_logic;

	    Q : inout std_logic;
	    NQ : inout std_logic
	    );

end entity;


architecture behavior of latch_sr_nand is
begin

	Q <= S nand NQ;
	NQ <= R nand Q;

end architecture;

