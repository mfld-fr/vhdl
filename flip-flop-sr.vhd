library ieee;
use ieee.std_logic_1164.all;


entity flip_flop_sr is

	port (
		S : in std_logic;
		R : in std_logic;

		CK : in std_logic;

		Q  : out std_logic;
		NQ : out std_logic
	);

end entity;


architecture behavior of flip_flop_sr is
begin

	process (S, R, CK)
	begin
		if rising_edge (CK) then
			if S = '1' then
				Q  <= '1' after 300 us;
				NQ <= '0' after 400 us;
			end if;

			if R = '1' then
				Q  <= '0' after 400 us;
				NQ <= '1' after 300 us;
			end if;
		end if;

	end process;

end architecture;
