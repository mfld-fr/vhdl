library ieee;
use ieee.std_logic_1164.all;


entity mux_2 is

    generic (N : positive);

    port (
        I0 : in std_logic_vector (N - 1 downto 0);
        I1 : in std_logic_vector (N - 1 downto 0);
        
        O : out std_logic_vector (N - 1 downto 0);

        S : in std_logic  -- select
        );

end mux_2;


architecture behavior of mux_2 is

begin

    O <= I0 when S = '0' else I1;

end behavior;
