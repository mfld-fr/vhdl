library ieee;
use ieee.std_logic_1164.all;


entity test_reg is
    generic (N : positive := 4);

end test_reg;


architecture behavior of test_reg is

--  component reg_flip_flop is
    component reg_proc is

        generic (N : positive);
    
        port (
            I : in std_logic_vector (N-1 downto 0);
            O : out std_logic_vector (N-1 downto 0);

            E : in std_logic;  -- enable
            R : in std_logic;  -- reset

            CK : in std_logic  -- clock
            );

    end component;

    signal CK : std_logic := '0';
    signal R : std_logic := '1';
    signal E : std_logic := '0';
    
    signal I : std_logic_vector (N-1 downto 0);
    signal O : std_logic_vector (N-1 downto 0);

begin

--  reg_0: reg_flip_flop
    reg_0: reg_proc
        generic map (N => N)
        port map (I => I, O => O, E => E, R => R, CK => CK);
    
    clock_1: process
    begin
        CK <= '0';
        wait for 1 ns;
        CK <= '1' nand R;
        wait for 1 ns;
    end process;

    test_1: process
    begin
        wait for 10 ns;
        R <= '0';
        wait for 10 ns;
        I <= "1010";
        E <= '1';
        wait for 10 ns;
        E <= '0';
        wait for 10 ns;
        I <= "0101";
        E <= '1';
        wait for 10 ns;
        E <= '0';
        wait for 10 ns;
        R <= '1';
    end process;

end behavior;
