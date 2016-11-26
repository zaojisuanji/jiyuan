----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    20:45:59 11/19/2015 
-- Design Name: 
-- Module Name:    ForwardController - Behavioral 
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

entity ForwardController is
	port(
		ExMemRd : in std_logic_vector(3 downto 0);   --
		MemWbRd : in std_logic_vector(3 downto 0);   --
		
		--ExMemRegWrite : in std_logic;
		--MemWbRegWrite : in std_logic;    --��"1111"�ж�û��Դ�Ĵ���
		
		IdExALUsrcB : in std_logic;
		
		IdExReg1 : in std_logic_vector(3 downto 0);  --����ָ���Դ�Ĵ���1
		IdExReg2 : in std_logic_vector(3 downto 0);  --����ָ���Դ�Ĵ���2
		
		ForwardA : out std_logic_vector(1 downto 0);
		ForwardB : out std_logic_vector(1 downto 0)
	);
end ForwardController;

architecture Behavioral of ForwardController is
begin
	process(ExMemRd, MemWbRd, IdExALUsrcB, IdExReg1, IdExReg2)
	begin
		if (IdExReg1 = ExMemRd) then
			ForwardA <= "01";
		elsif (IdExReg1 = MemWbRd) then
			ForwardA <= "10";
		else
			ForwardA <= "00";
		end if;
		
		if (IdExALUsrcB = '1') then		--SrcB��һ�����������򲻻������ͻ
			ForwardB <= "00";
		elsif (IdExALUsrcB = '0') then	--SrcB��һ���Ĵ���ֵ������ܲ�����ͻ
			if (IdExReg2 = ExMemRd) then
				ForwardB <= "01";
			elsif (IdExReg2 = MemWbRd) then
				ForwardB <= "10";
			else									--�޳�ͻ
				ForwardB <= "00";
			end if;
		end if;
		
	end process;

end Behavioral;

