library ieee;
use ieee.std_logic_1164.all;


entity test_flip_flop_d is
end entity;


architecture behavior of test_flip_flop_d is

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
    signal S : std_logic := '0';
    signal R : std_logic := '0';

    signal D : std_logic := '0';
    signal E : std_logic := '0';
    signal Q : std_logic;

begin

    ff_0: flip_flop_d port map (D => D, E => E, Q => Q, S => S, R => R, CK => CK);

	process
	begin
		CK <= '0';
		wait for 1 ms;
		CK <= '1';
		wait for 1 ms;
	end process;

	process
	begin
		S <= '1';
		wait for 1 ms;
		assert Q = '1';
		S <= '0';
		wait for 1 ms;
		assert Q = '1';
		wait for 10 ms;
		R <= '1';
		wait for 1 ms;
		assert Q = '0';
		R <= '0';
		wait for 1 ms;
		assert Q = '0';
		wait for 10 ms;
		D <= '1';
		wait for 10 ms;
		E <= '1';
		wait for 10 ms;
		E <= '0';
		wait for 10 ms;
		D <= '0';
		wait for 10 ms;
		E <= '1';
		wait for 10 ms;
		E <= '0';
	end process;

end architecture;
