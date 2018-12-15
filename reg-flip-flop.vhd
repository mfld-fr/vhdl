library ieee;
use ieee.std_logic_1164.all;


entity reg_flip_flop is

    generic (N : natural);

    port (
        I : in std_logic_vector (N-1 downto 0);
        O : out std_logic_vector (N-1 downto 0);

        E : in std_logic;  -- enable
        R : in std_logic;  -- reset

        CK : in std_logic  -- clock
        );

end reg_flip_flop;


architecture behavior of reg_flip_flop is

    component flip_flop_d is
	    port (
	        D : in std_logic;
	        E : in std_logic;
	        Q : out std_logic;

	        S : in std_logic;
	        R : in std_logic;

	        CK : in std_logic
        );

    end component;

begin

    ff_N: for B in 0 to N-1 generate
        ff_I: flip_flop_d port map (D => I(B), E => E, Q => O(B), S => '0', R => R, CK => CK);
    end generate;

end behavior;
