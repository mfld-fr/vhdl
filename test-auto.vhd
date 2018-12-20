library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity test_auto is

    generic (
        N : positive := 4;  -- word width
        M : positive := 5;  -- index width
        P : positive := 16  -- step width
        );

end entity;


architecture behavior of test_auto is

    subtype WORD is std_logic_vector (N-1 downto 0);

    type MEMORY is array (0 to 2**N - 1) of WORD;

    signal mem_0: MEMORY := (
        "0010",  -- 0h  LD A,...
        "1000",  -- 1h  ...8h
        "0111",  -- 2h  ST A,...
        "1111",  -- 3h  ...(Fh)
        "0011",  -- 4h  LD DP,...
        "1110",  -- 5h  ...Eh
        "1000",  -- 6h  LD DP,(DP)
        "0100",  -- 7h  LD A,(DP)
        "1110",  -- 8h  ADD A,...
        "0001",  -- 9h  ...1h
        "0101",  -- Ah  ST A,(DP)
        "1100",  -- Bh  JMP...
        "0100",  -- Ch  ...4h
        "0000",  -- Dh
        "1111",  -- Eh  DW Fh
        "0000"   -- Fh  DW 0h
        );
        
    subtype INDEX is std_logic_vector (M-1 downto 0);
    type ROM_INDEX is array (0 to 2**N - 1) of INDEX;

    constant rom_index_0: ROM_INDEX := (
        "00000",  -- 0h -> 00h NOP
        "00000",  -- 1h -> 00h NOP
        "00010",  -- 2h -> 02h LD A,imm
        "00011",  -- 3h -> 03h LD DP,imm
        "00100",  -- 4h -> 04h LD A,(DP)
        "00101",  -- 5h -> 05h ST A,(DP)
        "00110",  -- 6h -> 06h LD A,(addr)
        "01000",  -- 7h -> 08h ST A,(addr)
        "01010",  -- 8h -> 0Ah LD DP,(DP)
        "00000",  -- 9h -> 00h NOP
        "00000",  -- Ah -> 00h NOP
        "00000",  -- Bh -> 00h NOP
        "01100",  -- Ch -> 0Ch JMP imm
        "00000",  -- Dh -> 00h NOP
        "01110",  -- Eh -> 0Eh ADD A,imm
        "01111"   -- Fh -> 0Fh SUB A,imm
        );

    subtype STEP is std_logic_vector (P-1 downto 0);
    type ROM_STEP is array (0 to 2**M - 1) of STEP;

    --   A9876543210
    --   X               data read enable
    --    X              data write enable
    --     XX            ALU operation select (00: right, 01: left, 10: add, 11: sub)
    --       X           DP register input enable
    --        X          address source select (0: instruction pointer, 1: data pointer)
    --         X         accumulator input enable
    --          X        IP next value select (0: incremented address, 1: data input)
    --           X       IP register input enable
    --            X      next index select (0: step, 1: instruction register)
    --             X     instruction register input enable

    constant rom_step_0: ROM_STEP := (
        "1000000011100000",  -- 00h  load IR & increment IP / decode instruction
        "0000000000000000",  -- 01h
        "1000001010000000",  -- 02h  LD A,imm
        "1000100010000000",  -- 03h  LD DP,imm
        "1000011000000000",  -- 04h  LD A,(DP)
        "0101010000000000",  -- 05h  ST A,(DP)
        "1000100010000100",  -- 06h  LD A,(addr) = LD DP,addr / LD A,(DP)
        "0000000000000000",  -- 07h
        "1000100010000101",  -- 08h  ST A,(addr) = LD DP,addr / ST A,(DP)
        "0000000000000000",  -- 09h
        "1000110000000000",  -- 0Ah  LD DP,(DP)
        "0000000000000000",  -- 0Bh
        "1000000110000000",  -- 0Ch  JMP imm
        "0000000000000000",  -- 0Dh
        "1010001010000000",  -- 0Eh  ADD A,imm
        "1011001010000000",  -- 0Fh  SUB A,imm
        "0000000000000000",  -- 10h
        "0000000000000000",  -- 11h
        "0000000000000000",  -- 12h
        "0000000000000000",  -- 13h
        "0000000000000000",  -- 14h
        "0000000000000000",  -- 15h
        "0000000000000000",  -- 16h
        "0000000000000000",  -- 17h
        "0000000000000000",  -- 18h
        "0000000000000000",  -- 19h
        "0000000000000000",  -- 1Ah
        "0000000000000000",  -- 1Bh
        "0000000000000000",  -- 1Ch
        "0000000000000000",  -- 1Dh
        "0000000000000000",  -- 1Eh
        "0000000000000000"   -- 1Fh
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

    signal acc_en : std_logic;  -- accumulator enable

    signal alu_left : WORD;   -- ALU left value
    signal alu_right : WORD;  -- ALU right value
    
    signal alu_sel : std_logic_vector (1 downto 0);  -- ALU operation select

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
    alu_sel    <= C (8 downto 7);
    wr_en      <= C (9);
    rd_en      <= C (10);

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

    acc_reg: reg_logic
        generic map (N => N)
        port map (I => data_out, O => alu_left, E => acc_en, R => R, CK => CK);

    alu_right <= data_in;

    data_out <= alu_right when alu_sel = "00"
        else alu_left when alu_sel = "01"
        else std_logic_vector (unsigned (alu_left) + unsigned (alu_right)) when alu_sel = "10"
        else std_logic_vector (unsigned (alu_left) - unsigned (alu_right)) when alu_sel = "11";

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
