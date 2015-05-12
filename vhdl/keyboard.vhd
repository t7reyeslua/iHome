
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity keyboard is
	port(	keyboard_clk	: IN	STD_LOGIC;
			keyboard_data	: IN	STD_LOGIC;
			clock_25Mhz		: IN	STD_LOGIC;
			reset				: IN	STD_LOGIC;
			read_kb				: IN	STD_LOGIC;
			scan_code		: OUT	STD_LOGIC_VECTOR(7 DOWNTO 0);
			scan_ready		: OUT	STD_LOGIC);
end keyboard;

architecture Behavioral of keyboard is
	signal INCNT					: std_logic_vector(3 downto 0);
	signal SHIFTIN 				: std_logic_vector(8 downto 0);
	signal READ_CHAR 				: std_logic;
	signal INFLAG, ready_set	: std_logic;
	signal keyboard_clk_filtered 	: std_logic;
	signal filter 					: std_logic_vector(7 downto 0);
	
begin

process (read_kb, ready_set)
begin
  if read_kb = '1' then 
		scan_ready <= '0';
  elsif ready_set'EVENT and ready_set = '1' then
		scan_ready <= '1';
  end if;
end process;


--Este proceso filtra la raw signal del clock que viene del teclado usando un shift register y dos ands
Clock_filter: process
begin
	wait until clock_25Mhz'EVENT and clock_25Mhz= '1';
		filter (6 downto 0) <= filter(7 downto 1) ;
		filter(7) <= keyboard_clk;
		if filter = "11111111" then 
			keyboard_clk_filtered <= '1';
		elsif  filter= "00000000" then 
			keyboard_clk_filtered <= '0';
		end if;
end process Clock_filter;


--Este proceso lee data serial que llega de la terminal
process
begin
wait until (KEYBOARD_CLK_filtered'EVENT and KEYBOARD_CLK_filtered='1');
	if RESET='1' then
        INCNT <= "0000";
        READ_CHAR <= '0';
	elsif KEYBOARD_DATA='0' and READ_CHAR='0' then
        READ_CHAR<= '1';
        ready_set<= '0';
	elsif READ_CHAR = '1' then -- Shift in los sig 8 data bits para armar el scan code   
        if INCNT < "1001" then
         	INCNT <= INCNT + 1;
         	SHIFTIN(7 downto 0) <= SHIFTIN(8 downto 1);
         	SHIFTIN(8) <= KEYBOARD_DATA;
				ready_set <= '0';
        else -- Fin del char de scan code, así que pon las banderas y salte del loop
	 	   	scan_code <= SHIFTIN(7 downto 0);
	   		READ_CHAR <='0';
	    	   ready_set <= '1';
	    	   INCNT <= "0000";
        end if;
   end if;
end process;

end Behavioral;


