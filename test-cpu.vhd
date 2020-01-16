library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity test_cpu is

    generic (
        N : positive := 5;  -- word width
        M : positive := 5;  -- index width
        P : positive := 22  -- step width
        );

end entity;


architecture behavior of test_cpu is

    subtype WORD is std_logic_vector (N-1 downto 0);

    type MEMORY is array (0 to 2**N - 1) of WORD;

    signal mem_0: MEMORY := (
        "00011",  -- 00h  LD DP,1Dh
        "11101",  -- 01h  ...
        "10110",  -- 02h  CALL 10h
        "10000",  -- 03h  ...
        "00011",  -- 04h  LD DP,1Eh
        "11110",  -- 05h  ...
        "10110",  -- 06h  CALL 18h
        "11000",  -- 07h  ...
        "01100",  -- 08h  JMP 0h
        "00000",  -- 09h  ...
        "00000",  -- 0Ah  NOP
        "00000",  -- 0Bh  NOP
        "00000",  -- 0Ch  NOP
        "00000",  -- 0Dh  NOP
        "00000",  -- 0Eh  NOP
        "00000",  -- 0Fh  NOP
        "00100",  -- 10h  LD A,(DP)
        "00000",  -- 11h  INC A ???
        "00101",  -- 12h  ST A,(DP)
        "10111",  -- 13h  RET
        "00000",  -- 14h  NOP
        "00000",  -- 15h  NOP
        "00000",  -- 16h  NOP
        "00000",  -- 17h  NOP
        "00100",  -- 18h  LD A,(DP)
        "00000",  -- 19h  DEC A ???
        "00101",  -- 1Ah  ST A,(DP)
        "10111",  -- 1Bh  RET
        "00000",  -- 1Ch  NOP
        "00000",  -- 1Dh  DW 0h (count 1)
        "00000",  -- 1Eh  DW 0h (count 2)
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
        "01100",  -- 0Ch -> 0Ch  LD IP,imm (= JMP imm)
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

    --   0FEDCBA9876543210
    --   X                  A enable
    --    X                 SP enable
    --     X                DP enable
    --      X               pointer select (0: DP, 1: SP)
    --       X              ALU left select (0: accumulator, 1: pointer)
    --        X             operand select (0: data pointer, 1: IP)
    --         X            ALU right select (0: data input, 1: pointer value)
    --          X           data read enable
    --           X          data write enable
    --            XXX       ALU operation select (000: right, 001: left, 010: add, 011: sub, 100: inc, 101: dec)
    --               X      address source select (0: IP, 1: data pointer)
    --                X     IP next select (0: address + 1, 1: ALU ouput)
    --                 X    IP enable
    --                  X   next index select (0: step, 1: IR)
    --                   X  IR enable

    constant rom_step_0: ROM_STEP := (
        "00000001000000111" & "00000",  -- 00h  LD IR,(IP++) & decode instruction
        "00000000000000000" & "00000",  -- 01h
        "10000001000000100" & "00000",  -- 02h  LD A,imm = LD A,(IP++)
        "00100001000000100" & "00000",  -- 03h  LD DP,imm = LD DP,(IP++)
        "10000001000010000" & "00000",  -- 04h  LD A,(DP)
        "00000000100110000" & "00000",  -- 05h  ST A,(DP)
        "00100001000000100" & "00100",  -- 06h  LD A,(addr) = LD DP,addr -> LD A,(DP)
        "00000000000000000" & "00000",  -- 07h
        "00100001000000100" & "00101",  -- 08h  ST A,(addr) = LD DP,addr -> ST A,(DP)
        "00000000000000000" & "00000",  -- 09h
        "00100001000010000" & "00000",  -- 0Ah  LD DP,(DP)
        "00100001000000100" & "01010",  -- 0Bh  LD DP,(addr) = LD DP,addr -> LD DP,(DP)
        "00000001000001100" & "00000",  -- 0Ch  JMP imm = LD IP,imm = LD IP,(IP++)
        "00000000000000000" & "00000",  -- 0Dh
        "10000001001000100" & "00000",  -- 0Eh  ADD A,imm
        "10000001001100100" & "00000",  -- 0Fh  SUB A,imm
        "00000000000000000" & "00000",  -- 10h
        "00100000000100000" & "00000",  -- 12h  MV DP,A
        "00000000000000000" & "00000",  -- 11h
        "00000000000101100" & "00000",  -- 13h  MV IP,A
        "10000010000000000" & "00000",  -- 14h  MV A,DP
        "10000110000000000" & "00000",  -- 15h  MV A,IP
        "01011000010100000" & "10111",  -- 16h  CALL imm = DEC SP...
        "00011100110010000" & "01100",  -- 17h  ...ST ++IP,(SP) -> JMP imm
        "00000000000000000" & "00000",  -- 18h
        "00000000000000000" & "00000",  -- 19h
        "00010001000011100" & "11011",  -- 1Ah  RET = LD IP,(SP)...
        "01011000010000000" & "00000",  -- 1Bh  ...INC SP
        "00000000000000000" & "00000",  -- 1Ch
        "00000000000000000" & "00000",  -- 1Dh
        "00000000000000000" & "00000",  -- 1Eh
        "00000000000000000" & "00000"   -- 1Fh
        );

    component reg_w is

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

    signal R : std_logic := '1';

    -- CONTROL UNIT

    signal index_cur : INDEX;  -- current from index register
    signal index_ins : INDEX;  -- index from ROM_INDEX
    signal index_step : INDEX;  -- index from automaton step
    signal index_next : INDEX;  -- next index after selection
    
    signal index_sel : std_logic;  -- select index source (step or instruction register)

    signal step_cur : STEP;  -- step from ROM_STEP

    signal C : std_logic_vector (P - M - 1 downto 0);  -- control bus

    -- EXECUTIVE UNIT

    signal addr_out : WORD;  -- address bus
    signal addr_en : std_logic;  -- address enable

    signal data_in : WORD;       -- data bus input
    signal data_val : WORD;      -- data bus input
    signal data_out : WORD;      -- data bus output
    signal rd_en : std_logic;    -- read enable
    signal wr_en : std_logic;    -- write enable
	signal rd_o  : std_logic;    -- read output strobe
	signal rd_i  : std_logic;    -- read input strobe

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

    signal acc_en  : std_logic;   -- accumulator A enable
    signal acc_val : WORD;        -- accumulator A value

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

    index_reg: reg_w
        generic map (N => M)
        port map (I => index_next, O => index_cur, E => '1', R => R, CK => NCK);

    step_cur <= rom_step_0 (to_integer (unsigned (index_cur)));

    index_step <= step_cur (M-1 downto 0);

    C <= step_cur (P-1 downto M);

    acc_en     <= C (16);
    sp_en      <= C (15);
    dp_en      <= C (14);
    ptr_sel    <= C (13); -- TODO: invert DP & SP

    ir_en      <= C (0);
    index_sel  <= C (1);
    ip_en      <= C (2);
    ip_sel     <= C (3);
    addr_sel   <= C (4);
    alu_op     <= C (7 downto 5);
    wr_en      <= C (8);
    rd_en      <= C (9) and NCK;
    right_sel  <= C (10);
    op_sel     <= C (11);
    left_sel   <= C (12);

    -- EXECUTIVE UNIT

    ins_reg: reg_w
        generic map (N => N)
        port map (I => data_val, O => ins_val, E => ir_en, R => R, CK => CK);

    ip_next <= alu_val when ip_sel = '1' else addr_next;

    ip_reg: reg_w
        generic map (N => N)
        port map (I => ip_next, O => ip_val, E => ip_en, R => R, CK => CK);

    dp_reg: reg_w
        generic map (N => N)
        port map (I => alu_val, O => dp_val, E => dp_en, R => R, CK => CK);

    sp_reg: reg_w
        generic map (N => N)
        port map (I => alu_val, O => sp_val, E => sp_en, R => R, CK => CK);

    ptr_val <= sp_val when ptr_sel = '1' else dp_val;

    addr_val <= ptr_val when addr_sel = '1' else ip_val;

	addr_next <= std_logic_vector (unsigned (addr_val) + to_unsigned (1, N));

	addr_en <= wr_en or rd_en;

	addr_out <= addr_val when addr_en = '1' else (WORD'range => 'Z');

	-- asynchronous RAM timing when reading

	process (R, rd_en)
	begin
		if R = '1' or rd_en = '0' then
			rd_o <= '0';
			rd_i <= '0';
		else
			rd_o <= '1' after 100 us;
			rd_i <= '1' after 200 us;
		end if;
	end process;

	data_in <= mem_0 (to_integer (unsigned (addr_out))) when rd_o = '1' else (WORD'range => 'Z');

	data_val <= data_in when rd_i = '1';  -- infered latch

	acc_reg: reg_w
		generic map (N => N)
		port map (I => alu_val, O => acc_val, E => acc_en, R => R, CK => CK);

    op_val <= ip_val when op_sel = '1' else ptr_val;

    alu_left <= op_val when left_sel = '1' else acc_val;
    alu_right <= op_val when right_sel = '1' else data_val;

    alu_val <= alu_right when alu_op = "000"
        else alu_left when alu_op = "001"
        else std_logic_vector (unsigned (alu_left) + unsigned (alu_right)) when alu_op = "010"
        else std_logic_vector (unsigned (alu_left) - unsigned (alu_right)) when alu_op = "011"
        else std_logic_vector (unsigned (alu_left) + to_unsigned (1, N)) when alu_op = "100"
        else std_logic_vector (unsigned (alu_left) - to_unsigned (1, N)) when alu_op = "101";

    data_out <= alu_val when wr_en = '1' else (WORD'range => 'Z');

    mem_0 (to_integer (unsigned (addr_out))) <= data_out when wr_en = '1' and rising_edge (CK);

    reset_1: process
    begin
        wait for 10 ms;
        R <= '0';
    end process;

    clock_1: process
    begin
        wait for 1 ms;
        CK <= '1' nand R;
        wait for 1 ms;
        CK <= '0';
    end process;


end architecture;
