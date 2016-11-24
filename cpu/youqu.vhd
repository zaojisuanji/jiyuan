--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   17:22:28 11/24/2016
-- Design Name:   
-- Module Name:   D:/Junior/ComputerOrganization/CPU/jiyuan/cpu/youqu.vhd
-- Project Name:  cpu
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: cpu
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY youqu IS
END youqu;
 
ARCHITECTURE behavior OF youqu IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT cpu
    PORT(
         rst : IN  std_logic;
         clkIn : IN  std_logic;
         dataReady : IN  std_logic;
         tbre : IN  std_logic;
         tsre : IN  std_logic;
         rdn : INOUT  std_logic;
         wrn : INOUT  std_logic;
         ram1En : OUT  std_logic;
         ram1We : OUT  std_logic;
         ram1Oe : OUT  std_logic;
         ram1Data : INOUT  std_logic_vector(15 downto 0);
         ram1Addr : OUT  std_logic_vector(17 downto 0);
         ram2En : OUT  std_logic;
         ram2We : OUT  std_logic;
         ram2Oe : OUT  std_logic;
         ram2Data : INOUT  std_logic_vector(15 downto 0);
         ram2Addr : OUT  std_logic_vector(17 downto 0);
         digit1 : OUT  std_logic_vector(6 downto 0);
         digit2 : OUT  std_logic_vector(6 downto 0);
         led : OUT  std_logic_vector(15 downto 0);
         hs : OUT  std_logic;
         vs : OUT  std_logic;
         redOut : OUT  std_logic_vector(2 downto 0);
         greenOut : OUT  std_logic_vector(2 downto 0);
         blueOut : OUT  std_logic_vector(2 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal rst : std_logic := '0';
   signal clkIn : std_logic := '0';
   signal dataReady : std_logic := '0';
   signal tbre : std_logic := '0';
   signal tsre : std_logic := '0';

	--BiDirs
   signal rdn : std_logic;
   signal wrn : std_logic;
   signal ram1Data : std_logic_vector(15 downto 0);
   signal ram2Data : std_logic_vector(15 downto 0);

 	--Outputs
   signal ram1En : std_logic;
   signal ram1We : std_logic;
   signal ram1Oe : std_logic;
   signal ram1Addr : std_logic_vector(17 downto 0);
   signal ram2En : std_logic;
   signal ram2We : std_logic;
   signal ram2Oe : std_logic;
   signal ram2Addr : std_logic_vector(17 downto 0);
   signal digit1 : std_logic_vector(6 downto 0);
   signal digit2 : std_logic_vector(6 downto 0);
   signal led : std_logic_vector(15 downto 0);
   signal hs : std_logic;
   signal vs : std_logic;
   signal redOut : std_logic_vector(2 downto 0);
   signal greenOut : std_logic_vector(2 downto 0);
   signal blueOut : std_logic_vector(2 downto 0);

   -- Clock period definitions
   constant clkIn_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: cpu PORT MAP (
          rst => rst,
          clkIn => clkIn,
          dataReady => dataReady,
          tbre => tbre,
          tsre => tsre,
          rdn => rdn,
          wrn => wrn,
          ram1En => ram1En,
          ram1We => ram1We,
          ram1Oe => ram1Oe,
          ram1Data => ram1Data,
          ram1Addr => ram1Addr,
          ram2En => ram2En,
          ram2We => ram2We,
          ram2Oe => ram2Oe,
          ram2Data => ram2Data,
          ram2Addr => ram2Addr,
          digit1 => digit1,
          digit2 => digit2,
          led => led,
          hs => hs,
          vs => vs,
          redOut => redOut,
          greenOut => greenOut,
          blueOut => blueOut
        );

   -- Clock process definitions
   clkIn_process :process
   begin
		clkIn <= '0';
		wait for 10ns;
		clkIn <= '1';
		wait for 10ns;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for 100 ns;	

      wait for clkIn_period*10;

      -- insert stimulus here 
i
      wait;
   end process;

END;
