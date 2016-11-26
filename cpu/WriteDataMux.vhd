----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    20:16:47 11/26/2016 
-- Design Name: 
-- Module Name:    WriteDataMux - Behavioral 
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

entity WriteDataMux is
	port(
		--�����ź�
		ForwardSW : in std_logic_vector(1 downto 0);
		--��ѡ������
		ReadData2 : in std_logic_vector(15 downto 0);
		ExMemALUResult : in std_logic_vector(15 downto 0);	--����ָ���ALU���
		MemWbResult : in std_logic_vector(15 downto 0);	--������ָ��Ľ��
		--ѡ�������
		WriteDataOut : out std_logic_vector(15 downto 0)
	);
end WriteDataMux;

architecture Behavioral of WriteDataMux is

begin
	process(ForwardSW,ReadData2,ExMemALUResult,MemWbResult)
	begin
		case ForwardSW is
			when "00" =>
				WriteDataOut <= ReadData2;
			when "01" =>
				WriteDataOut <= ExMemALUResult;
			when "10" =>
				WriteDataOut <= MemWbResult;
			when others =>
		end case;
	end process;


end Behavioral;

