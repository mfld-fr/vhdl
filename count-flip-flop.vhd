library ieee;
use ieee.std_logic_1164.all;


entity count_flip_flop is

    generic (N : positive);

    port (
        Q : inout std_logic_vector (N-1 downto 0);

        E : in std_logic;  -- enable
        R : in std_logic;  -- reset

        CK : in std_logic  -- clock
        );

end count_flip_flop;


architecture behavior of count_flip_flop is

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

    signal NQ : std_logic_vector (N-1 downto 0);

begin

    ff_0: flip_flop_d port map (D => NQ(0), E => E, Q => Q(0), S => '0', R => R, CK => CK);
    
    ff_N: for I in 1 to N-1 generate
        ff_I: flip_flop_d port map (D => NQ(I), E => E, Q => Q(I), S => '0', R => R, CK => NQ(I-1));
    end generate;

    NQ <= not Q;

end behavior;
