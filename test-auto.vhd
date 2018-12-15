library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity test_auto is

    generic (
        N : positive := 4;
        P : positive := 8
        );

end test_auto;


architecture behavior of test_auto is

    subtype WORD is std_logic_vector (N-1 downto 0);

    subtype INDEX is std_logic_vector (N-1 downto 0);
    subtype STEP is std_logic_vector (P-1 downto 0);

    type ROM_STEP is array (0 to 2**N - 1) of STEP;

    constant rom_step_0: ROM_STEP := (
        "01010001",  -- 0 - load IR & increment IP
        "00100000",  -- 1 - decode instruction
        "00000000",  -- 2
        "00000000",  -- 3
        "00000000",  -- 4
        "00000000",  -- 5
        "00000000",  -- 6
        "00000000",  -- 7
        "00000000",  -- 8 - instruction 8 - NOP 1 machine cycle
        "00000000",  -- 9
        "00000000",  -- A
        "00000000",  -- B
        "00001101",  -- C - instruction C - NOP 2 machine cycle
        "00000000",  -- D
        "00000000",  -- E
        "00000000"   -- F
        );

    type ROM_PROG is array (0 to 2**N - 1) of WORD;
    
    constant rom_prog_0: ROM_PROG := (
        "1000",  -- 0 - NOP 1
        "1100",  -- 1 - NOP 2
        "1000",  -- 2 - NOP 1
        "1100",  -- 3 - NOP 2
        "1000",  -- 4 - NOP 1
        "1100",  -- 5 - NOP 2
        "1000",  -- 6 - NOP 1
        "1100",  -- 7 - NOP 2
        "1000",  -- 8 - NOP 1
        "1100",  -- 9 - NOP 2
        "1000",  -- A - NOP 1
        "1100",  -- B - NOP 2
        "1000",  -- C - NOP 1
        "1100",  -- D - NOP 2
        "1000",  -- E - NOP 1
        "1100"   -- F - NOP 2
        );
        
    component mux_2 is

        generic (N : positive);

        port (
            I0 : in std_logic_vector (N - 1 downto 0);
            I1 : in std_logic_vector (N - 1 downto 0);
            
            O : out std_logic_vector (N - 1 downto 0);

            S : in std_logic  -- select
            );

    end component;

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

    signal CK : std_logic := '0';
    signal R : std_logic := '1';
    signal E : std_logic := '0';
    
    signal step_cur : STEP;
    
    signal cur_index : INDEX;  -- current from index register
    signal ins_index : INDEX;  -- index from instruction register
    signal step_index : INDEX;  -- index from automaton step
    signal next_index : INDEX;  -- next index after selection
    
    signal index_sel : std_logic;  -- select index source (step or instruction register)

    signal C : std_logic_vector (3 downto 0);  -- control bus
    signal D : WORD;  -- data bus
    signal A : WORD;  -- address bus
    
    signal ins_reg_en : std_logic;  -- instruction register enable
    signal ins_ptr_en : std_logic;  -- instruction pointer enable

    signal ptr_inc : WORD;  -- pointer incrementer output

begin

    reg_ins: reg_flip_flop
        generic map (N => N)
        port map (I => D, O => ins_index, E => ins_reg_en, R => R, CK => CK);
    
    mux_index: mux_2
        generic map (N => N)
        port map (I0 => step_index, I1 => ins_index, O => next_index, S => index_sel);

    reg_index: reg_flip_flop
        generic map (N => N)
        port map (I => next_index, O => cur_index, E => '1', R => R, CK => CK);

    step_cur <= rom_step_0 (to_integer (unsigned (cur_index)));

    step_index <= step_cur (N-1 downto 0);

    C <= step_cur (P-1 downto N);
    ins_reg_en <= C (0);
    index_sel  <= C (1);
    ins_ptr_en <= C (2);

    ins_ptr: reg_flip_flop
        generic map (N => N)
        port map (I => ptr_inc, O => A, E => ins_ptr_en, R => R, CK => CK);

    ptr_inc <= std_logic_vector (to_unsigned (to_integer (unsigned (A)) + 1, N)) when A /= "1111" else "0000";
    
    D <= rom_prog_0 (to_integer (unsigned (A)));

    clock_1: process
    begin
        wait for 1 ns;
        CK <= '1' and not R;
        wait for 1 ns;
        CK <= '0';
    end process;

    test_1: process
    begin
        wait for 10 ns;
        R <= '0';
        wait for 200 ns;
        R <= '1';
    end process;

end behavior;
