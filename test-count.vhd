library ieee;
use ieee.std_logic_1164.all;

entity test_count is

    generic (N : Integer := 4);

end test_count;

architecture behavior of test_count is

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
    
    signal Q0 : std_logic_vector (N-1 downto 0);
    signal Q1 : std_logic_vector (N-1 downto 0);

begin

    ff_0: flip_flop_d port map (D => Q1(0), E => E, Q => Q0(0), S => '0', R => R, CK => CK);
    
    ff_N: for I in 1 to N-1 generate
        ff_I: flip_flop_d port map (D => Q1(I), E => E, Q => Q0(I), S => '0', R => R, CK => Q1(I-1));
    end generate;

    Q1 <= not Q0;

    clock_1: process
    begin
        CK <= '0';
        wait for 1 ns;
        CK <= '1';
        wait for 1 ns;
    end process;

    test_1: process
    begin
        wait for 10 ns;
        R <= '0';
        wait for 10 ns;
        E <= '1';
        wait for 50 ns;
        E <= '0';
        wait for 50 ns;
    end process;

end behavior;
