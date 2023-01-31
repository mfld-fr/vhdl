use std.textio.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;

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

    impure function init_ram return MEMORY is

        file text_file : TEXT open read_mode is "sram.txt";
        variable text_line : LINE;
		variable i : integer := 0;
		variable mem_0 : MEMORY;

    begin
        while not endfile (text_file) loop
            readline (text_file, text_line);
            bread (text_line, mem_0 (i));
			i := i + 1;
        end loop;

		for j in i to 2**AW - 1 loop
			mem_0 (j) := (WORD'range => '1');
		end loop;

		return mem_0;

    end function init_ram;

    signal mem: MEMORY := init_ram;


begin

    mem (to_integer (unsigned (A))) <= D when CS = '0' and WE = '0';
	D <= (WORD'range => 'Z') when CS = '1' or OE = '1' else mem (to_integer (unsigned (A)));

end architecture;
