library ieee;
use ieee.std_logic_1164.all;


entity test_flip_flop_sr_nand is
end entity;


architecture behavior of test_flip_flop_sr_nand is

    component flip_flop_sr_nand is
	    port (
	    S : in std_logic;
	    R : in std_logic;
	    
	    CK : in std_logic;

	    Q : inout std_logic;
	    NQ : inout std_logic
	    );

    end component;

    signal S : std_logic := '0';
    signal R : std_logic := '0';

    signal CK : std_logic := '0';

    signal Q : std_logic;
    signal NQ : std_logic;

begin

    flip_flop_1: flip_flop_sr_nand port map (S => S, R => R, CK => CK, Q => Q, NQ => NQ);

    process
    begin
        wait for 10 ms;
        S <= '1';
        wait for 10 ms;
        S <= '0';
        wait for 10 ms;
        R <= '1';
        wait for 10 ms;
        R <= '0';
    end process;

    process
    begin
        wait for 1 ms;
        CK <= '1';
        wait for 1 ms;
        CK <= '0';
    end process;

end architecture;
