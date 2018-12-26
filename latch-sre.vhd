library ieee;
use ieee.std_logic_1164.all;


entity latch_sre is

	port (
		S : in std_logic;  -- set
		R : in std_logic;  -- reset

		E : in std_logic;  -- enable

		Q  : out std_logic;
		NQ : out std_logic
	);

end entity;


architecture behavior of latch_sre is
begin

	process (S, R, E)
	begin
		if E = '1' then
			if S = '1' then
				Q <= '1' after 200 us;
				NQ <= '0' after 300 us;
			end if;

			if R = '1' then
				Q <= '0' after 300 us;
				NQ <= '1' after 200 us;
			end if;
		end if;
	end process;

end architecture;
