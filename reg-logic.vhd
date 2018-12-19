library ieee;
use ieee.std_logic_1164.all;


entity reg_logic is

    generic (N : positive);

    port (
        I : in std_logic_vector (N-1 downto 0);
        O : out std_logic_vector (N-1 downto 0);

        E : in std_logic;  -- enable
        R : in std_logic;  -- reset

        CK : in std_logic  -- clock
        );

end entity;


architecture behavior of reg_logic is

begin

    O <= (I'range => '0') when R = '1' else I when E = '1' and rising_edge (CK);

end architecture;
