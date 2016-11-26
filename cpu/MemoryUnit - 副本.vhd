----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    20:26:00 11/22/2016 
-- Design Name: 
-- Module Name:    MemoryUnit - Behavioral 
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

entity MemoryUnit is
	port(
		--ʱ��
		clk : in std_logic;
		rst : in std_logic;
		
		--����
		data_ready : in std_logic;		--����׼���źţ�='1'��ʾ���ڵ�������׼���ã������ڳɹ�������ʾ������data��
		tbre : in std_logic;				--�������ݱ�־
		tsre : in std_logic;				--���ݷ�����ϱ�־��tsre and tbre = '1'ʱд�������
		wrn : out std_logic;				--д���ڣ���ʼ��Ϊ'1'������Ϊ'0'����RAM1data���ã�����Ϊ'1'д����
		rdn : out std_logic;				--�����ڣ���ʼ��Ϊ'1'����RAM1data��Ϊ"ZZ..Z"��
												--��data_ready='1'�����rdn��Ϊ'0'���ɶ����ڣ�����������RAM1data�ϣ�
		
		--RAM1��DM����RAM2��IM��
		MemRead : in std_logic;			--���ƶ�DM���źţ�='1'������Ҫ��
		MemWrite : in std_logic;		--����дDM���źţ�='1'������Ҫд
		
		dataIn : in std_logic_vector(15 downto 0);		--д�ڴ�ʱ��Ҫд��DM��IM������
		
		ramAddr : in std_logic_vector(15 downto 0);		--��DM/дDM/дIMʱ����ַ����
		PC : in std_logic_vector(15 downto 0);				--��IMʱ����ַ����
		dataOut : out std_logic_vector(15 downto 0);		--��DMʱ��������������/�����Ĵ���״̬
		insOut : out std_logic_vector(15 downto 0);		--��IMʱ��������ָ��
		
		ram1_addr : out std_logic_vector(17 downto 0); 	--RAM1��ַ����
		ram2_addr : out std_logic_vector(17 downto 0); 	--RAM2��ַ����
		ram1_data : inout std_logic_vector(15 downto 0);--RAM1��������
		ram2_data : inout std_logic_vector(15 downto 0);--RAM2��������
		
		ram1_en : out std_logic;		--RAM1ʹ�ܣ�='1'��ֹ
		ram1_oe : out std_logic;		--RAM1��ʹ�ܣ�='1'��ֹ��
		ram1_we : out std_logic;		--RAM1дʹ�ܣ�='1'��ֹ
		ram2_en : out std_logic;		--RAM2ʹ�ܣ�='1'��ֹ
		ram2_oe : out std_logic;		--RAM2��ʹ�ܣ�='1'��ֹ
		ram2_we : out std_logic			--RAM2дʹ�ܣ�='1'��ֹ
		
		
	);
end MemoryUnit;

architecture Behavioral of MemoryUnit is
	signal state : std_logic_vector(1 downto 0) := "00";
	
begin

	--ram1_addr(17 downto 16) <= "00";
	--ram2_addr(17 downto 16) <= "00";

	process(clk, rst)
	begin
		if rst = '0' then
			ram1_en <= '1';
			ram1_oe <= '1';
			ram1_we <= '1';
			ram2_en <= '1';
			ram2_oe <= '1';
			ram2_we <= '1';
			wrn <= '1';
			rdn <= '1';
			
			ram1_addr <= (others => '0');
			ram2_addr <= (others => '0');
			dataOut <= (others => '0');
			insOut <= (others => '0');
			
			state <= "00";
			
		elsif clk'event and clk = '1' then 
			ram1_en <= '0';
			ram2_en <= '0';
			
			case state is 
				when "00" =>
					if (MemWrite = '1') then --д�ڴ�򴮿�
						if (ramAddr <= x"7FFF" and ramAddr >= x"4000") then	--дָ���ڴ�
							ram2_data <= dataIn;
							ram2_addr(15 downto 0) <= ramAddr;
							ram2_we <= '0';
							ram2_oe <= '1';--��ֹ--
							wrn <= '1';		--��ֹ--
							rdn <= '1';		--��ֹ--
						elsif (ramAddr = x"BF00") then	--д��������
							ram1_data(7 downto 0) <= dataIn(7 downto 0);
							ram1_addr(15 downto 0) <= ramAddr;
							wrn <= '0';
							rdn <= '1';		--��ֹ--
							ram1_we <= '1';--��ֹ--
							ram1_oe <= '1';--��ֹ--
							ram2_we <= '1';--��ֹ--
							ram2_oe <= '1';--��ֹ--
						else										--д�����ڴ�
							ram1_data <= dataIn;
							ram1_addr(15 downto 0) <= ramAddr;
							ram1_we <= '0';
							ram1_oe <= '1';--��ֹ--
							wrn <= '1';		--��ֹ--
							rdn <= '1';		--��ֹ--
						end if;
					elsif (MemRead = '1') then --�������ڴ�򴮿�
						if (ramAddr <= x"BF00") then		--����������
							ram1_data(7 downto 0) <= "ZZZZZZZZ";
							rdn <= '1';
							wrn <= '1';		--��ֹ--
							ram1_we <= '1';--��ֹ--
							ram1_oe <= '1';--��ֹ--
							ram2_we <= '1';--��ֹ--
							ram2_oe <= '1';--��ֹ--
						elsif (ramAddr <= x"BF01") then	--������״̬
							dataOut(15 downto 2) <= (others => '0');
							dataOut(1) <= data_ready;
							dataOut(0) <= tsre and tbre;
						else										--�������ڴ�
							ram1_data <= (others => 'Z');
							ram1_addr(15 downto 0) <= ramAddr;
							ram1_oe <= '0';
							ram1_we <= '1';--��ֹ--
							wrn <= '1';		--��ֹ--
							rdn <= '1';		--��ֹ--
						end if;
					end if;
					state <= "01";
				when "01" =>
					if (MemWrite = '1') then --д�ڴ�򴮿�
						if (ramAddr <= x"7FFF" and ramAddr >= x"4000") then	--дָ���ڴ�
							ram2_we <= '1';			--�ڶ���������RAM2д�ź�
							ram2_oe <= '1';--��ֹ--
							wrn <= '1';		--��ֹ--
							rdn <= '1';		--��ֹ--
						elsif (ramAddr = x"BF00") then	--д��������
							wrn <= '1';					--�ڶ���������д�����ź�
							rdn <= '1';		--��ֹ--
							ram1_we <= '1';--��ֹ--
							ram1_oe <= '1';--��ֹ--
							ram2_we <= '1';--��ֹ--
							ram2_oe <= '1';--��ֹ--
						else										--д�����ڴ�
							ram1_we <= '1';			--�ڶ���������RAM1д�ź�
							ram1_oe <= '1';--��ֹ--
							wrn <= '1';		--��ֹ--
							rdn <= '1';		--��ֹ--
						end if;
					elsif (MemRead = '1') then --�������ڴ�򴮿�
						if (ramAddr <= x"BF00") then		--����������
							if (data_ready = '1') then
								rdn <= '0';
								dataOut(7 downto 0) <= ram1_data(7 downto 0);	--------д��һ��״̬���
								dataOut(15 downto 8) <= "00000000";		--������ݵĸ߰�λ����
							end if;
							wrn <= '1';		--��ֹ--
							ram1_we <= '1';--��ֹ--
							ram1_oe <= '1';--��ֹ--
							ram2_we <= '1';--��ֹ--
							ram2_oe <= '1';--��ֹ--
						elsif (ramAddr <= x"BF01") then	--������״̬
							null;
						else										--�������ڴ�
							dataOut <= ram1_data;							-------�������ֱ�ӵõ�������
							ram1_we <= '1';--��ֹ--
							wrn <= '1';		--��ֹ--
							rdn <= '1';		--��ֹ--
						end if;
					end if;
					state <= "10";
				when "10" =>		--��ָ���ڴ�
					ram2_data <= (others => 'Z');
					ram2_addr(15 downto 0) <= PC;
					ram2_oe <= '0';
					ram2_we <= '1';		--��ֹ--
					
					state <= "11";
				when "11" =>		--��ָ���ڴ棬�ڶ��׶�
					insOut <= ram2_data;							-------�������ֱ�ӵõ�������
					ram2_we <= '1';		--��ֹ--
					
					state <= "00";
					
				when others =>
					state <= "00";
					
			end case;
		end if;
	end process;
end Behavioral;

