----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    23:03:16 11/20/2016 
-- Design Name: 
-- Module Name:    PCMux - Behavioral 
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity PCMux is
	--ѡ����PC�ĵ�Ԫ
	port(
		PCAddOne : in std_logic_vector(15 downto 0);	 --PC+1
		IdEximme : in std_logic_vector(15 downto 0); --���ڼ���Branch��ת��PCֵ=IdEXEimme+PC+1
		AsrcOut : in std_logic_vector(15 downto 0);	 --����JRָ���ת��ַΪASrcOut
		
		
		jump : in std_logic;					--jump�����ܿ�����Controller�������ź�
		BranchJudge : in std_logic;		--����ALU�����Ŀ����źţ���ʾB����ת�ɹ�
		PCRollback : in std_logic;			--SW���ݳ�ͻʱ��PC��Ҫ���˵�SW��һ��ָ��ٵĵ�ַ��
													--����ǰ��PC+1�Ǣ۵ĵ�ַ�����Դ�ʱPCOut = PCAddOne - 2;
		
		PCOut : out std_logic_vector(15 downto 0)
	);
end PCMux;

architecture Behavioral of PCMux is
	
	
begin
	process(PCAddOne, IdEximme, AsrcOut, jump, BranchJudge)
	begin
		if (BranchJudge = '1' and jump = '0') then
			PCOut <= IdEximme + PCAddOne;
		elsif (jump = '1' and BranchJudge = '0') then
			PCOut <= AsrcOut;
		elsif (jump = '0' and BranchJudge = '0') then
			if (PCRollback = '1') then
				PCOut <= PCAddOne - "0000000000000010";	--PCOut = PCAddOne - 2;
			elsif (PCRollback = '0') then
				PCOut <= PCAddOne;
			end if;
		end if;
	
	end process;
end Behavioral;

