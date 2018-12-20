library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity test_auto is

    generic (
        N : positive := 5;  -- word width
        M : positive := 5;  -- index width
        P : positive := 18  -- step width
        );

end entity;


architecture behavior of test_auto is

    subtype WORD is std_logic_vector (N-1 downto 0);

    type MEMORY is array (0 to 2**N - 1) of WORD;

    signal mem_0: MEMORY := (
        "00110",  -- 00h  LD A,(stack pointer)
        "11111",  -- 01h  ...
        "01111",  -- 02h  SUB A,1h
        "00001",  -- 03h  ...
        "00101",  -- 04h  ST A,(DP)
        "10010",  -- 05h  MV DP,A
        "10101",  -- 06h  MV A,IP
        "01110",  -- 07h  ADD A,5h
        "00101",  -- 08h  ...
        "00101",  -- 09h  ST A,(DP)
        "01100",  -- 0Ah  JMP 10h
        "10000",  -- 0Bh  ...
        "00000",  -- 0Ch  NOP
        "00000",  -- 0Dh  NOP
        "01100",  -- 0Eh  JMP 0h
        "00000",  -- 0Fh  ...
        "01001",  -- 10h  LD DP,(stack pointer)
        "11111",  -- 11h  ...
        "00100",  -- 12h  LD A,(DP)
        "00111",  -- 13h  ST A,(return address)
        "11110",  -- 14h  ...
        "00110",  -- 15h  LD A,(stack pointer)
        "11111",  -- 16h  ...
        "01110",  -- 17h  ADD A,1h
        "00001",  -- 18h  ...
        "00101",  -- 19h  ST A,(DP)
        "00110",  -- 1Ah  LD A,(return address)
        "11110",  -- 1Ah  ...
        "10011",  -- 1Ch  JMP A
        "00000",  -- 1Dh  DW 0h (stack)
        "00000",  -- 1Eh  DW 0h (return address)
        "11110"   -- 1Fh  DW 1Eh (stack pointer)
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
        "00000",  -- 16h -> 00h  NOP
        "00000",  -- 17h -> 00h  NOP
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

    --   CBA9876543210
    --   X                pointer value select (0: data pointer, 1: instruction pointer)
    --    X               ALU right operand select (0: data input, 1: pointer value)
    --     X              data read enable
    --      X             data write enable
    --       XX           ALU operation select (00: right, 01: left, 10: add, 11: sub)
    --         X          DP register input enable
    --          X         address source select (0: instruction pointer, 1: data pointer)
    --           X        accumulator input enable
    --            X       IP next value select (0: incremented address, 1: ALU ouput)
    --             X      IP register input enable
    --              X     next index select (0: step, 1: instruction register)
    --               X    instruction register input enable

    constant rom_step_0: ROM_STEP := (
        "001000000011100000",  -- 00h  load IR & increment IP / decode instruction
        "000000000000000000",  -- 01h
        "001000001010000000",  -- 02h  LD A,imm
        "001000100010000000",  -- 03h  LD DP,imm
        "001000011000000000",  -- 04h  LD A,(DP)
        "000101010000000000",  -- 05h  ST A,(DP)
        "001000100010000100",  -- 06h  LD A,(addr) = LD DP,addr / LD A,(DP)
        "000000000000000000",  -- 07h
        "001000100010000101",  -- 08h  ST A,(addr) = LD DP,addr / ST A,(DP)
        "000000000000000000",  -- 09h
        "001000110000000000",  -- 0Ah  LD DP,(DP)
        "001000100010001010",  -- 0Bh  LD DP,(addr) = LD DP,addr / LD DP,(DP)
        "001000000110000000",  -- 0Ch  JMP imm
        "000000000000000000",  -- 0Dh
        "001010001010000000",  -- 0Eh  ADD A,imm
        "001011001010000000",  -- 0Fh  SUB A,imm
        "000000000000000000",  -- 10h
        "000000000000000000",  -- 11h
        "000001100000000000",  -- 12h  MV DP,A
        "000001000110000000",  -- 13h  MV IP,A
        "010000001000000000",  -- 14h  MV A,DP
        "110000001000000000",  -- 15h  MV A,IP
        "000000000000000000",  -- 16h
        "000000000000000000",  -- 17h
        "000000000000000000",  -- 18h
        "000000000000000000",  -- 19h
        "000000000000000000",  -- 1Ah
        "000000000000000000",  -- 1Bh
        "000000000000000000",  -- 1Ch
        "000000000000000000",  -- 1Dh
        "000000000000000000",  -- 1Eh
        "000000000000000000"   -- 1Fh
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
    signal NCK : std_logic := '1';

    signal R : std_logic := '1';
    
    signal ins_val : WORD;

    signal index_cur : INDEX;  -- current from index register
    signal index_ins : INDEX;  -- index from ROM_INDEX
    signal index_step : INDEX;  -- index from automaton step
    signal index_next : INDEX;  -- next index after selection
    
    signal index_sel : std_logic;  -- select index source (step or instruction register)

    signal step_cur : STEP;  -- step from ROM_STEP

    signal C : std_logic_vector (P - M - 1 downto 0);  -- control bus

    signal data_in : WORD;  -- data bus input
    signal data_out : WORD;  -- data bus output
    signal rd_en : std_logic;  -- read enable
    signal wr_en : std_logic;  -- write enable

    signal ir_en : std_logic;  -- instruction register enable

    signal ip_next : WORD;     -- instruction pointer next value
    signal ip_val : WORD;     -- instruction pointer current value
    signal ip_sel : std_logic; -- instruction pointer next value select
    signal ip_en : std_logic;  -- instruction pointer input enable

    signal dp_val : WORD;  -- data pointer value
    signal dp_en : std_logic;  -- data pointer input enable

    signal addr_out : WORD;
    signal addr_next : WORD;  -- address next value (incremented)
    signal addr_sel : std_logic;  -- select address source

    signal ptr_val : WORD;  -- selected pointer value
    signal ptr_sel : std_logic;  -- pointer value select

    signal acc_en : std_logic;  -- accumulator enable

    signal alu_left : WORD;   -- ALU left operand value
    signal alu_right : WORD;  -- ALU right operand value
    signal right_sel : std_logic;  -- ALU right operand select

    signal alu_op : std_logic_vector (1 downto 0);  -- ALU operation select

begin

    NCK <= not CK;

    ins_reg: reg_logic
        generic map (N => N)
        port map (I => data_in, O => ins_val, E => ir_en, R => R, CK => CK);

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
    acc_en     <= C (4);
    addr_sel   <= C (5);
    dp_en      <= C (6);
    alu_op     <= C (8 downto 7);
    wr_en      <= C (9);
    rd_en      <= C (10);
    right_sel  <= C (11);
    ptr_sel    <= C (12);

    ip_next <= data_out when ip_sel = '1' else addr_next;

    ip_reg: reg_logic
        generic map (N => N)
        port map (I => ip_next, O => ip_val, E => ip_en, R => R, CK => CK);

    dp_reg: reg_logic
        generic map (N => N)
        port map (I => data_out, O => dp_val, E => dp_en, R => R, CK => CK);

    addr_out <= dp_val when addr_sel = '1' else ip_val;

    addr_next <= std_logic_vector (unsigned (addr_out) + to_unsigned (1, N));

    data_in <= mem_0 (to_integer (unsigned (addr_out)));

    ptr_val <= ip_val when ptr_sel = '1' else dp_val;

    acc_reg: reg_logic
        generic map (N => N)
        port map (I => data_out, O => alu_left, E => acc_en, R => R, CK => CK);

    alu_right <= ptr_val when right_sel = '1' else data_in;

    data_out <= alu_right when alu_op = "00"
        else alu_left when alu_op = "01"
        else std_logic_vector (unsigned (alu_left) + unsigned (alu_right)) when alu_op = "10"
        else std_logic_vector (unsigned (alu_left) - unsigned (alu_right)) when alu_op = "11";

    mem_0 (to_integer (unsigned (addr_out))) <= data_out when wr_en = '1' and rising_edge (CK);

    clock_1: process
    begin
        wait for 1 ns;
        CK <= '1' nand R;
        wait for 1 ns;
        CK <= '0';
    end process;

    reset_1: process
    begin
        wait for 10 ns;
        R <= '0';
        wait for 200 ns;
        R <= '1';
    end process;

end architecture;
