library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Asynchronous static RAM chip

entity sram is

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

end entity;


architecture behavior of sram is

    subtype WORD is std_logic_vector (DW-1 downto 0);

    type MEMORY is array (0 to 2**AW - 1) of WORD;

	-- TODO: move to ROM chip
    signal mem: MEMORY := (
        "00000011",  -- 00h  LD DP,1Dh
        "00011101",  -- 01h  ...
        "00010110",  -- 02h  CALL 10h
        "00010000",  -- 03h  ...
        "00000011",  -- 04h  LD DP,1Eh
        "00011110",  -- 05h  ...
        "00010110",  -- 06h  CALL 18h
        "00011000",  -- 07h  ...
        "00001100",  -- 08h  JMP 0h
        "00000000",  -- 09h  ...
        "00000000",  -- 0Ah  NOP
        "00000000",  -- 0Bh  NOP
        "00000000",  -- 0Ch  NOP
        "00000000",  -- 0Dh  NOP
        "00000000",  -- 0Eh  NOP
        "00000000",  -- 0Fh  NOP
        "00000100",  -- 10h  LD A,(DP)
        "00011110",  -- 11h  INC A
        "00000101",  -- 12h  ST A,(DP)
        "00010111",  -- 13h  RET
        "00000000",  -- 14h  NOP
        "00000000",  -- 15h  NOP
        "00000000",  -- 16h  NOP
        "00000000",  -- 17h  NOP
        "00000100",  -- 18h  LD A,(DP)
        "00011111",  -- 19h  DEC A
        "00000101",  -- 1Ah  ST A,(DP)
        "00010111",  -- 1Bh  RET
        "00000000",  -- 1Ch  NOP
        "00000000",  -- 1Dh  DW 0h (count 1)
        "00000000",  -- 1Eh  DW 0h (count 2)
        "00000000"   -- 1Fh  DW 0h (stack)
        );

begin

    mem (to_integer (unsigned (A))) <= D when CS = '0' and WE = '0';
	D <= (WORD'range => 'Z') when CS = '1' or OE = '1' else mem (to_integer (unsigned (A)));

end architecture;
