library ieee;
use ieee.std_logic_1164.all;

entity test_shift is

    generic (N : Integer := 8);

end test_shift;

architecture behavior of test_shift is

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

    signal CK : std_logic := '0';
    signal R : std_logic := '1';

    signal E : std_logic := '0';
    
    signal Q : std_logic_vector (N-1 downto 0);

begin

    ff_0: flip_flop_d port map (D => Q(N-1), E => E, Q => Q(0), S => R, R => '0', CK => CK);
    
    ff_N: for I in 1 to N-1 generate
        ff_I: flip_flop_d port map (D => Q(I-1), E => E, Q => Q(I), S => '0', R => R, CK => CK);
    end generate;

    process
    begin
        CK <= '0';
        wait for 1 ms;
        CK <= '1' nand R;
        wait for 1 ms;
    end process;

    process
    begin
        wait for 10 ms;
        R <= '0';
        wait for 10 ms;
        E <= '1';
        wait for 50 ms;
        E <= '0';
        wait for 50 ms;
    end process;

end behavior;
