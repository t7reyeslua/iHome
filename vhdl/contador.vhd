----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    21:54:30 02/27/2008 
-- Design Name: 
-- Module Name:    contador - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity contador is
    Port ( inc : in std_logic;
           reset : in std_logic;
			  run: in std_logic;
           s : inout std_logic_vector(9 downto 0));
end contador;

architecture Behavioral of contador is

begin
process(inc, reset,run)
begin 
	if (inc='1') and inc'event and run='1' then 
		if reset='1' then
			s<="0000000000";
		else
			s<= s+1;
		end if;
end if;
end process;
end Behavioral;


