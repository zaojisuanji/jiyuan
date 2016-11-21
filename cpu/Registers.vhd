----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    20:39:24 11/20/2015 
-- Design Name: 
-- Module Name:    Registers - Behavioral 
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

entity Registers is
	port(
			clk : in std_logic;
			rst : in std_logic;
			
			ReadReg1In : in std_logic_vector(3 downto 0);  --"0XXX"代表R0~R7，"1000"=SP,"1001"=IH, "1010"=T
			ReadReg2In : in std_logic_vector(3 downto 0);  --"0XXX"代表R0~R7
			
			WriteReg : in std_logic_vector(3 downto 0);	  --由WB阶段传回：目的寄存器
			WriteData : in std_logic_vector(15 downto 0);  --由WB阶段传回：写目的寄存器的值
			RegWrite : in std_logic;					--由WB阶段传回：RegWrite（写目的寄存器）控制信号
			
			r0Out, r1Out, r2Out,r3Out,r4Out,r5Out,r6Out,r7Out : out std_logic_vector(15 downto 0);
			
			ReadData1 : out std_logic_vector(15 downto 0); --读出的寄存器1的值
			ReadData2 : out std_logic_vector(15 downto 0); --读出的寄存器2的值
			--dataT : out std_logic_vector(15 downto 0);
			--dataSP : out std_logic_vector(15 downto 0);
			--dataIH : out std_logic_vector(15 downto 0)
	);
end Registers;

architecture Behavioral of Registers is

	signal r0 : std_logic_vector(15 downto 0);
	signal r1 : std_logic_vector(15 downto 0);
	signal r2 : std_logic_vector(15 downto 0);
	signal r3 : std_logic_vector(15 downto 0);
	signal r4 : std_logic_vector(15 downto 0);
	signal r5 : std_logic_vector(15 downto 0);
	signal r6 : std_logic_vector(15 downto 0);
	signal r7 : std_logic_vector(15 downto 0);
	signal T : std_logic_vector(15 downto 0);
	signal IH : std_logic_vector(15 downto 0);
	signal SP : std_logic_vector(15 downto 0);
begin
	
	process(clk, rst)
	begin
		if (rst = '0') then
			r0 <= (others => '0');
			r1 <= (others => '0');
			r2 <= (others => '0');
			r3 <= (others => '0');
			r4 <= (others => '0');
			r5 <= (others => '0');
			r6 <= (others => '0');
			r7 <= (others => '0');
			T <= (others => '0');
			IH <= (others => '0');			
			SP <= (others => '0');
		elsif (clk'event and clk = '0' and RegWrite = '1') then
			case WriteReg is 
				when "0000" => r0 <= WriteData;
				when "0001" => r1 <= WriteData;
				when "0010" => r2 <= WriteData;
				when "0011" => r3 <= WriteData;
				when "0100" => r4 <= WriteData;
				when "0101" => r5 <= WriteData;
				when "0110" => r6 <= WriteData;
				when "0111" => r7 <= WriteData;
				when "1000" => SP <= WriteData;
				when "1001" => IH <= WriteData;
				when "1010" => T <= WriteData;
				when others =>
			end case;
		end if;
	end process;
	
	process
	begin 
		case ReadReg1In is 
			when "0000" => dataA <= r0;
			when "0001" => dataA <= r1;
			when "0010" => dataA <= r2;
			when "0011" => dataA <= r3;
			when "0100" => dataA <= r4;
			when "0101" => dataA <= r5;
			when "0110" => dataA <= r6;
			when "0111" => dataA <= r7;
			when "1000" => dataA <= SP;
			when "1001" => dataA <= IH;
			when "1010" => dataA <= T;
			when others =>
		end case;
	end process;
	
	process
	begin 
		case ReadReg2In is
			when "0000" => dataB <= r0;
			when "0001" => dataB <= r1;
			when "0010" => dataB <= r2;
			when "0011" => dataB <= r3;
			when "0100" => dataB <= r4;
			when "0101" => dataB <= r5;
			when "0110" => dataB <= r6;
			when "0111" => dataB <= r7;
			when others =>
		end case;
	end process;
	
	--dataSP <= SP;
	--dataIH <= IH;
	--dataT <= T;
	
	r0Out <= r0;
	r1Out <= r1;
	r2Out <= r2;
	r3Out <= r3;
	r4Out <= r4;
	r5Out <= r5;
	r6Out <= r6;
	r7Out <= r7;
end Behavioral;

