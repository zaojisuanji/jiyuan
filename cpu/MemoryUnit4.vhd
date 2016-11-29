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
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

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
		PCOut : in std_logic_vector(15 downto 0);		--��IMʱ����ַ����
		PCMuxOut : in std_logic_vector(15 downto 0);	
		PCKeep : in std_logic;
		
		dataOut : out std_logic_vector(15 downto 0);	--��DMʱ��������������/�����Ĵ���״̬
		insOut : out std_logic_vector(15 downto 0);		--��IMʱ��������ָ��
		
		ram1_addr : out std_logic_vector(17 downto 0); 	--RAM1��ַ����
		ram2_addr : out std_logic_vector(17 downto 0); 	--RAM2��ַ����
		ram1_data : inout std_logic_vector(15 downto 0);--RAM1��������
		ram2_data : inout std_logic_vector(15 downto 0);--RAM2��������
		
		ram2AddrOutput : out std_logic_vector(17 downto 0);
		
		ram1_en : out std_logic;		--RAM1ʹ�ܣ�='1'��ֹ����Զ����'1'
		ram1_oe : out std_logic;		--RAM1��ʹ�ܣ�='1'��ֹ����Զ����'1'
		ram1_we : out std_logic;		--RAM1дʹ�ܣ�='1'��ֹ����Զ����'1'
		
		ram2_en : out std_logic;		--RAM2ʹ�ܣ�='1'��ֹ����Զ����'0'
		ram2_oe : out std_logic;		--RAM2��ʹ�ܣ�='1'��ֹ
		ram2_we : out std_logic;		--RAM2дʹ�ܣ�='1'��ֹ
		
		MemoryState : out std_logic_vector(1 downto 0);
		FlashStateOut : out std_logic_vector(2 downto 0);
		
		flashFinished : out std_logic := '0';
		
		--Flash
		flash_addr : out std_logic_vector(22 downto 0);		--flash��ַ��
		flash_data : inout std_logic_vector(15 downto 0);	--flash������
		
		flash_byte : out std_logic := '1';	--flash����ģʽ������'1'
		flash_vpen : out std_logic := '1';	--flashд����������'1'
		flash_rp : out std_logic := '1';		--'1'��ʾflash����������'1'
		flash_ce : out std_logic := '0';		--flashʹ��
		flash_oe : out std_logic := '1';		--flash��ʹ�ܣ�'0'��Ч��ÿ�ζ���������'1'
		flash_we : out std_logic := '1'		--flashдʹ��
		
		
		
	);
end MemoryUnit;

architecture Behavioral of MemoryUnit is

	signal state : std_logic_vector(1 downto 0) := "00";	--�ô桢���ڲ�����״̬
	signal rflag : std_logic := '0';		--rflag='1'����Ѵ��������ߣ�ram1_data���ø��裬���ڽ�ʡ״̬�Ŀ���
	
	signal flash_finished : std_logic := '0';
	--type FLASH_STATE is (STATE1, STATE2, STATE3, STATE4, STATE5, STATE6);
	--signal flashstate : FLASH_STATE := STATE1;	--��flash����ָ�ram2��״̬
	signal flashstate : std_logic_vector(2 downto 0) := "000";
	signal current_addr : std_logic_vector(15 downto 0) := (others => '0');	--flash��ǰҪ���ĵ�ַ
	shared variable cnt : integer := 0;	--��������50Mʱ��Ƶ����1M
	
begin
	
	--ram1ר��������
	--ram1_en <= '1';
	--ram1_oe <= '1';
	--ram1_we <= '1';
	--ram1_addr(17 downto 0) <= (others => '0');
	--ram2��д�ڴ�
	--ram2_en <= '0';
	--ram2_addr(17 downto 16) <= "00";
	--flash����
	--flash_byte <= '1';
	--flash_vpen <= '1';
	--flash_rp <= '1';
	--flash_ce <= '0';
	
	process(clk, rst)
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
			
			state <= "00";			--rst֮�ա���
			flashstate <= "000";
			--flash_finished <= '0';
			current_addr <= (others => '0');
			
		elsif (clk'event and clk = '1') then 
			if (flash_finished = '1') then			--��flash����kernelָ�ram2�����
				flash_byte <= '1';
				flash_vpen <= '1';
				flash_rp <= '1';
				flash_ce <= '1';	--��ֹflash
				ram1_en <= '1';
				ram1_oe <= '1';
				ram1_we <= '1';
				ram1_addr(17 downto 0) <= (others => '0');
				ram2_en <= '0';
				ram2_addr(17 downto 16) <= "00";
				ram2_oe <= '1';
				ram2_we <= '1';
				wrn <= '1';
				rdn <= '1';
				
				case state is 
					--when "00" =>
					--	state <= "01";
						
					when "01" =>		--׼����ָ��
						if PCKeep = '0' then
							ram2_addr(15 downto 0) <= PCMuxOut;
						elsif PCKeep = '1' then
							ram2_addr(15 downto 0) <= PCOut;
						end if;
						ram2_data <= (others => 'Z');
						--ram2_addr(15 downto 0) <= PC;
						wrn <= '1';
						rdn <= '1';
						ram2_oe <= '0';
						state <= "10";
						
					when "10" =>		--����ָ�׼����/д ����/�ڴ�
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
						state <= "11";
						
					when "11" =>		--��/д ����/�ڴ�
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
						state <= "00";
						
					when others =>
						state <= "00";
						
				end case;
				
			else				--��flash����kernelָ�ram2��δ��ɣ����������
				if (cnt = 1000) then
					cnt := 0;
					
					case flashstate is
						when "000" =>
							flashstate <= "001";
						
						when "001" =>		--WE��0
							ram2_en <= '0';
							ram2_we <= '0';
							ram2_oe <= '1';
							wrn <= '1';
							rdn <= '1';
							flash_we <= '0';
							flash_oe <= '1';
							
							flash_byte <= '1';
							flash_vpen <= '1';
							flash_rp <= '1';
							flash_ce <= '0';
							
							flashstate <= "010";
							
						when "010" =>
							flash_data <= x"00FF";
							flashstate <= "011";
							
						when "011" =>
							flash_we <= '1';
							flashstate <= "100";
							
						when "100" =>
							flash_addr <= "000000" & current_addr & '0';
							flash_data <= (others => 'Z');
							flash_oe <= '0';
							flashstate <= "101";
							
						when "101" =>
							flash_oe <= '1';
							ram2_we <= '0';
							ram2_addr <= "00" & current_addr;
							ram2AddrOutput <= "00" & current_addr;
							ram2_data <= flash_data;
							flashstate <= "110";
						
						when "110" =>
							ram2_we <= '1';
							current_addr <= current_addr + '1';
							flashstate <= "111";
						
						when "111" =>
							flashstate <= "000";
							
						when others =>
							flashstate <= "000";
						
					end case;
					
					if (current_addr > x"0249") then
						flash_finished <= '1';
					end if;
				else 
					if (cnt < 1000) then
						cnt := cnt + 1;
					end if;
				end if;	--cnt 
				
			end if;	--flash finished or not
			
		end if;	--rst/clk_raise
		
	end process;
	
	
	MemoryState <= state;
	flashFinished <= flash_finished;
	FlashStateOut <= flashstate;
	
	
end Behavioral;

