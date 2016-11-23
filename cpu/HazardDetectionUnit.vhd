----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    16:18:15 11/22/2015 
-- Design Name: 
-- Module Name:    BMux - Behavioral 
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

entity HazardDetectionUnit is
	port(
		ExMemRd : in std_logic_vector(3 downto 0);
		ExMemMemRead : in std_logic;
		
		IdExeReg1 : in std_logic_vector(3 downto 0);
		IdExeReg2 : in std_logic_vector(3 downto 0);
		
		PCKeep : out std_logic;
		IfIdKeep : out std_logic;
		IdExFlush : out std_logic
	);	
end HazardDetectionUnit;

architecture Behavioral of HazardDetectionUnit is
	
begin
	process(ExMemRd, ExMemMemRead, IdExeReg1, IdExeReg2)
	begin 
		if (ExMemMemRead = '0') then
			PCKeep <= '0';
			IfIdKeep <= '0';
			IdExFlush <= '0';
		elsif (IdExeReg1 = "1111" and IdExeReg2 = "1111") then
			PCKeep <= '0';
			IfIdKeep <= '0';
			IdExFlush <= '0';
		elsif (IdExeReg1 = ExMemRd or IdExeReg2 = ExMemRd) then
			PCKeep <= '1';
			IfIdKeep <= '1';
			IdExFlush <= '1';
		else
			PCKeep <= '0';
			IfIdKeep <= '0';
			IdExFlush <= '0';
		end if;

	end process;

end Behavioral;

