----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    14:03:34 11/21/2016 
-- Design Name: 
-- Module Name:    ExMemRegisters - Behavioral 
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

entity ExMemRegisters is
	--EX/MEM�׶μĴ���
	port(
		clk : in std_logic;
		rst : in std_logic;
		--��������
		rdIn : in std_logic_vector(3 downto 0);
		PCIn : in std_logic_vector(15 downto 0);
		ALUResultIn : in std_logic_vector(15 downto 0);
		readData2In : in std_logic_vector(15 downto 0); --��SW���д�ڴ�
		--�ź�����
		regWriteIn : in std_logic;
		memReadIn : in std_logic;
		memWriteIn : in std_logic;
		memToRegIn : in std_logic;

		--�������
		rdOut : out std_logic_vector(3 downto 0);
		PCOut : out std_logic_vector(15 downto 0);
		ALUResultOut : out std_logic_vector(15 downto 0);
		readData2Out : out std_logic_vector(15 downto 0); --��SW���д�ڴ�
		--�ź����
		regWriteOut : out std_logic;
		memReadOut : out std_logic;
		memWriteOut : out std_logic;
		memToRegOut : out std_logic
	);
end ExMemRegisters;

architecture Behavioral of ExMemRegisters is

begin
	process(rst, clk)
	begin
		if (rst = '0') then
			rdOut <= (others => '0');
			PCOut <= (others => '0');
			ALUResultOut <= (others => '0');
			readData2Out <= (others => '0');
			
			regWriteOut <= '0';
			memReadOut <= '0';
			memWriteOut <= '0';
			memToRegOut <= '0';

		elsif (clk'event and clk = '1') then
			rdOut <= rdIn;
			PCOut <= PCIn;
			ALUResultOut <= ALUResultIn;
			readData2Out <= readData2In;
			
			regWriteOut <= regWriteIn;
			memReadOut <= memReadIn;
			memWriteOut <= memWriteIn;
			memToRegOut <= memToRegIn;
			
		end if;
	end process;
end Behavioral;

