library ieee;
use ieee.std_logic_1164.all;


entity latch_w is

    generic (N : positive);

    port (
        I : in std_logic_vector (N-1 downto 0);
        O : out std_logic_vector (N-1 downto 0);

        E : in std_logic  -- enable
        );

end entity;


architecture behavior of latch_w is
begin

	O <= I when E = '1';

end architecture;
