----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    17:10:05 11/19/2015 
-- Design Name: 
-- Module Name:    cpu - Behavioral 
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

entity cpu is
	port(
			rst : in std_logic; --reset
			clkIn : in std_logic; --ʱ��Դ  Ĭ��Ϊ50M  ����ͨ���޸İ󶨹ܽ����ı�
			
			--����
			dataReady : in std_logic;   
			tbre : in std_logic;
			tsre : in std_logic;
			rdn : inout std_logic;
			wrn : inout std_logic;
			
			--RAM1  �������
			ram1En : out std_logic;
			ram1We : out std_logic;
			ram1Oe : out std_logic;
			ram1Data : inout std_logic_vector(15 downto 0);
			ram1Addr : out std_logic_vector(15 downto 0);
			
			--RAM2 ��ų����ָ��
			ram2En : out std_logic;
			ram2We : out std_logic;
			ram2Oe : out std_logic;
			ram2Data : inout std_logic_vector(15 downto 0);
			ram2Addr : out std_logic_vector(17 downto 0);
			
			--debug  digit1��digit2��ʾPCֵ��led��ʾ��ǰָ��ı���
			digit1 : out std_logic_vector(6 downto 0);
			digit2 : out std_logic_vector(6 downto 0);
			led : out std_logic_vector(15 downto 0);
			
			hs,vs : out std_logic;
			redOut, greenOut, blueOut : out std_logic_vector(2 downto 0)
	);
			
end cpu;

architecture Behavioral of cpu is
	--��������������������
	component MEMu
	    port ( clk 			:	in 	STD_LOGIC;
           rst 			: 	in  STD_LOGIC;
           MEMdata_i	:	in 	STD_LOGIC_VECTOR(15 downto 0);
           MEMaddr 		:	in 	STD_LOGIC_VECTOR(15 downto 0);
           MEMwe 		:	in 	STD_LOGIC;
           MEMre		:	in 	STD_LOGIC;
           --IFce			:	in 	STD_LOGIC;
           IFaddr		:	in 	STD_LOGIC_VECTOR(15 downto 0);
			  data_ready :	in STD_LOGIC;
			  tbre		:	in STD_LOGIC;
			  tsre 		:	in STD_LOGIC;

           Ramoe		:	out STD_LOGIC;
           Ramwe		:	out STD_LOGIC;
           Ramen		:	out STD_LOGIC;
           Ramaddr		:	out STD_LOGIC_VECTOR(17 downto 0);
           IFdata_o		:	out STD_LOGIC_VECTOR(15 downto 0);
           MEMdata_o 	:	out STD_LOGIC_VECTOR(15 downto 0);
			  ram1oe			:	out STD_LOGIC;
			  ram1we			:	out STD_LOGIC;
			  ram1en 		:	out STD_LOGIC;
			  ram1data		:	inout STD_LOGIC_VECTOR(7 downto 0);
			  wrn 			:	out STD_LOGIC;
			  rdn 			:	out STD_LOGIC;
           Ramdata		:	inout STD_LOGIC_VECTOR(15 downto 0)
        );
	end component;
	

	--ʱ�ӣ�������������������
	component Clock
	port(
		rst : in std_logic;
		clkIn : in std_logic;
		
		clk_8 : out std_logic;
		clk_15 : out std_logic
	);
	end component;
	
	
	--ALU������
	component ALU
	port(
		Asrc       	 :  in STD_LOGIC_VECTOR(15 downto 0);
		Bsrc       	 :  in STD_LOGIC_VECTOR(15 downto 0);
		ALUop		  	 :  in STD_LOGIC_VECTOR(3 downto 0);
		ALUresult  	 :  out STD_LOGIC_VECTOR(15 downto 0) := "0000000000000000"; -- Ĭ����Ϊȫ0
		BranchJudge  :  out STD_LOGIC
		);
	end component;
	
	--ѡ������ALU�ĵ�һ��������
	component AMux
	port(
		--�����ź�
		ForwardA : in std_logic_vector(1 downto 0);
		--��ѡ������
		ReadData1 : in std_logic_vector(15 downto 0);
		ExMemALUResult : in std_logic_vector(15 downto 0);	--����ָ���ALU���
		MemWbALUResult : in std_logic_vector(15 downto 0);	--������ָ���ALU���
		MemWbMemResult : in std_logic_vector(15 downto 0);	--������ָ��Ķ�DM���
		--ѡ�������
		AsrcOut : out std_logic_vector(15 downto 0)
	);
	end component;
	
	--ѡ������ALU�ĵڶ���������
	component BMux
	port(
		--�����ź�
		ForwardB : in std_logic_vector(1 downto 0);
		ALUSrcB  : in std_logic_vector(1 downto 0);
		--��ѡ������
		ReadData2 : in std_logic_vector(15 downto 0);
		imme 	    : in std_logic_vector(15 downto 0);
		ExMemALUResult : in std_logic_vector(15 downto 0);	--����ָ���ALU���
		MemWbALUResult : in std_logic_vector(15 downto 0);	--������ָ���ALU���
		MemWbMemResult : in std_logic_vector(15 downto 0);	--������ָ��Ķ�DM���
		--ѡ�������
		BsrcOut : out std_logic_vector(15 downto 0)
	);	
	end component;
	
	
	--�������п����źŵĿ�����
	component Controller
	port(	
		commandIn : in std_logic_vector(15 downto 0);
		rst : in std_logic;
		controllerOut :  out std_logic_vector(20 downto 0)
		-- RegWrite(1) RegDst(3) ReadReg1(3) ReadReg2(1) immeSelect(3) ALUSrcB(1) 
		-- ALUOp(4) MemRead(1) MemWrite(1) MemToReg(1) jump(1) MFPC(1)
	);
	end component;
	
	--ѡ����PC�ĵ�Ԫ
	component PCMux
	port(
		PCAddOne : in std_logic_vector(15 downto 0);	 --PC+1
		IdEXEimme : in std_logic_vector(15 downto 0); --���ڼ���Branch��ת��PCֵ=IdEXEimme+PC+1
		AsrcOut : in std_logic_vector(15 downto 0);	 --����JRָ���ת��ַΪASrcOut
		
		jump : in std_logic;					--jump�����ܿ�����Controller�������ź�
		BranchJudge : in std_logic;		--����ALU�����Ŀ����źţ���ʾB����ת�ɹ�
		
		PCOut : out std_logic_vector(15 downto 0)
	);
	end component;
	
	--��MFPCָ���PC+1��ALUResult��ѡ��
	component MFPCMux
	port(
		PCAddOne  : in std_logic_vector(15 downto 0);	
		ALUResult : in std_logic_vector(15 downto 0);
		MFPC		 : in std_logic;
		
		MFPCMuxOut : out std_logic_vector(15 downto 0)
	);
	
	
	--EX/MEM�׶μĴ���
	component ExMemRegisters
	port(
		clk : in std_logic;
		rst : in std_logic;
		
		readData1In : in std_logic_vector(15 downto 0);
		readData2In : in std_logic_vector(15 downto 0);
		rdIn : in std_logic_vector(3 downto 0);
		PCIn : in std_logic_vector(15 downto 0);
		ALUResultIn : in std_logic_vector(15 downto 0);
		
		readData2In : in std_logic_vector(15 downto 0); --��SW���д�ڴ�
		
		regWriteIn : in std_logic;
		memReadIn : in std_logic;
		memWriteIn : in std_logic;
		memToRegIn : in std_logic;
		--dataSrcIn : in std_logic;
		
		--wbKeep : in std_logic;

		rdOut : out std_logic_vector(3 downto 0);
		PCOut : out std_logic_vector(15 downto 0);
		ALUResultOut : out std_logic_vector(15 downto 0);
		
		readData2Out : out std_logic_vector(15 downto 0); --��SW���д�ڴ�
		
		regWriteOut : out std_logic;
		memReadOut : out std_logic;
		memWriteOut : out std_logic;
		memToRegOut : out std_logic;
		--dataOut : out std_logic_vector(15 downto 0)
	);
	end component;
	
	--ת����Ԫ
	component ForwardController
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
	end component;
	
	--LW���ݳ�ͻ���Ƶ�Ԫ
	component HazardDetectionUnit
	port(
		ExMemRd : in std_logic_vector(3 downto 0);
		ExMemMemRead : in std_logic;
		
		IdExeReg1 : in std_logic_vector(3 downto 0);
		IdExeReg2 : in std_logic_vector(3 downto 0);
		
		PCKeep : out std_logic;
		IfIdKeep : out std_logic;
		IdExFlush : out std_logic
		
	);
	end component;
	
	--ID/EX�׶μĴ���
	component IdExRegisters
	port(
		clk : in std_logic;
		rst : in std_logic;
		
		IdExFlush : in std_logic;		--LW���ݳ�ͻ��
		
		PCIn : in std_logic_vector(15 downto 0);
		rdIn : in std_logic_vector(3 downto 0);	
		ReadReg1In : in std_logic_vector(3 downto 0);
		ReadReg2In : in std_logic;
		--ASrcIn : in std_logic_vector(2 downto 0);
		--BSrcIn : in std_logic_vector(1 downto 0);
		ALUSrcBIn : in std_logic;
		
		ReadData1In : in std_logic_vector(15 downto 0);
		ReadData2In : in std_logic_vector(15 downto 0);			
		--dataTIn : in std_logic_vector(15 downto 0);
		--dataIHIn : in std_logic_vector(15 downto 0);
		--dataSPIn : in std_logic_vector(15 downto 0);
		immeIn : in std_logic_vector(15 downto 0);
		
		--WriteKeep : in std_logic;
		MFPCIn : in std_logic;
		
		regWriteIn : in std_logic;
		memWriteIn : in std_logic;
		memReadIn : in std_logic;
		memToRegIn : in std_logic;
		jumpIn : in std_logic;
		ALUOpIn : in std_logic_vector(3 downto 0);
		--dataSrcIn : in std_logic;
	
		PCOut : out std_logic_vector(15 downto 0);
		rdOut : out std_logic_vector(3 downto 0);
		ReadReg1Out : out std_logic_vector(3 downto 0);
		ReadReg2Out : out std_logic;
		--ASrcOut : out std_logic_vector(2 downto 0);
		--BSrcOut : out std_logic_vector(1 downto 0);
		ALUSrcBOut : out std_logic;
		
		ReadData1Out : out std_logic_vector(15 downto 0);
		ReadData2Out : out std_logic_vector(15 downto 0);			
		--dataTOut : out std_logic_vector(15 downto 0);
		--dataIHOut : out std_logic_vector(15 downto 0);
		--dataSPOut : out std_logic_vector(15 downto 0);
		immeOut : out std_logic_vector(15 downto 0);
		
		MFPCOut : out std_logic;
		
		regWriteOut : out std_logic;
		memWriteOut : out std_logic;
		memReadOut : out std_logic;
		memToRegOut : out std_logic;
		jumpOut : out std_logic;
		ALUOpOut : out std_logic_vector(3 downto 0);
		--dataSrcOut : out std_logic
	);
	end component;
	
	--IF/ID�׶μĴ���
	component IfIdRegisters
	port(
		rst : in std_logic;
		clk : in std_logic;
		commandIn : in std_logic_vector(15 downto 0);
		PCIn : in std_logic_vector(15 downto 0); 
		IfIdKeep : in std_logic;		--LW���ݳ�ͻ��
		IfIdFlush : in std_logic;		--��תʱ��
		
		rx : out std_logic_vector(2 downto 0);		--Command[10:8]
		ry : out std_logic_vector(2 downto 0);		--Command[7:5]
		rz : out std_logic_vector(2 downto 0);		--Command[4:2]
		imme_10_0 : out std_logic_vector(10 downto 0);	--Command[10:0]
		commandOut : out std_logic_vector(15 downto 0);
		PCOut : out std_logic_vector(15 downto 0)  --PC+1����MFPCָ���EXE��
	);
	end component;
	
	--��������չ��Ԫ
	component ImmeExtendUnit
	port(
		 immeIn : in std_logic_vector(10 downto 0);		--ȡָ���[10:0]λ����Ϊ���ܵ�����������
		 immeSelect : in std_logic_vector(2 downto 0);  --���ܿ�����Controller����
		 
		 immeOut : out std_logic_vector(15 downto 0)		--��չ���������
	);
	end component;
	
	--MEM/WB�׶μĴ���
	component MemWbRegisters
		port(
			clk : in std_logic;
			rst : in std_logic;
			
			readMemDataIn : in std_logic_vector(15 downto 0);
			ALUResultIn : in std_logic_vector(15 downto 0);
			rdIn : in std_logic_vector(3 downto 0);
			
			regWriteIn : in std_logic;
			memToReg : in std_logic;
			
			rdOut : out std_logic_vector(3 downto 0);
			regWriteOut : out std_logic;
			dataToWB : out std_logic_vector(15 downto 0)
		);
	end component;
	
	--PC�ӷ��� ʵ��PC+1
	component PCAdder
		port( 
			adderIn : in std_logic_vector(15 downto 0);
			adderOut : out std_logic_vector(15 downto 0)
		);
	end component;
	
	--PC�Ĵ�����������
	component PCRegister
		port(	
			rst,clk : in std_logic;
			PCKeep : in std_logic;		--��HazardDetectionUnit�����Ŀ����ź�
			PCIn : in std_logic_vector(15 downto 0);		--ȡPCMux�����ֵ��ѡ������PCֵ��
			PCOut : out std_logic_vector(15 downto 0)		--�͸�IMȥȡָ��PC
		);
	end component;
	
	--Դ�Ĵ���1ѡ����
	component ReadReg1Mux
		port(
			rx : in std_logic_vector(2 downto 0);
			ry : in std_logic_vector(2 downto 0);			--R0~R7�е�һ��
			
			ReadReg1 : in std_logic_vector(2 downto 0);		--���ܿ�����Controller���ɵĿ����ź�
			
			ReadReg1Out : out std_logic_vector(3 downto 0)  --"0XXX"����R0~R7��"1000"=SP,"1001"=IH, "1010"=T, "1111"=û��
		);
	end component;
	
	--Դ�Ĵ���2ѡ����
	component RdMux
		port(
			rx : in std_logic_vector(2 downto 0);
			ry : in std_logic_vector(2 downto 0);			--R0~R7�е�һ��
			
			ReadReg2 : in std_logic_vector;					--���ܿ�����Controller���ɵĿ����ź�
			
			ReadReg2Out : out std_logic_vector(3 downto 0)  --"0XXX"����R0~R7, "1111"=û��
		);
	end component;
	
	--Ŀ�ļĴ���ѡ����
	component RdMux
		port(
			rx : in std_logic_vector(2 downto 0);
			ry : in std_logic_vector(2 downto 0);
			rz : in std_logic_vector(2 downto 0);			--R0~R7�е�һ��
			
			RegDst : in std_logic_vector(2 downto 0);		--���ܿ�����Controller���ɵĿ����ź�
			
			rdOut : out std_logic_vector(3 downto 0)		--"0XXX"����R0~R7��"1000"=SP,"1001"=IH, "1010"=T, "1111"=û��
		);
	end component;
	
	--�Ĵ����ѣ�������
	component Registers
		port(
			clk : in std_logic;
			rst : in std_logic;
			
			ReadReg1In : in std_logic_vector(3 downto 0);  --"0XXX"����R0~R7��"1000"=SP,"1001"=IH, "1010"=T
			ReadReg2In : in std_logic_vector(3 downto 0);  --"0XXX"����R0~R7
			
			WriteReg : in std_logic_vector(3 downto 0);	  --��WB�׶δ��أ�Ŀ�ļĴ���
			WriteData : in std_logic_vector(15 downto 0);  --��WB�׶δ��أ�дĿ�ļĴ�����ֵ
			RegWrite : in std_logic;							  --��WB�׶δ��أ�RegWrite��дĿ�ļĴ����������ź�
			
			--r0Out, r1Out, r2Out,r3Out,r4Out,r5Out,r6Out,r7Out : out std_logic_vector(15 downto 0);
			
			ReadData1 : out std_logic_vector(15 downto 0); --�����ļĴ���1��ֵ
			ReadData2 : out std_logic_vector(15 downto 0); --�����ļĴ���2��ֵ

		);
	end component;
	
	
	--���µ�signal���ǡ�ȫ�ֱ�����
	
	
	--clock
	signal clk : std_logic;
	signal clk_8 : std_logic;
	
	--PCRegister
	signal PCOut : std_logic_vector(15 downto 0); 
	
	--PCAdder
	signal AddedPC : std_logic_vector(15 downto 0);
	
	--IfIdRegisters
	signal rx1, ry1, rz1 :std_logic_vector(2 downto 0);
	signal imm_10_0 : std_logic_vector(10 downto 0);
	signal IfIdCommand, IfIdPC : std_logic_vector(15 downto 0);
	
	--RdMux
	signal rdMuxOut : std_logic_vector(3 downto 0);
	
	--controller
	signal immChoose : std_logic_vector(2 downto 0);
	signal controllerOut : std_logic_vector(20 downto 0);
	
	--Registers
	signal dataA1, dataB1, dataT1, dataSP1, dataIH1 : std_logic_vector(15 downto 0);
	signal r0,r1,r2,r3,r4,r5,r6,r7 : std_logic_vector(15 downto 0);
	--ImmExtend
	signal extendedImm : std_logic_vector(15 downto 0);
	
	--IdExRegisters
	signal IdExPC : std_logic_vector(15 downto 0);
	signal IdExRd : std_logic_vector(3 downto 0);
	signal rx2,ry2 : std_logic_vector(2 downto 0);
	signal ASrc : std_logic_vector(2 downto 0);
	signal BSrc : std_logic_vector(1 downto 0);
	signal dataA2,dataB2,dataT2,dataIH2,dataSP2 : std_logic_vector(15 downto 0);
	signal imm2 : std_logic_vector(15 downto 0);
	signal IdExWB,IdExMemWrite,IdExMemRead,IdExMemToReg,IdExBranch,IdExDataSrc,IdExJump : std_logic;
	signal IdExALUOP : std_logic_vector(3 downto 0);
	
	--ExMemRegisters
	signal ExMemData : std_logic_vector(15 downto 0);
	signal ExMemRd : std_logic_vector(3 downto 0);
	signal ExMemRegWrite : std_logic;
	signal ExMemPC, ExMemAns : std_logic_vector(15 downto 0);
	signal ExMemBranch, ExMemBJ : std_logic;
	signal ExMemRead, ExMemWrite, ExMemToReg: std_logic;
	
	--ForwardController
	signal ForwardA, ForwardB, ForwardX, ForwardY : std_logic_vector(1 downto 0);
	
	--MemWbRegisters
	signal WbRd : std_logic_vector(3 downto 0);
	signal WbData : std_logic_vector(15 downto 0);
	signal WB : std_logic;
	
	--AMux
	signal AMuxOut : std_logic_vector(15 downto 0);
	
	--BMux
	signal BMuxOut : std_logic_vector(15 downto 0);
	
	--ALU
	signal ALUAns : std_logic_vector(15 downto 0);
	signal ALUBJ : std_logic;
	
	--ExAdder&BranchMux
	signal BranchPC : std_logic_vector(15 downto 0);
	
	--PCMux
	signal PCMuxOut : std_logic_vector(15 downto 0);
	
	--ConflictController
	signal PCKeep : std_logic;
	signal IfIdKeep : std_logic;
	signal WriteKeep : std_logic;
	signal IfIdFlush : std_logic;
	signal IdExFlush : std_logic;
	signal ExMemFlush :  std_logic;
	--IO
	signal ioCommand : std_logic_vector(15 downto 0);
	signal ioData : std_logic_vector(15 downto 0);
	--stage
	signal stageA : std_logic_vector(15 downto 0);
	signal stageB : std_logic_vector(15 downto 0);
	
	--digit rom
	signal digitRomAddr : std_logic_vector(14 downto 0);
	signal digitRomData : std_logic_vector(23 downto 0);
	
	--font rom
	signal fontRomAddr : std_logic_vector(10 downto 0);
	signal fontRomData : std_logic_vector(7 downto 0);
begin
	u1 : PCRegister
	port map(	rst => rst,
			clk => clk,
			PCKeep => PCKeep,
			PCIn => PCMuxOut,
			PCOut => PCOut
	);
		
	u2 : PCAdder
	port map( 
			adderIn => PCOut,
			adderOut => AddedPC
	);
		
	u3 : 	IfIdRegisters
	port map(
			rst => rst,
			clk => clk,
			commandIn => ioCommand,
			PCIn => AddedPc,
			IfIdKeep => IfIdKeep,
			IfIdFlush => IfIdFlush,
			
			rx => rx1,
			ry => ry1,
			rz => rz1,
			imm_10_0 => imm_10_0,
					
			commandOut => IfIdCommand,
			PCOut => IfIdPC
		);
		
	u4 : RdMux
	port map(
			rx => rx1,
			ry => ry1,
			rz => rz1,
			
			rdChoose => controllerOut(17 downto 15),
			
			rdOut => rdMuxOut
		);
		
	u5 : Controller
	port map(	commandIn => IfIdCommand,
			rst => rst,
			imm => immChoose,
			controllerOut => controllerOut
			-- RegWrite(1)	SpeReg(2) RegDst(3) Asrc(3) Bsrc(2) ALUOP(4) 
			-- MemRead(1) MemWrite(1) MemToReg(1)  branch(1) jump(1) dataSrc(1)
		);
		
	u6 : Registers
	port map(
			clk => clk,
			rst => rst,
			
			rx => rx1,
			ry => ry1,
			
			WbRd => WbRd,
			WbData => WbData,
			WB => WB,
			
			r0Out => r0,
			r1Out => r1,
			r2Out => r2,
			r3Out => r3,
			r4Out => r4,
			r5Out => r5,
			r6Out => r6,
			r7Out => r7,
			
			dataA => dataA1,
			dataB => dataB1,
			dataT => dataT1,
			dataSP => dataSP1,
			dataIH => dataIH1
		);
		
	u7 : ImmExtend
	port map(
			 immIn => imm_10_0,
			 immSele => immChoose,
			 
			 immOut => extendedImm
		);
		
	u8 : IdExRegisters
	port map(
			clk => clk,
			rst => rst,
			
			IdExFlush => IdExFlush,
			
			PCIn => IfIdPC,
			rdIn => rdMuxOut,
			rxIn => rx1,
			ryIn => ry1,
			ASrcIn => controllerOut(14 downto 12),
			BSrcIn => controllerOut (11 downto 10),
			
			dataAIn => dataA1,
			dataBIn => dataB1,
			dataTIn => dataT1,
			dataIHIn => dataIH1,
			dataSPIn => dataSP1,
			immIn => extendedImm,
			
			WriteKeep => WriteKeep,
			
			WBIn => controllerOut(20),
			memWriteIn => controllerOut(4),
			memReadIn => controllerOut(5),
			memToRegIn => controllerOut(3),
			branchIn => controllerOut(2),
			jumpIn => controllerOut(1),
			ALUOpIn => controllerOut(9 downto 6),
			dataSrcIn => controllerOut(0),
		
			PCOut => IdExPC,
			rdOut => IdExRd,
			rxOut => rx2,
			ryOut => ry2,
			ASrcOut => ASrc,
			BSrcOut => BSrc,
			
			dataAOut => dataA2,
			dataBOut => dataB2,
			dataTOut => dataT2,
			dataIHOut => dataIH2,
			dataSPOut => dataSP2,
			immOut => imm2,
			
			WBOut => IdExWB,
			memWriteOut => IdExMemWrite,
			memReadOut => IdExMemRead,
			memToRegOut => IdExMemToReg,
			branchOut => IdExBranch,
			jumpOut => IdExJump,
			ALUOpOut => IdExALUOP,
			dataSrcOut => IdExDataSrc
		);
		
	u9 : AMux
		port map(
			forwardA => ForwardA,
			forwardB => ForwardB,
			ASrc => ASrc,
			
			dataA => dataA2,
			dataB => dataB2,
			dataT => dataT2,
			dataIH => dataIH2,
			dataSP => dataSP2,
			PCIn => IdExPC,
			imm => imm2,
			
			dataEx => ExMemAns,
			dataMem => WbData,
			
			AsrcOut => AMuxOut
		);
		
	u10 : BMux
	port map(
			forwardA => ForwardA,
			forwardB => ForwardB,
			BSrc => BSrc,
			
			dataA => dataA2,
			dataB => dataB2,
			imm => imm2,
			
			dataEx => ExMemAns,
			dataMem => WbData,
			
			BsrcOut => BMuxOut
		);	
		
	u11 : ForwardController
	port map(
			ExMemRd => ExMemRd,
			MemWbRd => WbRd,
			
			ExMemRegWrite => ExMemRegWrite,
			MemWbRegWrite => WB,
			
			IdExAsrc => ASrc,
			IdExBsrc => Bsrc,
			
			IdExRx => rx2,
			IdExRy => ry2,
			
			ForwardA => ForwardA,
			ForwardB => ForWardB,
			
			ForwardX => ForwardX,
			ForwardY => ForwardY
		);
	
	u12 : ALU
	port map(
		Asrc      	=> AMuxOut,
		Bsrc        => BMuxOut,
		ALUop		  	=> IdExALUOP,
		ALUresult  	=> ALUAns,
		branchJudge => ALUBJ
	);
	
	u13 : ExAdderAndBranchMux
	port map(
			PCIn => IdExPC,
			imm => imm2,
			dataA => DataA2,
			--dataA => stageA,
			
			jump => IdExJump,
			
			PCOut => BranchPC
		);
	
	u14 : ExMemRegisters
	port map(
			clk => clk,
			rst => rst,
			
			--dataAIn => DataA2,
			--dataBIn => DataB2,
			dataAIn => stageA,
			dataBIn => stageB,
			
			rdIn => IdExRd,
			PCIn => BranchPC,
			ansIn => ALUAns,
			branchIn => IdExBranch,
			branchJudgeIn => ALUBJ,
			
			WBIn => IdExWb,
			memReadIn => IdExMemRead,
			memWriteIn => IdExMemWrite,
			memToRegIn => IdExMemToReg,
			dataSrcIn => IdExDataSrc,
			
			wbKeep => ExMemFlush,
			
			rdOut => ExMemRd,
			PCOut => ExMemPC,
			ansOut => ExMemAns,
			branchOut => ExMemBranch,
			branchJudgeOut => ExMemBJ,
			
			WBOut => ExMemRegWrite,
			memReadOut => ExMemRead,
			memWriteOut => ExMemWrite,
			memToRegOut => ExMemToReg,
			dataOut => ExMemData
		);
	
	u15 : MemWbRegisters
	port map(
			clk => clk,
			rst => rst,
			
			dataIn => ioData,
			ansIn => ExMemAns,
			rdIn => ExMemRd,
			
			WBIn => ExMemRegWrite,
			memToReg => ExMemToReg,
			
			rdOut => WbRd,
			WBOut => WB,
			dataToWB => WbData
		);
	 u16 : ConflictController
	 port map(
			rst => rst,
			clk => clk,
			branch => ExMemBranch,
			branchJudge => ExMemBj,
			
			IdExMemRead => IdExMemRead,
			IdExRd => IdExRd,
			
			IfIdRx => rx1,
			IfIdRy => ry1,
			IfIdASrc => controllerOut(14 downto 12),
			IfIdBSrc => controllerOut(11 downto 10),
			IfIdMemWrite => controllerOut(4),
			
			PCKeep => PCKeep,
			IfIdKeep => IfIdKeep,
			IfIdFlush => IfIdFlush,
			IdExFlush => IdExFlush,
			WriteKeep => WriteKeep,
			ExMemFlush => ExMemFlush
		);
		
	u17 : PCMux
	port map( 
			branch => ExMemBranch,
			branchJudge => ExMemBJ,
			PCAdd => AddedPC,
			PCJump => ExMemPC,
			
			PCNext => PCMuxOut
		);
	
--	u18 : IO
--	port map(
	--	rst => rst,
	--	clk 			=> clkIn,
	--	MemWrite		=> ExMemWrite,
	--	MemRead		=> ExMemRead,
	--	ram_data		=> ExMemData,
		--ram_data => "0000000001001111",
	--	ram_addr		=> ExMemAns,
	--	ins_addr 	=> PcOut,
	--	data_out		=> ioData,
	--	ins_out 		=> ioCommand,
	--	tbre			=> tbre,
	--	tsre			=> tsre,
	--	rdn 			=> rdn,
	--	wrn			=> wrn,
	--	ram1_en 		=> ram1En,
	--	ram1_oe		=> ram1Oe,
	--	ram1_we		=> ram1We,
	--	ram1_addr	=> ram1Addr,
	--	ram1_data	=> ram1Data,
	--	ram2_en	   => ram2En,
	--	ram2_oe		=> ram2Oe,
	--	ram2_we		=> ram2We,
	--	ram2_addr	=> ram2Addr,
	--	ram2_data	=> ram2Data,
	--	data_ready	=> dataReady
	--);
	u18 : MEMU
	    Port map( 
			clk 		 => clkIn,
           rst   	 => rst,
           MEMdata_i	=>ExMemData,
           MEMaddr 	=> ExMemAns,
           MEMwe 		=> ExMemWrite,
           MEMre		=> ExMemRead,
           --IFce			:	in 	STD_LOGIC;
           IFaddr		=> PcOut,
			  data_ready => dataReady,
			  tbre		=> tbre,
			  tsre 		=> tsre,

           Ramoe		=> ram2Oe,
           Ramwe		=> ram2We,
           Ramen		=> ram2En,
           Ramaddr	=> ram2Addr,
           IFdata_o	=> ioCommand,
           MEMdata_o => ioData,
			  ram1oe		=> ram1Oe,
			  ram1we		=> ram1We,
			  ram1en 	=> ram1En,
			  ram1data	=> ram1Data( 7 downto 0),
			  wrn 		=> wrn,
			  rdn 		=> rdn,
           Ramdata	=> ram2Data
        );

	u19 : Clock
	port map(
		rst => rst,
		clkIn => clkIn,
		
		clk_8 => clk_8,
		clk_15 => clk
	);
	
	
	u20 : StageDataUnit
	port map(
			dataAIn => dataA2,
			dataBIn => dataB2,
			
			forwardA => ForwardX,
			forwardB => ForwardY,
			
			dataEx => ExMemAns,
			dataMem => WbData,
			
			dataAOut => stageA,
			dataBOut => stageB
	);

	u21 : VGA_Controller
	port map(
	--VGA Side
		hs => hs,
		vs => vs,
		oRed => redOut,
		oGreen => greenOut,
		oBlue	=> blueOut,
	--RAM side
--		R,G,B	: in  std_logic_vector (9 downto 0);
--		addr	: out std_logic_vector (18 downto 0);
	-- data
		r0 => r0,
		r1 => r1,
		r2 => r2,
		r3 => r3,
		r4 => r4,
		r5 => r5,
		r6 => r6,
		r7 => r7,
	--font rom
		romAddr => fontRomAddr,
		romData => fontRomdata,
	--pc
		pc => PCOut,
		cm => ioCommand,
		tdata => dataT1(3 downto 0),
	--Control Signals
		reset	=> rst,
		CLK_in => clkIn
	);		
	--r0 <= "0110101010010111";
	--r1 <= "1011100010100110";
	u22 : digit
	port map(
			clkA => clkIn,
			addra => digitRomAddr,
			douta => digitRomData
	);
	
	u23 : fontRom
	port map(
		clka => clkIn,
		addra => fontRomAddr,
		douta => fontRomData
		);
		
	led <=wbdata;
	--jing <= PCOut;
	process(PCOut)
		begin
		case PCOut(7 downto 4) is
			when "0000" => digit1 <= "0111111";--0
			when "0001" => digit1 <= "0000110";--1
			when "0010" => digit1 <= "1011011";--2
			when "0011" => digit1 <= "1001111";--3
			when "0100" => digit1 <= "1100110";--4
			when "0101" => digit1 <= "1101101";--5
			when "0110" => digit1 <= "1111101";--6
			when "0111" => digit1 <= "0000111";--7
			when "1000" => digit1 <= "1111111";--8
			when "1001" => digit1 <= "1101111";--9
			when "1010" => digit1 <= "1110111";--A
			when "1011" => digit1 <= "1111100";--B
			when "1100" => digit1 <= "0111001";--C
			when "1101" => digit1 <= "1011110";--D
			when "1110" => digit1 <= "1111001";--E
			when "1111" => digit1 <= "1110001";--F
			when others => digit1 <= "0000000";
		end case;
		
		case PCOut(3 downto 0) is
			when "0000" => digit2 <= "0111111";--0
			when "0001" => digit2 <= "0000110";--1
			when "0010" => digit2 <= "1011011";--2
			when "0011" => digit2 <= "1001111";--3
			when "0100" => digit2 <= "1100110";--4
			when "0101" => digit2 <= "1101101";--5
			when "0110" => digit2 <= "1111101";--6
			when "0111" => digit2 <= "0000111";--7
			when "1000" => digit2 <= "1111111";--8
			when "1001" => digit2 <= "1101111";--9
			when "1010" => digit2 <= "1110111";--A
			when "1011" => digit2 <= "1111100";--B
			when "1100" => digit2 <= "0111001";--C
			when "1101" => digit2 <= "1011110";--D
			when "1110" => digit2 <= "1111001";--E
			when "1111" => digit2 <= "1110001";--F
			when others => digit2 <= "0000000";
		end case;
	end process;
	ram1Addr <= (others => '0');
end Behavioral;

