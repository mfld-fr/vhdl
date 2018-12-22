library ieee;
use ieee.std_logic_1164.all;


entity latch_sr_nand is

	port (
	    NS : in std_logic;
	    NR : in std_logic;

	    Q : inout std_logic;
	    NQ : inout std_logic
	    );

end entity;


architecture behavior of latch_sr_nand is
begin

	Q <= NS nand NQ;
	NQ <= NR nand Q;

end architecture;

