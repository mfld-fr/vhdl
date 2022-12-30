library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity test_sram is

    generic (
		DW : positive := 5;
		AW : positive := 5
		);

end entity;


architecture behavior of test_sram is

    subtype WORD is std_logic_vector (DW-1 downto 0);
    subtype ADDR is std_logic_vector (AW-1 downto 0);

    component sram is
		generic (
		    DW : positive;  -- word width
		    AW : positive   -- address width
		    );

		port (
		    D : inout WORD;
		    A : in ADDR;

		    CS : in std_logic;  -- chip select (inverted)
		    OE : in std_logic;  -- output enable (inverted)
			WE : in std_logic   -- write enable (inverted)
		    );

    end component;

    signal D : WORD := (WORD'range => 'Z');
    signal A : ADDR := (ADDR'range => 'Z');

    signal CS : std_logic := '1';
    signal OE : std_logic := '1';
    signal WE : std_logic := '1';

begin

    sram_0: sram
        generic map (DW => DW, AW => AW)
        port map (D => D, A => A, CS => CS, OE => OE, WE => WE);

	test_0: process

		procedure write (ai : in ADDR; di : in WORD) is
		begin
			A <= ai;
	        D <= di;
			CS <= '0';
			WE <= '0';
    	    wait for 1 ms;
			WE <= '1';
    	    wait for 1 ms;
			A <= (ADDR'range => 'Z');
			D <= (WORD'range => 'Z');
    	    CS <= '1';
		end procedure;

		procedure read (ai : in ADDR) is
		begin
			A <= ai;
			CS <= '0';
			OE <= '0';
	        wait for 1 ms;
			A <= (ADDR'range => 'Z');
			D <= (WORD'range => 'Z');
	        CS <= '1';
	        OE <= '1';
		end procedure;

	variable i : unsigned (AW-1 downto 0);

    begin
		i := (others => '0');
	    wait for 1 ms;

		loop
			write (ADDR (i), WORD (i));
		    wait for 1 ms;
			exit when i = 2**AW - 1;
			i := i + 1;
		end loop;

		i := (others => '0');
	    wait for 1 ms;

		loop
			read (ADDR (i));
		    wait for 1 ms;
			exit when i = 2**AW - 1;
			i := i + 1;
		end loop;

		wait;

    end process;

end architecture;
