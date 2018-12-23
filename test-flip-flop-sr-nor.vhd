library ieee;
use ieee.std_logic_1164.all;


entity test_flip_flop_sr_nor is
end entity;


architecture behavior of test_flip_flop_sr_nor is

    component flip_flop_sr_nor is
	    port (
	    S : in std_logic;
	    R : in std_logic;
	    
	    CK : in std_logic;

	    Q  : out std_logic;
	    NQ : out std_logic
	    );

    end component;

    signal S : std_logic := '0';
    signal R : std_logic := '0';

    signal CK : std_logic := '0';

    signal Q  : std_logic;
    signal NQ : std_logic;

begin

    flip_flop_1: flip_flop_sr_nor port map (S => S, R => R, CK => CK, Q => Q, NQ => NQ);

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
