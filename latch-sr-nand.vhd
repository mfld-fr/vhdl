library ieee;
use ieee.std_logic_1164.all;

entity latch_sr_nand is
	port (
	S : in std_logic;
	R : in std_logic;
	Q0 : inout std_logic;
	Q1 : inout std_logic
	);

end latch_sr_nand;

architecture flow of latch_sr_nand is
begin
	Q0 <= S nand Q1;
	Q1 <= R nand Q0;

end flow;

