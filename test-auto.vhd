library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity test_auto is

    generic (
        N : positive := 5;  -- word width
        M : positive := 5;  -- index width
        P : positive := 24  -- step width
        );

end entity;


architecture behavior of test_auto is

    subtype WORD is std_logic_vector (N-1 downto 0);

    type MEMORY is array (0 to 2**N - 1) of WORD;

    signal mem_0: MEMORY := (
        "10110",  -- 00h  CALL 10h
        "10000",  -- 01h  ...
        "10110",  -- 02h  CALL 18h
        "11000",  -- 03h  ...
        "01100",  -- 04h  JMP 0h
        "00000",  -- 05h  ...
        "00000",  -- 06h  NOP
        "00000",  -- 07h  NOP
        "00000",  -- 08h  NOP
        "00000",  -- 09h  NOP
        "00000",  -- 0Ah  NOP
        "00000",  -- 0Bh  NOP
        "00000",  -- 0Ch  NOP
        "00000",  -- 0Dh  NOP
        "00000",  -- 0Eh  NOP
        "00000",  -- 0Fh  NOP
        "10111",  -- 10h  RET
        "00000",  -- 11h  NOP
        "00000",  -- 12h  NOP
        "00000",  -- 13h  NOP
        "00000",  -- 14h  NOP
        "00000",  -- 15h  NOP
        "00000",  -- 16h  NOP
        "00000",  -- 17h  NOP
        "10111",  -- 18h  RET
        "00000",  -- 19h  NOP
        "00000",  -- 1Ah  NOP
        "00000",  -- 1Ah  NOP
        "00000",  -- 1Ch  NOP
        "00000",  -- 1Dh  NOP
        "00000",  -- 1Eh  NOP
        "00000"   -- 1Fh  DW 0h (stack)
        );
        
    subtype INDEX is std_logic_vector (M-1 downto 0);
    type ROM_INDEX is array (0 to 2**N - 1) of INDEX;

    constant rom_index_0: ROM_INDEX := (
        "00000",  -- 00h -> 00h  NOP
        "00000",  -- 01h -> 00h  NOP
        "00010",  -- 02h -> 02h  LD A,imm
        "00011",  -- 03h -> 03h  LD DP,imm
        "00100",  -- 04h -> 04h  LD A,(DP)
        "00101",  -- 05h -> 05h  ST A,(DP)
        "00110",  -- 06h -> 06h  LD A,(addr)
        "01000",  -- 07h -> 08h  ST A,(addr)
        "01010",  -- 08h -> 0Ah  LD DP,(DP)
        "01011",  -- 09h -> 0Bh  LD DP,(addr)
        "00000",  -- 0Ah -> 00h  NOP
        "00000",  -- 0Bh -> 00h  NOP
        "01100",  -- 0Ch -> 0Ch  MOV IP,imm (= JMP imm)
        "00000",  -- 0Dh -> 00h  NOP
        "01110",  -- 0Eh -> 0Eh  ADD A,imm
        "01111",  -- 0Fh -> 0Fh  SUB A,imm
        "00000",  -- 10h -> 00h  NOP
        "00000",  -- 11h -> 00h  NOP
        "10010",  -- 12h -> 12h  MV DP,A
        "10011",  -- 13h -> 13h  MV IP,A (= JMP A)
        "10100",  -- 14h -> 14h  MV A,DP
        "10101",  -- 15h -> 15h  MV A,IP
        "10110",  -- 16h -> 16h  CALL imm
        "11010",  -- 17h -> 1Ah  RET
        "00000",  -- 18h -> 00h  NOP
        "00000",  -- 19h -> 00h  NOP
        "00000",  -- 1Ah -> 00h  NOP
        "00000",  -- 1Bh -> 00h  NOP
        "00000",  -- 1Ch -> 00h  NOP
        "00000",  -- 1Dh -> 00h  NOP
        "00000",  -- 1Eh -> 00h  NOP
        "00000"   -- 1Fh -> 00h  NOP
        );

    subtype STEP is std_logic_vector (P-1 downto 0);
    type ROM_STEP is array (0 to 2**M - 1) of STEP;

    --   210FEDCBA9876543210
    --   X                    ALU left operand select (0: accumulator, 1: pointer)
    --    X                   accumulator value select (0: A0, 1: A1)
    --     X                  A1 register input enable
    --      X                 pointer operand select (0: pointer value, 1: instruction pointer)
    --       X                SP register input enable
    --        X               pointer value select (0: data pointer, 1: stack pointer)
    --         X              ALU right operand select (0: data input, 1: pointer value)
    --          X             data read enable
    --           X            data write enable
    --            XXX         ALU operation select (000: right, 001: left, 010: add, 011: sub, 100: inc, 101: dec)
    --               X        DP register input enable
    --                X       address source select (0: instruction pointer, 1: pointer value)
    --                 X      A0 register input enable
    --                  X     IP next value select (0: incremented address, 1: data ouput)
    --                   X    IP register input enable
    --                    X   next index select (0: step, 1: instruction register)
    --                     X  IR register input enable

    constant rom_step_0: ROM_STEP := (
        "000000010000000011100000",  -- 00h  LD IR,(IP++) & decode instruction
        "000000000000000000000000",  -- 01h
        "000000010000001010000000",  -- 02h  LD A,imm = LD A,(IP++)
        "000000010000100010000000",  -- 03h  LD DP,imm = LD DP,(IP++)
        "000000010000011000000000",  -- 04h  LD A,(DP)
        "000000001001010000000000",  -- 05h  ST A,(DP)
        "000000010000100010000100",  -- 06h  LD A,(addr) = LD DP,addr -> LD A,(DP)
        "000000000000000000000000",  -- 07h
        "000000010000100010000101",  -- 08h  ST A,(addr) = LD DP,addr -> ST A,(DP)
        "000000000000000000000000",  -- 09h
        "000000010000110000000000",  -- 0Ah  LD DP,(DP)
        "000000010000100010001010",  -- 0Bh  LD DP,(addr) = LD DP,addr -> LD DP,(DP)
        "000000010000000110000000",  -- 0Ch  JMP imm = LD IP,imm = LD IP,(IP++)
        "000000000000000000000000",  -- 0Dh
        "000000010010001010000000",  -- 0Eh  ADD A,imm
        "000000010011001010000000",  -- 0Fh  SUB A,imm
        "000000000000000000000000",  -- 10h
        "000000000001100000000000",  -- 12h  MV DP,A
        "000000000000000000000000",  -- 11h
        "000000000001000110000000",  -- 13h  MV IP,A
        "000000100000001000000000",  -- 14h  MV A,DP
        "000100100000001000000000",  -- 15h  MV A,IP
        "100011000101000000010111",  -- 16h  CALL imm = DEC SP...
        "100101001100010000001100",  -- 17h  ...ST ++IP,(SP) -> JMP imm
        "000000000000000000000000",  -- 18h
        "000000000000000000000000",  -- 19h
        "000001010000010110011011",  -- 1Ah  RET = LD IP,(SP)...
        "100011000100000000000000",  -- 1Bh  ...INC SP
        "000000000000000000000000",  -- 1Ch
        "000000000000000000000000",  -- 1Dh
        "000000000000000000000000",  -- 1Eh
        "000000000000000000000000"   -- 1Fh
        );

    component reg_logic is

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
    signal NCK : std_logic;

    signal R : std_logic;

    -- CONTROL UNIT

    signal index_cur : INDEX;  -- current from index register
    signal index_ins : INDEX;  -- index from ROM_INDEX
    signal index_step : INDEX;  -- index from automaton step
    signal index_next : INDEX;  -- next index after selection
    
    signal index_sel : std_logic;  -- select index source (step or instruction register)

    signal step_cur : STEP;  -- step from ROM_STEP

    signal C : std_logic_vector (P - M - 1 downto 0);  -- control bus

    -- EXECUTIVE UNIT

    signal addr_out : WORD;      -- address bus out
    signal addr_en : std_logic;  -- address enable

    signal data_in : WORD;       -- data bus input
    signal data_val : WORD;      -- data bus input
    signal data_out : WORD;      -- data bus output
    signal rd_en : std_logic;    -- read enable
    signal wr_en : std_logic;    -- write enable

    signal ins_val : WORD;
    signal ir_en : std_logic;  -- instruction register enable

    signal ip_next : WORD;     -- instruction pointer next value
    signal ip_val : WORD;      -- instruction pointer current value
    signal ip_sel : std_logic; -- instruction pointer next value select
    signal ip_en : std_logic;  -- instruction pointer input enable

    signal sp_val : WORD;      -- stack pointer value
    signal dp_val : WORD;      -- data pointer value
    signal sp_en : std_logic;  -- stack pointer input enable
    signal dp_en : std_logic;  -- data pointer input enable

    signal ptr_val : WORD;       -- pointer register value
    signal ptr_sel : std_logic;  -- pointer register value select

    signal addr_val : WORD;       -- address current value
    signal addr_next : WORD;      -- address next value (incremented)
    signal addr_sel : std_logic;  -- select address ouput source

    signal op_val : WORD;         -- pointer operand value
    signal op_sel : std_logic;    -- pointer operand select

    signal a0_en : std_logic;     -- accumulator A0 enable
    signal a1_en : std_logic;     -- accumulator A1 enable
    signal a0_val : WORD;         -- accumulator A0 value
    signal a1_val : WORD;         -- accumulator A1 value
    signal acc_val : WORD;        -- accumulator value
    signal acc_sel : std_logic;   -- accumulor select

    signal alu_left : WORD;        -- ALU left operand value
    signal alu_right : WORD;       -- ALU right operand value
    signal alu_val : WORD;         -- ALU result value
    signal left_sel : std_logic;   -- ALU left operand select
    signal right_sel : std_logic;  -- ALU right operand select

    signal alu_op : std_logic_vector (2 downto 0);  -- ALU operation select

begin

    NCK <= not CK;

    -- CONTROL UNIT

    index_ins <= rom_index_0 (to_integer (unsigned (ins_val)));

    index_next <= index_ins when index_sel = '1' else index_step;

    index_reg: reg_logic
        generic map (N => M)
        port map (I => index_next, O => index_cur, E => '1', R => R, CK => NCK);

    step_cur <= rom_step_0 (to_integer (unsigned (index_cur)));

    index_step <= step_cur (M-1 downto 0);

    C <= step_cur (P-1 downto M);

    ir_en      <= C (0);
    index_sel  <= C (1);
    ip_en      <= C (2);
    ip_sel     <= C (3);
    a0_en      <= C (4);
    addr_sel   <= C (5);
    dp_en      <= C (6);
    alu_op     <= C (9 downto 7);
    wr_en      <= C (10);
    rd_en      <= C (11) and NCK;
    right_sel  <= C (12);
    ptr_sel    <= C (13);
    sp_en      <= C (14);
    op_sel     <= C (15);
    a1_en      <= C (16);
    acc_sel    <= C (17);
    left_sel   <= C (18);

    -- EXECUTIVE UNIT

    ins_reg: reg_logic
        generic map (N => N)
        port map (I => data_val, O => ins_val, E => ir_en, R => R, CK => CK);

    ip_next <= alu_val when ip_sel = '1' else addr_next;

    ip_reg: reg_logic
        generic map (N => N)
        port map (I => ip_next, O => ip_val, E => ip_en, R => R, CK => CK);

    dp_reg: reg_logic
        generic map (N => N)
        port map (I => alu_val, O => dp_val, E => dp_en, R => R, CK => CK);

    sp_reg: reg_logic
        generic map (N => N)
        port map (I => alu_val, O => sp_val, E => sp_en, R => R, CK => CK);

    ptr_val <= sp_val when ptr_sel = '1' else dp_val;

    addr_val <= ptr_val when addr_sel = '1' else ip_val;

    addr_next <= std_logic_vector (unsigned (addr_val) + to_unsigned (1, N));

    addr_en <= wr_en or rd_en;

    addr_out <= addr_val; -- when addr_en = '1' else (addr_out'range => 'Z');

    data_in <= mem_0 (to_integer (unsigned (addr_out))) when rd_en = '1' else (data_in'range => 'Z');

    data_val <= data_in when rd_en = '1' else (data_val'range => 'U');

    a0_reg: reg_logic
        generic map (N => N)
        port map (I => alu_val, O => a0_val, E => a0_en, R => R, CK => CK);

    a1_reg: reg_logic
        generic map (N => N)
        port map (I => alu_val, O => a1_val, E => a1_en, R => R, CK => CK);

    acc_val <= a1_val when acc_sel = '1' else a0_val;

    op_val <= ip_val when op_sel = '1' else ptr_val;

    alu_left <= op_val when left_sel = '1' else acc_val;
    alu_right <= op_val when right_sel = '1' else data_val;

    alu_val <= alu_right when alu_op = "000"
        else alu_left when alu_op = "001"
        else std_logic_vector (unsigned (alu_left) + unsigned (alu_right)) when alu_op = "010"
        else std_logic_vector (unsigned (alu_left) - unsigned (alu_right)) when alu_op = "011"
        else std_logic_vector (unsigned (alu_left) + to_unsigned (1, N)) when alu_op = "100"
        else std_logic_vector (unsigned (alu_left) - to_unsigned (1, N)) when alu_op = "101";

    data_out <= alu_val when wr_en = '1' else (data_out'range => 'Z');

    mem_0 (to_integer (unsigned (addr_out))) <= data_out when wr_en = '1' and rising_edge (CK);

    reset_1: process
    begin
        R <= '1';
        wait for 10 ns;
        R <= '0';
        wait for 1000 ns;
    end process;

    clock_1: process
    begin
        wait for 1 ns;
        CK <= '1' nand R;
        wait for 1 ns;
        CK <= '0';
    end process;


end architecture;
