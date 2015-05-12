----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    10:21:05 08/15/2007 
-- Design Name: 
-- Module Name:    Display - Behavioral 
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

entity Display is
Port (
			-- Input
			Clk_in	: in  STD_LOGIC;		-- Clock
				-- Data
			D0 		: in  STD_LOGIC_VECTOR (3 downto 0);
			D1			: in  STD_LOGIC_VECTOR (3 downto 0);
			D2 		: in  STD_LOGIC_VECTOR (3 downto 0);
			D3 		: in  STD_LOGIC_VECTOR (3 downto 0);
			
			-- Output
			D7 : out  STD_LOGIC_VECTOR (7 downto 0);	-- Data
			En : out  STD_LOGIC_VECTOR (3 downto 0)	-- Enable
		);
end Display;

architecture Behavioral of Display is
	-- Display signal
	signal Dmix : std_logic_vector(3 downto 0);
	
	-- Clock signals
	signal clk_cont : std_logic_vector(28 downto 0);
	signal clk		 : std_logic;
	
	-- SM signals
	signal pstate	:	std_logic_vector(3 downto 0);
	signal nstate	:	std_logic_vector(3 downto 0);
	
begin

	-- Clock stuff
	----------------------------------------------------------------------------
	C1:process(Clk_in)begin
		if(clk_in = '1' and clk_in'event)then
			clk_cont <= clk_cont+1;
		end if;
	end process;
	
	clk <= clk_cont(8);
	----------------------------------------------------------------------------
	-- End Clock Stuff
	
	-- State Machine
	----------------------------------------------------------------------------
	nstate <= 	"0001" when pstate = "1000" else
					"0010" when pstate = "0001" else
					"0100" when pstate = "0010" else
					"1000" when pstate = "0100" else
					"0001";
	
	SM:process(clk)begin
		if(clk = '1' and clk'event)then
			pstate <= nstate;
		end if;
	end process;
	----------------------------------------------------------------------------
	-- End State Machine
	
	-- Data coding
	----------------------------------------------------------------------------
	Dmix <=	D0 when pstate = "0001" else
				D1 when pstate = "0010" else
				D2 when pstate = "0100" else
				D3 when pstate = "1000" else
				x"A";
	
	D7(6 downto 0) <=	"0000001" when Dmix = "0000" else 	-- 0
							"1001111" when Dmix = "0001" else	-- 1
							"0010010" when Dmix = "0010" else	-- 2
							"0000110" when Dmix = "0011" else	-- 3
							"1001100" when Dmix = "0100" else 	-- 4
							"0100100" when Dmix = "0101" else 	-- 5
							"0100000" when Dmix = "0110" else 	-- 6
							"0001111" when Dmix = "0111" else 	-- 7
							"0000000" when Dmix = "1000" else 	-- 8
							"0000100" when Dmix = "1001" else 	-- 9
							"1111111" when Dmix = "1010" else 	-- " "
							"1110001" when Dmix = "1011" else 	-- L
							"1111010" when Dmix = "1100" else 	-- r
							"0001000" when Dmix = "1101" else 	-- A
							"0100000" when Dmix = "1110" else 	-- G
							"0111000" when Dmix = "1111" else 	-- F
							"1010101" ;	
							
	D7(7) <=  '0' when ((pstate = "0100") and (Dmix < "1010")) else '1';
	----------------------------------------------------------------------------
	-- End Data Coding
	
	En <= not pstate;


end Behavioral;

