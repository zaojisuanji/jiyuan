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
		
		--RAM1�����ڣ�
		data_ready : in std_logic;		--����׼���źţ�='1'��ʾ���ڵ�������׼���ã������ڳɹ�������ʾ������data��
		tbre : in std_logic;				--�������ݱ�־
		tsre : in std_logic;				--���ݷ�����ϱ�־��tsre and tbre = '1'ʱд�������
		wrn : out std_logic;				--д���ڣ���ʼ��Ϊ'1'������Ϊ'0'����RAM1data���ã�����Ϊ'1'д����
		rdn : out std_logic;				--�����ڣ���ʼ��Ϊ'1'����RAM1data��Ϊ"ZZ..Z"��
												--��data_ready='1'�����rdn��Ϊ'0'���ɶ����ڣ�����������RAM1data�ϣ�
		
		--RAM2��IM+DM��
		MemRead : in std_logic;							--���ƶ�DM���źţ�='1'������Ҫ��
		MemWrite : in std_logic;						--����дDM���źţ�='1'������Ҫд
		
		dataIn : in std_logic_vector(15 downto 0);		--д�ڴ�ʱ��Ҫд��DM��IM������
		
		ramAddr : in std_logic_vector(15 downto 0);		--��DM/дDM/дIMʱ����ַ����
		PC : in std_logic_vector(15 downto 0);			--��IMʱ����ַ����
		dataOut : out std_logic_vector(15 downto 0);	--��DMʱ��������������/�����Ĵ���״̬
		insOut : out std_logic_vector(15 downto 0);		--��IMʱ��������ָ��
		
		ram1_addr : out std_logic_vector(17 downto 0); 	--RAM1��ַ����
		ram2_addr : out std_logic_vector(17 downto 0); 	--RAM2��ַ����
		ram1_data : inout std_logic_vector(15 downto 0);--RAM1��������
		ram2_data : inout std_logic_vector(15 downto 0);--RAM2��������
		
		ram1_en : out std_logic;		--RAM1ʹ�ܣ�='1'��ֹ����Զ����'1'
		ram1_oe : out std_logic;		--RAM1��ʹ�ܣ�='1'��ֹ����Զ����'1'
		ram1_we : out std_logic;		--RAM1дʹ�ܣ�='1'��ֹ����Զ����'1'
		
		ram2_en : out std_logic;		--RAM2ʹ�ܣ�='1'��ֹ����Զ����'0'
		ram2_oe : out std_logic;		--RAM2��ʹ�ܣ�='1'��ֹ
		ram2_we : out std_logic;		--RAM2дʹ�ܣ�='1'��ֹ
		
		MemoryState : out std_logic_vector(1 downto 0)
	);
end MemoryUnit;

architecture Behavioral of MemoryUnit is
	--signal state : std_logic_vector(1 downto 0) := "00";
	shared variable state : std_logic_vector(1 downto 0) := "01";
	signal stateHigh : std_logic := '0';
	signal stateLow : std_logic := '1';
	
	signal rflag : std_logic := '0';		--rflag='1'����Ѵ��������ߣ�ram1_data���ø��裬���ڽ�ʡ״̬�Ŀ���
begin
	
	--ram1ר��������
	ram1_en <= '1';
	ram1_oe <= '1';
	ram1_we <= '1';
	ram1_addr(17 downto 0) <= (others => '0');
	--ram2��д�ڴ�
	ram2_en <= '0';
	ram2_addr(17 downto 16) <= "00";
	
	process(clk, rst)
	begin
		if (rst = '0') then
			stateHigh <= '0';
		elsif (clk'event and clk = '1') then
			if (stateHigh = '1') then
				stateHigh <= '0';
			else
				stateHigh <= '1';
			end if;
		end if;
	end process;
	
	
	process(clk, rst)
	begin
		if (rst = '0') then
			stateLow <= '1';
		elsif (clk'event and clk = '0') then
			if (stateLow = '1') then
				stateLow <= '0';
			else
				stateLow <= '1';
			end if;
		end if;
	end process;
	
	process(rst, stateHigh, stateLow)
	begin
		if (rst = '0') then
			
			ram2_oe <= '1';
			ram2_we <= '1';
			wrn <= '1';
			rdn <= '1';
			rflag <= '0';
			
			ram1_addr <= (others => '0'); --�ɲ�Ҫ����
			ram2_addr <= (others => '0'); --�ɲ�Ҫ����
			
			dataOut <= (others => '0');
			insOut <= (others => '0');
			
			--state <= "11";
			
		--elsif clk'event and clk = '1' then 
		else
			state := stateHigh & stateLow;
			case state is 
				when "00" =>
					null;
					
				when "10" =>		--׼����ָ��
					ram2_data <= (others => 'Z');
					ram2_addr(15 downto 0) <= PC;
					wrn <= '1';
					rdn <= '1';
					ram2_oe <= '0';
					
					
				when "11" =>		--����ָ�׼����/д ����/�ڴ�
					ram2_oe <= '1';
					insOut <= ram2_data;
					if (MemWrite = '1') then	--���Ҫд
						rflag <= '0';
						if (ramAddr = x"BF00") then 	--׼��д����
							ram1_data(7 downto 0) <= dataIn(7 downto 0);
							wrn <= '0';
						else							--׼��д�ڴ�
							ram2_addr(15 downto 0) <= ramAddr;
							ram2_data <= dataIn;
							ram2_we <= '0';
						end if;
					elsif (MemRead = '1') then	--���Ҫ��
						if (ramAddr = x"BF01") then 	--׼��������״̬
							dataOut(15 downto 2) <= (others => '0');
							dataOut(1) <= data_ready;
							dataOut(0) <= tsre and tbre;
							if (rflag = '0') then	--������״̬ʱ��ζ�Ž���������Ҫ��/д��������
								ram1_data <= (others => 'Z');	--��Ԥ�Ȱ�ram1_data��Ϊ����
								rflag <= '1';	--���������Ҫ�������ֱ�Ӱ�rdn��'0'��ʡһ��״̬��Ҫд����rflag='0'��������д���ڵ�����
							end if;	
						elsif (ramAddr = x"BF00") then	--׼������������
							rflag <= '0';
							rdn <= '0';
						else							--׼�����ڴ�
							ram2_data <= (others => 'Z');
							ram2_addr(15 downto 0) <= ramAddr;
							ram2_oe <= '0';
						end if;
					end if;	
					
					
				when "01" =>		--��/д ����/�ڴ�
					if(MemWrite = '1') then		--д
						if (ramAddr = x"BF00") then		--д����
							wrn <= '1';
						else							--д�ڴ�
							ram2_we <= '1';
						end if;
					elsif(MemRead = '1') then	--��
						if (ramAddr = x"BF01") then		--������״̬���Ѷ�����
							null;
						elsif (ramAddr = x"BF00") then 	--����������
							rdn <= '1';
							dataOut(15 downto 8) <= (others => '0');
							dataOut(7 downto 0) <= ram1_data(7 downto 0);
						else							--���ڴ�
							ram2_oe <= '1';
							dataOut <= ram2_data;
						end if;
					end if;
					
					
				when others =>
					
					
			end case;
		end if;
	end process;
	
	MemoryState <= state;
	
end Behavioral;

