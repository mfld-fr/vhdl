library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity test_cpu is

    generic (
        N : positive := 8;  -- data word width
        W : positive := 6;  -- instruction index width
        M : positive := 5;  -- step index width
        P : positive := 27  -- step word width
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
    type ROM_INDEX is array (0 to 2**W - 1) of INDEX;

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
        "11111",  -- 1Fh -> 1Fh  DEC A
        "00000",  -- 20h -> 00h  NOP
        "00000",  -- 21h -> 00h  NOP
        "00000",  -- 22h -> 00h  NOP
        "00000",  -- 23h -> 00h  NOP
        "00000",  -- 24h -> 00h  NOP
        "00000",  -- 25h -> 00h  NOP
        "00000",  -- 26h -> 00h  NOP
        "00000",  -- 27h -> 00h  NOP
        "00000",  -- 28h -> 00h  NOP
        "00000",  -- 29h -> 00h  NOP
        "00000",  -- 2Ah -> 00h  NOP
        "00000",  -- 2Bh -> 00h  NOP
        "00000",  -- 2Ch -> 00h  NOP
        "00000",  -- 2Dh -> 00h  NOP
        "00000",  -- 2Eh -> 00h  NOP
        "00000",  -- 2Fh -> 00h  NOP
        "00000",  -- 30h -> 00h  NOP
        "00000",  -- 31h -> 00h  NOP
        "00000",  -- 32h -> 00h  NOP
        "00000",  -- 33h -> 00h  NOP
        "00000",  -- 34h -> 00h  NOP
        "00000",  -- 35h -> 00h  NOP
        "00000",  -- 36h -> 00h  NOP
        "00000",  -- 37h -> 00h  NOP
        "00000",  -- 38h -> 00h  NOP
        "00000",  -- 39h -> 00h  NOP
        "00000",  -- 3Ah -> 00h  NOP
        "00000",  -- 3Bh -> 00h  NOP
        "00000",  -- 3Ch -> 00h  NOP
        "00000",  -- 3Dh -> 00h  NOP
        "00000",  -- 3Eh -> 00h  NOP
        "00000"   -- 3Fh -> 00h  NOP
        );

    subtype STEP is std_logic_vector (P-1 downto 0);
    type ROM_STEP is array (0 to 2**M - 1) of STEP;

    --   10 9876 54 32109876543210
    --   XX                         constant select (00: +0, 01: data register, 10: +1, 11: -1)
    --      X                       A enable
    --       X                      SP enable
    --        X                     DP enable
    --         X                    pointer select (0: DP, 1: SP)
    --           XX                 register select (00: DP, 01: SP)
    --              X               ALU left select (0: accumulator, 1: pointer)
    --               X              operand select (0: data pointer, 1: IP)
    --                X             ALU right select (0: data input, 1: operand)
    --                 X            data out select (0: ALU output, 1: ALU right)
    --                  X           bus enable
    --                   X          bus way (0: read, 1: write)
    --                    XXX       ALU operation select (000: ADD, 001: xxx, 010: SUB, 011: xxx, 100: xxx, 101: xxx)
    --                       X      address source select (0: IP, 1: data pointer)
    --                        X     IP next select (0: address + 1, 1: ALU ouput)
    --                         X    IP enable
    --                          X   next index select (0: step, 1: IR)
    --                           X  IR enable

    constant rom_step_0: ROM_STEP := (
        std_logic_vector'("00"&"0000"&"00"&"00000000000000" & "00001"),  -- 00h  INIT instruction
        std_logic_vector'("01"&"0000"&"00"&"00011000000111" & "00001"),  -- 01h  LD IR,(IP++) & decode instruction
        std_logic_vector'("01"&"1000"&"00"&"00011000000100" & "00001"),  -- 02h  LD A,imm = LD A,(IP++)
        std_logic_vector'("01"&"0010"&"00"&"00011000000100" & "00001"),  -- 03h  LD DP,imm = LD DP,(IP++)
        std_logic_vector'("01"&"1000"&"00"&"00011000010000" & "00001"),  -- 04h  LD A,(DP)
        std_logic_vector'("00"&"0000"&"00"&"00001100010000" & "00001"),  -- 05h  ST A,(DP) with transparent ADD A,0
        std_logic_vector'("01"&"0010"&"00"&"00011000000100" & "00100"),  -- 06h  LD A,(addr) = LD DP,addr -> LD A,(DP)
        std_logic_vector'("00"&"0000"&"00"&"00000000000000" & "00000"),  -- 07h
        std_logic_vector'("01"&"0010"&"00"&"00011000000100" & "00101"),  -- 08h  ST A,(addr) = LD DP,addr -> ST A,(DP)
        std_logic_vector'("00"&"0000"&"00"&"00000000000000" & "00000"),  -- 09h
        std_logic_vector'("01"&"0010"&"00"&"00011000010000" & "00001"),  -- 0Ah  LD DP,(DP)
        std_logic_vector'("01"&"0010"&"00"&"00011000000100" & "01010"),  -- 0Bh  LD DP,(addr) = LD DP,addr -> LD DP,(DP)
        std_logic_vector'("01"&"0000"&"00"&"00011000001100" & "00001"),  -- 0Ch  JMP imm = LD IP,(IP)
        std_logic_vector'("00"&"0000"&"00"&"00000000000000" & "00000"),  -- 0Dh
        std_logic_vector'("01"&"1000"&"00"&"00001000000100" & "00001"),  -- 0Eh  ADD A,imm
        std_logic_vector'("01"&"1000"&"00"&"00001001000100" & "00001"),  -- 0Fh  SUB A,imm
        std_logic_vector'("00"&"0000"&"00"&"00000000000000" & "00000"),  -- 10h
        std_logic_vector'("00"&"0010"&"00"&"00000000000000" & "00001"),  -- 12h  MV DP,A with transparent ADD A,0
        std_logic_vector'("00"&"0000"&"00"&"00000000000000" & "00000"),  -- 11h
        std_logic_vector'("00"&"0000"&"00"&"00000000001100" & "00001"),  -- 13h  MV IP,A with transparent ADD A,0
        std_logic_vector'("00"&"1000"&"00"&"00110000000000" & "00001"),  -- 14h  MV A,DP
        std_logic_vector'("00"&"1000"&"00"&"01110000000000" & "00001"),  -- 15h  MV A,IP
        std_logic_vector'("10"&"0100"&"01"&"10001001000100" & "10111"),  -- 16h  CALL imm = LD DR,imm & DEC SP...
        std_logic_vector'("00"&"0001"&"01"&"01111100010000" & "11000"),  -- 17h  ...ST IP,(SP)...
        std_logic_vector'("01"&"0000"&"00"&"00010000001100" & "00001"),  -- 18h  ...LD IP,DR
        std_logic_vector'("00"&"0000"&"00"&"00000000000000" & "00000"),  -- 19h
        std_logic_vector'("01"&"0001"&"00"&"00011000011100" & "11011"),  -- 1Ah  RET = LD IP,(SP)...
        std_logic_vector'("10"&"0100"&"01"&"10000000000000" & "00001"),  -- 1Bh  ...INC SP = ADD SP,1
        std_logic_vector'("00"&"0000"&"00"&"00000000000000" & "00000"),  -- 1Ch
        std_logic_vector'("00"&"0000"&"00"&"00000000000000" & "00000"),  -- 1Dh
        std_logic_vector'("10"&"1000"&"00"&"00000000000000" & "00001"),  -- 1Eh  INC A = ADD A,1
        std_logic_vector'("10"&"1000"&"00"&"00000001000000" & "00001")   -- 1Fh  DEC A = SUB A,1
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

    -- CONTROL UNIT

    type control_step is (control_prep, control_exec);
    signal control_now : control_step;

    signal prep_en : std_logic;
    signal exec_en : std_logic;

    -- PREPARE UNIT

    signal ir_index : std_logic_vector (W - 1 downto 0);  -- instruction index

    signal index_cur : INDEX;  -- current from index register
    signal index_ins : INDEX;  -- index from ROM_INDEX
    signal index_step : INDEX;  -- index from automaton step
    signal index_next : INDEX;  -- next index after selection
    
    signal index_sel : std_logic;  -- select index source (step or instruction register)

    signal step_cur : STEP;  -- step from ROM_STEP

    signal C : std_logic_vector (P - M - 1 downto 0);  -- control bus

    -- BUS UNIT

    type bus_step is (bus_step1, bus_step2, bus_step3);
    signal bus_now : bus_step;

    signal addr_en : std_logic;  -- bus enable
    signal data_en : std_logic;  -- bus enable

    signal rd_bus : std_logic;   -- bus read (inverted)
    signal wr_bus : std_logic;   -- bus write (inverted)

    signal addr_bus : WORD;      -- address bus
    signal data_bus : WORD;      -- data bus
    signal dr_val   : WORD;      -- data register current value

    signal bus_en : std_logic;   -- bus enable
    signal bus_way : std_logic;  -- bus way (0:read 1:write)

    signal bus_done : std_logic; -- bus done
    signal dr_en : std_logic;    -- data register enable

    -- EXECUTE UNIT

    signal data_in : WORD;     -- data input
    signal data_out : WORD;    -- data output
    signal data_val : WORD;
    signal data_sel : std_logic;  -- data select (0: alu_val, 1:alu_right)
    signal const_sel : std_logic_vector (1 downto 0); -- constant select (00: +0, 01: data register, 10: +1, 11: -1)

    signal ir_val : WORD;      -- instruction register current value
    signal ir_en : std_logic;  -- instruction register enable

    signal ip_next : WORD;     -- instruction pointer next value
    signal ip_val : WORD;      -- instruction pointer current value
    signal ip_sel : std_logic; -- instruction pointer next value select
    signal ip_en : std_logic;  -- instruction pointer input enable

    signal sp_val : WORD;      -- stack pointer value
    signal dp_val : WORD;      -- data pointer value
    signal sp_en : std_logic;  -- stack pointer input enable
    signal dp_en : std_logic;  -- data pointer input enable

    signal ptr_val : WORD;       -- pointer value
    signal ptr_sel : std_logic;  -- pointer select

    signal addr_val : WORD;       -- address current value
    signal addr_next : WORD;      -- address next value (incremented)
    signal addr_sel : std_logic;  -- select address source (pointers or IP)

    signal reg_val : WORD;        -- register value
    signal reg_sel : std_logic_vector (1 downto 0);   -- register select

    signal op_val : WORD;         -- operand value
    signal op_sel : std_logic;    -- operand select

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

	-- DECODE UNIT

	-- instruction index from instruction word
	ir_index <= "0" & ir_val (4 downto 0) when ir_val (7 downto 5) = "000" else "000000";
	-- ir_index <= "0000" & ir_val (N-2 downto N-3) when ir_val (N-1) = '0'
	--	else "0001" & ir_val (1 downto 0) when ir_val (N-1 downto N-2) = "100"
	--	else "001" & ir_val (4 downto 2) when ir_val (N-1 downto N-2) = "101"
	--	else "010" & ir_val (4 downto 2) when ir_val (N-1 downto N-2) = "110"
	--	else "1" & ir_val (4 downto 0) when ir_val (N-1 downto N-2) = "111";
	--	else "1" & ir_val (1 downto 0) & ir_val (4 downto 2) when ir_val (N-1 downto N-2) = "111";

	-- register mask in instruction word
	-- ir_reg <= ir_val (1 downto 0) when ir_val (N-1) = '0'
	--	or ir_val (N-1 downto N-2) = '101'
	--	or ir_val (N-1 downto N-2) = '110';

    -- PREPARE UNIT

    index_ins <= rom_index_0 (to_integer (unsigned (ir_index)));

    index_next <= index_ins when index_sel = '1' else index_step;

    index_reg: reg_w
        generic map (N => M)
        port map (I => index_next, O => index_cur, E => prep_en, R => R, CK => CK);

    step_cur <= rom_step_0 (to_integer (unsigned (index_cur)));

    index_step <= step_cur (M-1 downto 0);

    C <= step_cur (P-1 downto M);

    -- TODO: regroup enabled registers

    const_sel  <= C (21 downto 20);
    acc_en     <= C (19) and exec_en;
    sp_en      <= C (18) and exec_en;
    dp_en      <= C (17) and exec_en;
    ptr_sel    <= C (16);
    reg_sel    <= C (15 downto 14);
    left_sel   <= C (13);
    op_sel     <= C (12);
    right_sel  <= C (11);
    data_sel   <= C (10);
    bus_en     <= C (9) and not prep_en;
    bus_way    <= C (8);
    alu_op     <= C (7 downto 5);
    addr_sel   <= C (4);
    ip_sel     <= C (3);
    ip_en      <= C (2) and exec_en;
    index_sel  <= C (1);
    ir_en      <= C (0) and exec_en;

    -- EXECUTE UNIT

    ins_reg: reg_w
        generic map (N => N)
        port map (I => data_val, O => ir_val, E => ir_en, R => R, CK => CK);

    ip_next <= data_out when ip_sel = '1' else addr_next;

    ip_reg: reg_w
        generic map (N => N)
        port map (I => ip_next, O => ip_val, E => ip_en, R => R, CK => CK);

    dp_reg: reg_w
        generic map (N => N)
        port map (I => data_out, O => dp_val, E => dp_en, R => R, CK => CK);

    sp_reg: reg_w
        generic map (N => N)
        port map (I => data_out, O => sp_val, E => sp_en, R => R, CK => CK);

    ptr_val <= sp_val when ptr_sel = '1' else dp_val;
    addr_val <= ptr_val when addr_sel = '1' else ip_val;

	addr_next <= std_logic_vector (unsigned (addr_val) + to_unsigned (1, N));

	acc_reg: reg_w
		generic map (N => N)
		port map (I => data_out, O => acc_val, E => acc_en, R => R, CK => CK);

	reg_val <= sp_val when reg_sel = "01" else dp_val when reg_sel = "00";
	op_val <= ip_val when op_sel = '1' else reg_val;

    alu_left <= op_val when left_sel = '1' else acc_val;
    alu_right <= op_val when right_sel = '1' else data_val;

    -- TODO: replace arithmetic by logic for ALU

    alu_val <= std_logic_vector (unsigned (alu_left) + unsigned (alu_right)) when alu_op = "000"
        else std_logic_vector (unsigned (alu_left) - unsigned (alu_right)) when alu_op = "010"
        else (WORD'range => '0');

    data_out <= alu_val when data_sel = '0' else alu_right;

	--- BUS UNIT

	addr_bus <= (WORD'range => 'Z') when addr_en = '0' else addr_val;

	data_in <= data_bus when data_en = '1' and bus_way = '0'
		else (WORD'range => '0');

	data_bus <= data_out when data_en = '1' and bus_way = '1'
		else (WORD'range => 'Z');

    dr_reg: reg_w
        generic map (N => N)
        port map (I => data_in, O => dr_val, E => dr_en, R => R, CK => CK);

    data_val <= (WORD'range => '0') when const_sel = "00"
        else dr_val when const_sel = "01"
        else (7 downto 1 => '0', 0 => '1') when const_sel = "10"
        else (WORD'range => '1') when const_sel = "11";

    -- CONTROL UNIT

    control_seq : process (R, CK)
    begin
        if R = '1' then
            control_now <= control_prep;

        elsif rising_edge(CK) then
            case control_now is
                when control_prep =>
                    control_now <= control_exec;
                when control_exec =>
					if bus_en = '0' or bus_done = '1' then
						control_now <= control_prep;
					end if;
            end case;
        end if;

    end process;

	prep_en <= '1' when control_now = control_prep else '0';

	exec_en <= '1' when control_now = control_exec and (bus_en = '0' or bus_done ='1') else '0';

    -- BUS UNIT

    bus_seq : process (R, CK)
    begin
        if R = '1' then
            bus_now <= bus_step1;

        elsif rising_edge(CK) then
            case bus_now is
                when bus_step1 =>
                    if bus_en = '1' then
                        bus_now <= bus_step2;
                    end if;
                when bus_step2 =>
                    bus_now <= bus_step3;
                when bus_step3 =>
                    bus_now <= bus_step1;
            end case;
        end if;

    end process;

	addr_en <= '1' when (bus_now = bus_step1 and bus_en = '1')
		or bus_now = bus_step2 or bus_now = bus_step3 else '0';

	data_en <= '1' when (bus_now = bus_step1 and bus_way = '1' and bus_en = '1')
		or bus_now = bus_step2 or (bus_now = bus_step3 and bus_way = '1') else '0';

	rd_bus <= '0' when bus_now = bus_step2 and bus_way = '0' else '1';  -- inverted
	wr_bus <= '0' when bus_now = bus_step2 and bus_way = '1' else '1';  -- inverted

    dr_en <= '1' when bus_now = bus_step2 and bus_way = '0' else '0';
    bus_done <= '1' when bus_now = bus_step3 else '0';

	-- RESET & CLOCK

    reset_0: process
    begin
        wait for 10 ms;
        R <= '0';
		wait;
    end process;

    clock_0: process
    begin
        wait for 1 ms;
        CK <= '1' nand R;
        wait for 1 ms;
        CK <= '0';
    end process;

end architecture;
