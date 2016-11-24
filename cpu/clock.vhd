----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    03:13:31 12/06/2014 
-- Design Name: 
-- Module Name:    clock - Behavioral 
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity clock is
    Port ( 
			rst : in STD_LOGIC;
			clk : in  STD_LOGIC;
		   
			clkout :out STD_LOGIC;
         clk1 : out  STD_LOGIC
			 );
end clock;

architecture Behavioral of clock is
	signal count:natural range 0 to 3 := 0;
	
begin
	process (clk,rst)
		begin
			clkout <= clk;
			if(rst = '1') then
			clkout <= '0';
			clk1 <= '0';
			count <= 0;
			elsif (clk'event and clk='1') then			
				case count is
					when 0 =>
						clk1 <= '1';

					when others =>
						clk1 <= '0';
				end case;
				
				if(count = 3) then
					count <= 0;
				else 
					count <= count + 1;
				end if;
				
			end if;

		end process;
end Behavioral;

