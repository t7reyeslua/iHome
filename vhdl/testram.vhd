------------------------------------------------------------------
-- Copyright (c) 1995-2005 Xilinx, Inc.
-- All Right Reserved.
------------------------------------------------------------------
--   ____  ____ 
--  /   /\/   / 
-- /___/  \  /    Vendor: Xilinx 
-- \   \   \/     Version : 8.1i
--  \   \         Application : 
--  /   /         Filename : testram.vhd
-- /___/   /\     Timestamp : 9/20/2005 11:04:05
-- \   \  /  \ 
--  \___\/\___\ 
--
-- 
--    This Entity contains an array of data elements representing VGA display patterns 

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity testram is Port ( 
	address: in std_logic_vector(6 downto 0);
	data: 	out std_logic_vector(3 downto 0)
	);
end testram;

architecture behavioral of testram is

type mem_array is array (0 to 111) of std_logic_vector(3 downto 0);
constant characters: mem_array := (

	-- 0
	"0000",
	"0110",
	"1001",
	"1001",
	"1001",
	"1001",
	"1001",
	"0110",

	-- 1
	"0000",
	"0001",
	"0001",
	"0001",
	"0001",
	"0001",
	"0001",
	"0001",

	-- 2
	"0000",
	"1110",
	"0001",
	"0001",
	"0111",
	"1000",
	"1000",
	"1111",

	-- 3
	"0000",
	"1110",
	"0001",
	"0001",
	"1111",
	"0001",
	"0001",
	"1110",

	-- 4
	"0000",
	"1001",
	"1001",
	"1001",
	"1111",
	"0001",
	"0001",
	"0001",

	-- 5
	"0000",
	"1111",
	"1000",
	"1000",
	"1110",
	"0001",
	"0001",
	"1110",

	-- 6
	"0000",
	"0111",
	"1000",
	"1000",
	"1110",
	"1001",
	"1001",
	"0110",

	-- 7
	"0000",
	"1111",
	"0001",
	"0001",
	"0001",
	"0001",
	"0001",
	"0001",

	-- 8
	"0000",
	"0110",
	"1001",
	"1001",
	"0110",
	"1001",
	"1001",
	"0110",

	-- 9
	"0000",
	"0110",
	"1001",
	"1001",
	"0111",
	"0001",
	"0001",
	"0001",
	
	-- :
	"0000",
	"0000",
	"0110",
	"0110",
	"0000",
	"0110",
	"0110",
	"0000",
	
	-- " "
	"0000",
	"0000",
	"0000",
	"0000",
	"0000",
	"0000",
	"0000",
	"0000",
	
	-- N
	"0000",
	"0000",
	"0000",
	"0000",
	"1001",
	"1101",
	"1011",
	"1001",
	
	-- F
	"0000",
	"0110",
	"1001",
	"1000",
	"1111",
	"1000",
	"1000",
	"1000"
	);

begin

process (address )
begin
		data <= characters(conv_integer(address));
end process;

end behavioral;