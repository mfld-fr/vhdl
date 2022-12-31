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

	component sram is

		generic (
		    DW : positive;  -- data width
		    AW : positive   -- address width
		    );

		port (
		    D : inout std_logic_vector (DW-1 downto 0);
		    A : in std_logic_vector (AW-1 downto 0);

		    CS : in std_logic;  -- chip select (inverted)
		    OE : in std_logic;  -- output enable (inverted)
			WE : in std_logic   -- write enable (inverted)
		    );

	end component;
        
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
        "11110",  -- 1Eh -> 1Eh  INC A
        "11111"   -- 1Fh -> 1Fh  DEC A
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
    --          X           bus enable
    --           X          bus way (0: read, 1: write)
    --            XXX       ALU operation select (000: right, 001: left, 010: add, 011: sub, 100: inc, 101: dec)
    --               X      address source select (0: IP, 1: data pointer)
    --                X     IP next select (0: address + 1, 1: ALU ouput)
    --                 X    IP enable
    --                  X   next index select (0: step, 1: IR)
    --                   X  IR enable

    constant rom_step_0: ROM_STEP := (
        "00000000000000000" & "00001",  -- 00h  NOP instruction
        "00000001000000111" & "00001",  -- 01h  LD IR,(IP++) & decode instruction
        "10000001000000100" & "00001",  -- 02h  LD A,imm = LD A,(IP++)
        "00100001000000100" & "00001",  -- 03h  LD DP,imm = LD DP,(IP++)
        "10000001000010000" & "00001",  -- 04h  LD A,(DP)
        "00000001100110000" & "00001",  -- 05h  ST A,(DP)
        "00100001000000100" & "00101",  -- 06h  LD A,(addr) = LD DP,addr -> LD A,(DP)
        "00000000000000000" & "00000",  -- 07h
        "00100001000000100" & "00101",  -- 08h  ST A,(addr) = LD DP,addr -> ST A,(DP)
        "00000000000000000" & "00000",  -- 09h
        "00100001000010000" & "00001",  -- 0Ah  LD DP,(DP)
        "00100001000000100" & "01010",  -- 0Bh  LD DP,(addr) = LD DP,addr -> LD DP,(DP)
        "00000001000001100" & "00001",  -- 0Ch  JMP imm = LD IP,imm = LD IP,(IP++)
        "00000000000000000" & "00000",  -- 0Dh
        "10000001001000100" & "00001",  -- 0Eh  ADD A,imm
        "10000001001100100" & "00001",  -- 0Fh  SUB A,imm
        "00000000000000000" & "00000",  -- 10h
        "00100000000100000" & "00001",  -- 12h  MV DP,A
        "00000000000000000" & "00000",  -- 11h
        "00000000000101100" & "00001",  -- 13h  MV IP,A
        "10000010000000000" & "00001",  -- 14h  MV A,DP
        "10000110000000000" & "00001",  -- 15h  MV A,IP
        "01011000010100000" & "10111",  -- 16h  CALL imm = DEC SP...
        "00011101110010000" & "01100",  -- 17h  ...ST ++IP,(SP) -> JMP imm
        "00000000000000000" & "00000",  -- 18h
        "00000000000000000" & "00000",  -- 19h
        "00010001000011100" & "11011",  -- 1Ah  RET = LD IP,(SP)...
        "01011000010000000" & "00001",  -- 1Bh  ...INC SP
        "00000000000000000" & "00000",  -- 1Ch
        "00000000000000000" & "00000",  -- 1Dh
        "10000000010000000" & "00001",  -- 1Eh  INC A
        "10000000010100000" & "00001"   -- 1Fh  DEC A
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

    signal R : std_logic := '1';

    -- PHASE UNIT

    type phase_type is (prep, exec_1, exec_2, exec_3);
    signal phase : phase_type;

    signal prep_en : std_logic;
    signal exec_en : std_logic;

    -- PREPARE UNIT

    signal index_cur : INDEX;  -- current from index register
    signal index_ins : INDEX;  -- index from ROM_INDEX
    signal index_step : INDEX;  -- index from automaton step
    signal index_next : INDEX;  -- next index after selection
    
    signal index_sel : std_logic;  -- select index source (step or instruction register)

    signal step_cur : STEP;  -- step from ROM_STEP

    signal C : std_logic_vector (P - M - 1 downto 0);  -- control bus

    -- BUS UNIT

    signal addr_en : std_logic;  -- bus enable
    signal data_en : std_logic;  -- bus enable

    signal rd_bus : std_logic;   -- bus read (inverted)
    signal wr_bus : std_logic;   -- bus write (inverted)

    signal addr_bus : WORD;      -- address bus
    signal data_bus : WORD;      -- data bus

    signal bus_en : std_logic;   -- bus enable
    signal bus_way : std_logic;  -- bus way (0:read 1:write)

    -- EXECUTE UNIT

    signal data_in : WORD;     -- data input
    signal data_out : WORD;    -- data output

    signal ins_val : WORD;     -- instruction register current value
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

	-- MEMORY CHIP

	ram : sram
		generic map (DW => N, AW => N)
		port map (D => data_bus, A => addr_bus, CS => '0', OE => rd_bus, WE => wr_bus);

    -- PREPARE UNIT

    index_ins <= rom_index_0 (to_integer (unsigned (ins_val)));

    index_next <= index_ins when index_sel = '1' else index_step;

    index_reg: reg_w
        generic map (N => M)
        port map (I => index_next, O => index_cur, E => prep_en, R => R, CK => CK);

    step_cur <= rom_step_0 (to_integer (unsigned (index_cur)));

    index_step <= step_cur (M-1 downto 0);

    C <= step_cur (P-1 downto M);

    -- TODO: regroup enabled registers

    acc_en     <= C (16) and exec_en;
    sp_en      <= C (15) and exec_en;
    dp_en      <= C (14) and exec_en;
    ptr_sel    <= C (13);

    ir_en      <= C (0) and exec_en;
    index_sel  <= C (1);
    ip_en      <= C (2) and exec_en;
    ip_sel     <= C (3);
    addr_sel   <= C (4);
    alu_op     <= C (7 downto 5);
    bus_way    <= C (8);
    bus_en     <= C (9);
    right_sel  <= C (10);
    op_sel     <= C (11);
    left_sel   <= C (12);

    -- EXECUTE UNIT

    ins_reg: reg_w
        generic map (N => N)
        port map (I => data_in, O => ins_val, E => ir_en, R => R, CK => CK);

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

	acc_reg: reg_w
		generic map (N => N)
		port map (I => alu_val, O => acc_val, E => acc_en, R => R, CK => CK);

    op_val <= ip_val when op_sel = '1' else ptr_val;

    alu_left <= op_val when left_sel = '1' else acc_val;
    alu_right <= op_val when right_sel = '1' else data_in;

    -- TODO: replace arithmetic by logic for ALU

    alu_val <= alu_right when alu_op = "000"
        else alu_left when alu_op = "001"
        else std_logic_vector (unsigned (alu_left) + unsigned (alu_right)) when alu_op = "010"
        else std_logic_vector (unsigned (alu_left) - unsigned (alu_right)) when alu_op = "011"
        else std_logic_vector (unsigned (alu_left) + to_unsigned (1, N)) when alu_op = "100"
        else std_logic_vector (unsigned (alu_left) - to_unsigned (1, N)) when alu_op = "101";

    data_out <= alu_val;

	--- BUS UNIT

	addr_bus <= (WORD'range => 'Z') when addr_en = '0' else addr_val;

	data_in <= (WORD'range => '0') when data_en = '0'
		else data_bus when bus_way = '0';

	data_bus <= (WORD'range => 'Z') when data_en = '0'
		else data_out when bus_way = '1';

    -- PHASE UNIT

    phase_1: process (R, CK)
    begin
        if R = '1' then
            phase <= prep;

        elsif rising_edge(CK) then
            case phase is
                when prep =>
                    phase <= exec_1;
                when exec_1 =>
					if bus_en = '0' then
						phase <= prep;
					else
						phase <= exec_2;
					end if;
                when exec_2 =>
					if bus_way = '0' then
						phase <= prep;
					else
						phase <= exec_3;
					end if;
                when exec_3 =>
					phase <= prep;
            end case;
        end if;

    end process;

	prep_en <= '1' when phase = prep else '0';

	exec_en <= '1' when (phase = exec_1 and bus_en = '0')
		or (phase = exec_2 and bus_way = '0')
		or (phase = exec_3) else '0';

	addr_en <= '1' when (phase = exec_1 and bus_en = '1')
		or phase = exec_2 or phase = exec_3 else '0';

	data_en <= '1' when (phase = exec_1 and bus_way = '1')
		or phase = exec_2 or phase = exec_3 else '0';

	rd_bus <= '0' when phase = exec_2 and bus_way = '0' else '1';  -- inverted
	wr_bus <= '0' when phase = exec_2 and bus_way = '1' else '1';  -- inverted

	-- RESET & CLOCK

    reset_1: process
    begin
        wait for 10 ms;
        R <= '0';
		wait;
    end process;

    clock_1: process
    begin
        wait for 1 ms;
        CK <= '1' nand R;
        wait for 1 ms;
        CK <= '0';
    end process;

end architecture;
