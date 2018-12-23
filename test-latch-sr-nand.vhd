library ieee;
use ieee.std_logic_1164.all;


entity test_latch_sr_nand is
end entity;


architecture behavior of test_latch_sr_nand is

    component latch_sr_nand is
	    port (
	        NS : in std_logic;
	        NR : in std_logic;

	        Q  : out std_logic;
	        NQ : out std_logic
	        );

    end component;

    signal NS : std_logic := '1';
    signal NR : std_logic := '1';
    signal Q  : std_logic;

begin

    latch_1: latch_sr_nand port map (NS => NS, NR => NR, Q => Q);

    process
        begin
        wait for 10 ms;
        NS <= '0';
        wait for 1 ms;
        NS <= '1';
        wait for 10 ms;
        NR <= '0';
        wait for 1 ms;
        NR <= '1';
      end process;

end architecture;
