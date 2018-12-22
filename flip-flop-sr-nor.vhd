library ieee;
use ieee.std_logic_1164.all;


entity flip_flop_sr_nor is

    port (
        S : in std_logic;
        R : in std_logic;

        CK : in std_logic;

        Q : inout std_logic;
        NQ : inout std_logic
        );

end entity;


architecture behavior of flip_flop_sr_nor is

    component latch_sre_nor is
	    port (
	    S : in std_logic;
	    R : in std_logic;

	    E : in std_logic;

	    Q : inout std_logic;
	    NQ : inout std_logic
	    );

    end component;

    signal T : std_logic;
    signal NT : std_logic;

    signal NCK : std_logic;

begin

    NCK <= not CK;

    latch_1: latch_sre_nor port map (S => S, R => R, E => CK, Q => T, NQ => NT);
    latch_2: latch_sre_nor port map (S => T, R => NT, E => NCK, Q => Q, NQ => NQ);

end architecture;
