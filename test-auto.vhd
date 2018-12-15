library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity test_auto is

    generic (
        N : positive := 4;
        P : positive := 11
        );

end test_auto;


architecture behavior of test_auto is

    subtype WORD is std_logic_vector (N-1 downto 0);

    subtype INDEX is std_logic_vector (N-1 downto 0);
    subtype STEP is std_logic_vector (P-1 downto 0);

    type ROM_STEP is array (0 to 2**N - 1) of STEP;

    --   X           data pointer enable
    --    X          address source select (0: IP, 1: data pointer)
    --     X         accumulator enable
    --      X        next address select (0: increment address, 1: data bus)
    --       X       instruction pointer enable
    --        X      next index select (0: step, 1: instruction register)
    --         X     instruction register enable

    constant rom_step_0: ROM_STEP := (
        "00001010001",  -- 0h  load IR & increment IP
        "00000100000",  -- 1h  decode instruction
        "00000000000",  -- 2h
        "00000000000",  -- 3h
        "00101000000",  -- 4h  LD A,immediate
        "10010000110",  -- 5h  LD DP,immediate (1/2)
        "00001000000",  -- 6h  increment IP (2/2)
        "00000000000",  -- 7h
        "00000000000",  -- 8h  NOP
        "00000000000",  -- 9h
        "00000000000",  -- Ah
        "00000000000",  -- Bh
        "00011000000",  -- Ch  JMP immediate
        "00000000000",  -- Dh
        "00000000000",  -- Eh
        "00000000000"   -- Fh
        );

    type ROM_PROG is array (0 to 2**N - 1) of WORD;
    
    constant rom_prog_0: ROM_PROG := (
        "1000",  -- 0h  NOP
        "0101",  -- 1h  LD DP,...
        "1101",  -- 2h  ...Dh
        "1000",  -- 3h  NOP
        "0100",  -- 4h  LD A,...
        "1010",  -- 5h  ...Ah
        "1100",  -- 6h  JMP...
        "1000",  -- 7h  ...8h
        "1000",  -- 8h  NOP
        "1100",  -- 9h  JMP...
        "1100",  -- Ah  ...Ch
        "0000",  -- Bh
        "0100",  -- Ch  LD A,...
        "0101",  -- Dh  ..5h
        "1100",  -- Eh  JMP...
        "0000"   -- Fh  ...0h
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

    signal C : std_logic_vector (P - N - 1 downto 0);  -- control bus
    signal data_bus : WORD;
    
    signal ins_reg_en : std_logic;  -- instruction register enable

    signal ptr_inc : WORD;  -- pointer incrementer output
    signal ptr_next : WORD;  -- pointer next value

    signal ptr_sel : std_logic; -- pointer next value select
    signal ins_ptr_en : std_logic;  -- instruction pointer enable
    signal dat_ptr_en : std_logic;  -- data pointer enable

    signal ins_addr : WORD;
    signal dat_addr : WORD;
    signal addr_bus : WORD;

    signal addr_sel : std_logic;  -- select address source

    signal acc_en : std_logic;  -- accumulator enable

    signal alu_left : WORD;   -- ALU left value
    signal alu_right : WORD;  -- ALU right value

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
    acc_en     <= C (4);
    addr_sel   <= C (5);
    dat_ptr_en <= C (6);

    ins_ptr: reg_flip_flop
        generic map (N => N)
        port map (I => ptr_next, O => ins_addr, E => ins_ptr_en, R => R, CK => CK);

    dat_ptr: reg_flip_flop
        generic map (N => N)
        port map (I => ptr_next, O => dat_addr, E => dat_ptr_en, R => R, CK => CK);

    mux_addr: mux_2
        generic map (N => N)
        port map (I0 => ins_addr, I1 => dat_addr, O => addr_bus, S => addr_sel);

    ptr_inc <= std_logic_vector (to_unsigned (to_integer (unsigned (addr_bus)) + 1, N)) when addr_bus /= "1111" else "0000";

    data_bus <= rom_prog_0 (to_integer (unsigned (addr_bus)));

    mux_ptr: mux_2
        generic map (N => N)
        port map (I0 => ptr_inc, I1 => data_bus, O => ptr_next, S => ptr_sel);

    reg_acc: reg_flip_flop
        generic map (N => N)
        port map (I => data_bus, O => alu_left, E => acc_en, R => R, CK => CK);

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
