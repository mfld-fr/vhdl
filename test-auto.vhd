library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity test_auto is

    generic (
        N : positive := 4;
        P : positive := 12
        );

end test_auto;


architecture behavior of test_auto is

    subtype WORD is std_logic_vector (N-1 downto 0);

    subtype INDEX is std_logic_vector (N-1 downto 0);
    subtype STEP is std_logic_vector (P-1 downto 0);

    type ROM_STEP is array (0 to 2**N - 1) of STEP;

    --   X            ALU operation select
    --    X           data pointer enable
    --     X          address source select (0: instruction pointer, 1: data pointer)
    --      X         accumulator enable
    --       X        next address select (0: increment address, 1: data bus)
    --        X       instruction pointer enable
    --         X      next index select (0: step, 1: instruction register)
    --          X     instruction register enable

    constant rom_step_0: ROM_STEP := (
        "000001010001",  -- 0h  load IR & increment IP
        "000000100000",  -- 1h  decode instruction
        "000000000000",  -- 2h
        "000000000000",  -- 3h
        "000101000000",  -- 4h  LD A,immediate
        "010010000110",  -- 5h  LD DP,immediate (1/2)
        "000001000000",  -- 6h  increment IP (2/2)
        "000000000000",  -- 7h
        "001100000000",  -- 8h  LD A,(DP)
        "000000000000",  -- 9h  TODO: ST (DP),A
        "000000000000",  -- Ah
        "000000000000",  -- Bh
        "000011000000",  -- Ch  JMP immediate
        "000000000000",  -- Dh
        "000000000000",  -- Eh
        "000000000000"   -- Fh  NOP
        );

    type RAM_PROG is array (0 to 2**N - 1) of WORD;

    signal ram_prog_0: RAM_PROG := (
        "0100",  -- 0h  LD A,...
        "0001",  -- 1h  ...1h
        "0101",  -- 2h  LD DP,...
        "1110",  -- 3h  ...Eh
        "1000",  -- 4h  LD A,(DP)
        "0101",  -- 5h  LD DP,...
        "1111",  -- 6h  ...Fh
        "1000",  -- 7h  LD A,(DP)
        "1111",  -- 8h  NOP
        "1100",  -- 9h  JMP...
        "0000",  -- Ah  ...0h
        "0000",  -- Bh
        "0000",  -- Ch
        "0000",  -- Dh
        "0010",  -- Eh  DB 2h
        "0011"   -- Fh  DB 3h
        );
        
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
    
    signal step_cur : STEP;
    
    signal cur_index : INDEX;  -- current from index register
    signal ins_index : INDEX;  -- index from instruction register
    signal step_index : INDEX;  -- index from automaton step
    signal next_index : INDEX;  -- next index after selection
    
    signal index_sel : std_logic;  -- select index source (step or instruction register)

    signal C : std_logic_vector (P - N - 1 downto 0);  -- control bus

    signal data_in : WORD;  -- data bus input
    signal data_out : WORD;  -- data bus output

    signal ins_reg_en : std_logic;  -- instruction register enable

    signal ptr_inc : WORD;  -- pointer incrementer output
    signal ptr_next : WORD;  -- pointer next value

    signal ptr_sel : std_logic; -- pointer next value select
    signal ins_ptr_en : std_logic;  -- instruction pointer enable
    signal dat_ptr_en : std_logic;  -- data pointer enable

    signal ins_addr : WORD;
    signal dat_addr : WORD;
    signal addr_out : WORD;

    signal addr_sel : std_logic;  -- select address source

    signal acc_en : std_logic;  -- accumulator enable

    signal alu_left : WORD;   -- ALU left value
    signal alu_right : WORD;  -- ALU right value
    
    signal alu_sel : std_logic;  -- ALU operation select

begin

    reg_ins: reg_flip_flop
        generic map (N => N)
        port map (I => data_in, O => ins_index, E => ins_reg_en, R => R, CK => CK);

    next_index <= ins_index when index_sel = '1' else step_index;

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
    alu_sel    <= C (7);

    ins_ptr: reg_flip_flop
        generic map (N => N)
        port map (I => ptr_next, O => ins_addr, E => ins_ptr_en, R => R, CK => CK);

    dat_ptr: reg_flip_flop
        generic map (N => N)
        port map (I => ptr_next, O => dat_addr, E => dat_ptr_en, R => R, CK => CK);

    addr_out <= dat_addr when addr_sel = '1' else ins_addr;

    data_in <= ram_prog_0 (to_integer (unsigned (addr_out)));

    ptr_inc <= std_logic_vector (to_unsigned (to_integer (unsigned (addr_out)) + 1, N)) when addr_out /= "1111" else "0000";

    ptr_next <= data_in when ptr_sel = '1' else ptr_inc;

    reg_acc: reg_flip_flop
        generic map (N => N)
        port map (I => data_out, O => alu_left, E => acc_en, R => R, CK => CK);

    alu_right <= data_in;

    data_out <= alu_left when alu_sel = '1' else alu_right;

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
