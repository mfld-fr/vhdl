library ieee;
use ieee.std_logic_1164.all;

entity test_latch_sr_nand is
end test_latch_sr_nand;

architecture sequence of test_latch_sr_nand is

    component latch_sr_nand is
	    port (
	    S : in std_logic;
	    R : in std_logic;
	    Q0 : inout std_logic;
	    Q1 : inout std_logic
	    );

    end component;

    signal S : std_logic := '1';
    signal R : std_logic := '1';
    signal O : std_logic;

begin

    latch_1: latch_sr_nand port map (S => S, R => R, Q0 => O);

    process
        begin
        wait for 10 ns;
        S <= '0';
        wait for 1 ns;
        S <= '1';
        wait for 10 ns;
        R <= '0';
        wait for 1 ns;
        R <= '1';
      end process;

end sequence;
