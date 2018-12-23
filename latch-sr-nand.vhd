library ieee;
use ieee.std_logic_1164.all;


entity latch_sr_nand is

	port (
	    NS : in std_logic;
	    NR : in std_logic;

	    Q  : out std_logic;
	    NQ : out std_logic
	    );

end entity;


architecture behavior of latch_sr_nand is

signal T  : std_logic;
signal NT : std_logic;

begin

	T  <= NS nand NT;
	NT <= NR nand T;

    Q  <= T;
    NQ <= T;

end architecture;
