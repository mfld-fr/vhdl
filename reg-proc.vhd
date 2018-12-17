library ieee;
use ieee.std_logic_1164.all;


entity reg_proc is

    generic (N : positive);

    port (
        I : in std_logic_vector (N-1 downto 0);
        O : out std_logic_vector (N-1 downto 0);

        E : in std_logic;  -- enable
        R : in std_logic;  -- reset

        CK : in std_logic  -- clock
        );

end entity reg_proc;


architecture behavior of reg_proc is

begin

    process (I, E, R, CK)
    begin
        if R = '1'
            then O <= (O'range => '0');
        elsif E = '1' and rising_edge (CK)
            then O <= I;
        end if;
   
    end process;

end architecture behavior;
