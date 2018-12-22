library ieee;
use ieee.std_logic_1164.all;


entity latch_sre is

	port (
	    S : in std_logic;
	    R : in std_logic;

        E : in std_logic;

	    Q : out std_logic;
	    NQ : out std_logic
	    );

end entity;


architecture behavior of latch_sre is

    signal T : std_logic;

begin

    process (S, R, E)
    begin
        if E = '1' then
            if S = '1' then T <= '1'; end if;
            if R = '1' then T <= '0'; end if;
        end if;
    end process;

    Q <= T;
    NQ <= not T;

end architecture;
