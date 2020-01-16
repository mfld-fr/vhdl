library ieee;
use ieee.std_logic_1164.all;


entity test_reg_flip_flop is

    generic (N : positive := 4);

end entity;


architecture behavior of test_reg_flip_flop is

    component reg_flip_flop is

        generic (N : positive);

        port (
            I : in std_logic_vector (N-1 downto 0);
            O : out std_logic_vector (N-1 downto 0);

            E : in std_logic;  -- enable
            R : in std_logic;  -- reset

            CK : in std_logic  -- clock
            );

    end component;

    signal R : std_logic := '0';
    signal CK : std_logic := '0';

    signal E : std_logic := '0';

    signal I : std_logic_vector (N-1 downto 0) := (N-1 downto 0 => '0');
    signal O : std_logic_vector (N-1 downto 0);

begin

    reg_0: reg_flip_flop
        generic map (N => N)
        port map (I => I, O => O, E => E, R => R, CK => CK);

    process
    begin
        wait for 1 ms;
        CK <= '1' nand R;
        wait for 1 ms;
        CK <= '0';
    end process;

    process
    begin
        wait for 10 ms;
        R <= '0';
        wait for 10 ms;
        I <= "1010";
        E <= '1';
        wait for 10 ms;
        E <= '0';
        wait for 10 ms;
        I <= "0101";
        E <= '1';
        wait for 10 ms;
        E <= '0';
        wait for 10 ms;
        R <= '1';
    end process;

end architecture;
