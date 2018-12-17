library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity test_auto is

    generic (
        N : positive := 4;
        P : positive := 13
        );

end test_auto;


architecture behavior of test_auto is

    subtype WORD is std_logic_vector (N-1 downto 0);

    subtype INDEX is std_logic_vector (N-1 downto 0);
    subtype STEP is std_logic_vector (P-1 downto 0);

    type ROM_STEP is array (0 to 2**N - 1) of STEP;

    --   X             data write enable
    --    X            ALU operation select (0: right, 1: left)
    --     X           DP register input enable
    --      X          address source select (0: instruction pointer, 1: data pointer)
    --       X         accumulator input enable
    --        X        IP next value select (0: incremented address, 1: data input)
    --         X       IP register input enable
    --          X      next index select (0: step, 1: instruction register)
    --           X     instruction register input enable

    constant rom_step_0: ROM_STEP := (
        "0000001010001",  -- 0h  load IR & increment IP
        "0000000100000",  -- 1h  decode instruction
        "0000000000000",  -- 2h
        "0000000000000",  -- 3h
        "0000101000000",  -- 4h  LD A,immediate
        "0010001000000",  -- 5h  LD DP,immediate
        "0000000000000",  -- 6h
        "0000000000000",  -- 7h
        "0001100000000",  -- 8h  LD A,(DP)
        "1101000000000",  -- 9h  ST (DP),A
        "0000000000000",  -- Ah
        "0000000000000",  -- Bh
        "0000011000000",  -- Ch  JMP immediate
        "0000000000000",  -- Dh
        "0000000000000",  -- Eh
        "0000000000000"   -- Fh  NOP
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
        "1001",  -- 7h  ST A,(DP)
        "0100",  -- 8h  LD A,...
        "0010",  -- 9h  ...2h
        "1000",  -- Ah  LD A,(DP)
        "1100",  -- Bh  JMP...
        "0000",  -- Ch  ...0h
        "0000",  -- Dh
        "0011",  -- Eh  DB 3h
        "0000"   -- Fh  DB 0h
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
    signal rd_en : std_logic;  -- read enable
    signal wr_en : std_logic;  -- write enable

    signal ins_reg_en : std_logic;  -- instruction register enable

    signal addr_next : WORD;  -- address next value (incremented)

    signal ip_next : WORD;     -- instruction pointer next value
    signal ip_val : WORD;     -- instruction pointer current value
    signal ip_sel : std_logic; -- instruction pointer next value select
    signal ip_en : std_logic;  -- instruction pointer input enable

    signal dp_val : WORD;  -- data pointer value
    signal dp_en : std_logic;  -- data pointer input enable

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
    ip_en      <= C (2);
    ip_sel     <= C (3);
    acc_en     <= C (4);
    addr_sel   <= C (5);
    dp_en      <= C (6);
    alu_sel    <= C (7);
    wr_en      <= C (8);

    ip_next <= data_in when ip_sel = '1' else addr_next;

    ip_reg: reg_flip_flop
        generic map (N => N)
        port map (I => ip_next, O => ip_val, E => ip_en, R => R, CK => CK);

    dp_reg: reg_flip_flop
        generic map (N => N)
        port map (I => data_in, O => dp_val, E => dp_en, R => R, CK => CK);

    addr_out <= dp_val when addr_sel = '1' else ip_val;

    addr_next <= std_logic_vector (unsigned (addr_out) + to_unsigned (1, N));

    data_in <= ram_prog_0 (to_integer (unsigned (addr_out)));

    reg_acc: reg_flip_flop
        generic map (N => N)
        port map (I => data_out, O => alu_left, E => acc_en, R => R, CK => CK);

    alu_right <= data_in;

    data_out <= alu_left when alu_sel = '1' else alu_right;

    ram_prog_0 (to_integer (unsigned (addr_out))) <= data_out when wr_en = '1';

    clock_1: process
    begin
        wait for 1 ns;
        CK <= '1' nand R;
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
