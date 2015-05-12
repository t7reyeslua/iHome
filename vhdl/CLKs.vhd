----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    21:29:39 02/27/2008 
-- Design Name: 
-- Module Name:    CLKs - Behavioral 
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

entity CLKs is
	Port (  Clk_in : in  STD_LOGIC;
           CLK_out: out STD_LOGIC);
end CLKs;

architecture Behavioral of CLKs is
signal cont: STD_LOGIC_VECTOR(25 downto 0);
signal CLK1: STD_LOGIC;
begin
	
	process(Clk_in)
	begin
		if CLK_in'event and Clk_in='1' then
				CLK1 <= not CLK1;
		end if;
	end process;
	
	CLK_out<= CLK1;
	
end Behavioral;

