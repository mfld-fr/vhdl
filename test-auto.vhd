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
        "00000000",  -- 8 - instruction 8 - NOP
        "00000000",  -- 9
        "00000000",  -- A
        "00000000",  -- B
        "11000000",  -- C - instruction C - JMP immediate
        "00000000",  -- D
        "00000000",  -- E
        "00000000"   -- F
        );

    type ROM_PROG is array (0 to 2**N - 1) of WORD;
    
    constant rom_prog_0: ROM_PROG := (
        "1000",  -- 0 - NOP
        "1100",  -- 1 - JMP...
        "1000",  -- 2 - ...8
        "0000",  -- 3
        "0000",  -- 4
        "0000",  -- 5
        "0000",  -- 6
        "0000",  -- 7
        "1000",  -- 8 - NOP
        "1100",  -- 9 - JMP...
        "0000",  -- A - ...0
        "0000",  -- B
        "0000",  -- C
        "0000",  -- D
        "0000",  -- E
        "0000"   -- F
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
    signal data_bus : WORD;
    signal addr_bus : WORD;
    
    signal ins_reg_en : std_logic;  -- instruction register enable
    signal ins_ptr_en : std_logic;  -- instruction pointer enable

    signal ptr_inc : WORD;  -- pointer incrementer output
    signal ptr_next : WORD;  -- pointer next value

    signal ptr_sel : std_logic; -- pointer next value select

begin

    reg_ins: reg_flip_flop
        generic map (N => N)
        port map (I => data_bus, O => ins_index, E => ins_reg_en, R => R, CK => CK);
    
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
    ptr_sel    <= C (3);

    ins_ptr: reg_flip_flop
        generic map (N => N)
        port map (I => ptr_next, O => addr_bus, E => ins_ptr_en, R => R, CK => CK);

    ptr_inc <= std_logic_vector (to_unsigned (to_integer (unsigned (addr_bus)) + 1, N)) when addr_bus /= "1111" else "0000";

    mux_ptr: mux_2
        generic map (N => N)
        port map (I0 => ptr_inc, I1 => data_bus, O => ptr_next, S => ptr_sel);

    data_bus <= rom_prog_0 (to_integer (unsigned (addr_bus)));

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
