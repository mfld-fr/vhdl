library ieee;
use ieee.std_logic_1164.all;

entity flip_flop_d is
	port (
	    D : in std_logic;   -- data in
	    E : in std_logic;   -- data enable
	    Q : out std_logic;  -- data out
	    
	    S : in std_logic;   -- set
	    R : in std_logic;   -- reset
	    CK : in std_logic   -- clock
    );

end flip_flop_d;

architecture behavior of flip_flop_d is
begin
	Q <= '1' when S = '1' else '0' when R = '1' else D when E = '1' and rising_edge (CK);
end behavior;

