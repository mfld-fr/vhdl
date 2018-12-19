library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity test_auto is

    generic (
        N : positive := 4;
        P : positive := 14
        );

end entity;


architecture behavior of test_auto is

    subtype WORD is std_logic_vector (N-1 downto 0);

    subtype INDEX is std_logic_vector (N-1 downto 0);
    subtype STEP is std_logic_vector (P-1 downto 0);

    type ROM_STEP is array (0 to 2**N - 1) of STEP;

    --   9876543210
    --   X             data write enable
    --    XX            ALU operation select (00: right, 01: left, 10: add, 11: sub)
    --      X           DP register input enable
    --       X          address source select (0: instruction pointer, 1: data pointer)
    --        X         accumulator input enable
    --         X        IP next value select (0: incremented address, 1: data input)
    --          X       IP register input enable
    --           X      next index select (0: step, 1: instruction register)
    --            X     instruction register input enable

    constant rom_step_0: ROM_STEP := (
        "00000001110000",  -- 0h  load IR & increment IP / decode instruction
        "00000000000000",  -- 1h
        "00000000000000",  -- 2h
        "00000000000000",  -- 3h
        "00000101000000",  -- 4h  LD A,immediate
        "00010001000000",  -- 5h  LD DP,immediate
        "00000000000000",  -- 6h
        "00000000000000",  -- 7h
        "00001100000000",  -- 8h  LD A,(DP)
        "10101000000000",  -- 9h  ST A,(DP)
        "00000000000000",  -- Ah
        "00000000000000",  -- Bh
        "00000011000000",  -- Ch  JMP immediate
        "00000000000000",  -- Dh
        "01000101000000",  -- Eh  ADD A,immediate
        "01100101000000"   -- Fh  SUB A,immediate
        );

    type MEMORY is array (0 to 2**N - 1) of WORD;

    signal mem_0: MEMORY := (
        "0100",  -- 0h  LD A,...
        "0000",  -- 1h  ...0h
        "0101",  -- 2h  LD DP,...
        "1111",  -- 3h  ...Fh
        "1001",  -- 4h  ST A,(DP)
        "0101",  -- 5h  LD DP,...
        "1111",  -- 6h  ...Fh
        "1000",  -- 7h  LD A,(DP)
        "1110",  -- 8h  ADD A,...
        "0001",  -- 9h  ...1h
        "1001",  -- Ah  ST A,(DP)
        "1100",  -- Bh  JMP...
        "0101",  -- Ch  ...5h
        "0000",  -- Dh
        "0000",  -- Eh
        "0000"   -- Fh  DW 0h
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
    
    signal index_cur : INDEX;  -- current from index register
    signal index_ins : INDEX;  -- index from instruction register
    signal index_step : INDEX;  -- index from automaton step
    signal index_next : INDEX;  -- next index after selection
    
    signal index_sel : std_logic;  -- select index source (step or instruction register)

    signal step_cur : STEP;

    signal C : std_logic_vector (P - N - 1 downto 0);  -- control bus

    signal data_in : WORD;  -- data bus input
    signal data_out : WORD;  -- data bus output
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
        port map (I => data_in, O => index_ins, E => ir_en, R => R, CK => CK);

    index_next <= index_ins when index_sel = '1' else index_step;

    index_reg: reg_logic
        generic map (N => N)
        port map (I => index_next, O => index_cur, E => '1', R => R, CK => NCK);

    step_cur <= rom_step_0 (to_integer (unsigned (index_cur)));

    index_step <= step_cur (N-1 downto 0);

    C <= step_cur (P-1 downto N);

    ir_en      <= C (0);
    index_sel  <= C (1);
    ip_en      <= C (2);
    ip_sel     <= C (3);
    acc_en     <= C (4);
    addr_sel   <= C (5);
    dp_en      <= C (6);
    alu_sel    <= C (8 downto 7);
    wr_en      <= C (9);

    ip_next <= data_in when ip_sel = '1' else addr_next;

    ip_reg: reg_logic
        generic map (N => N)
        port map (I => ip_next, O => ip_val, E => ip_en, R => R, CK => CK);

    dp_reg: reg_logic
        generic map (N => N)
        port map (I => data_in, O => dp_val, E => dp_en, R => R, CK => CK);

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
