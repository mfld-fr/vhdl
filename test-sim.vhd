library ieee;
use ieee.std_logic_1164.all;

entity test_sim is
end entity;

architecture behavior of test_sim is

	signal a : integer := 0;
	signal b : integer := 1;

	signal e,f,g : std_logic;

begin

	a <= a + b after 1 ms;
	b <= a - b after 1 ms;

	e <= '0' after 1 ms;
	f <= e after 1 ms;
	g <= f after 1 ms;

end architecture;
