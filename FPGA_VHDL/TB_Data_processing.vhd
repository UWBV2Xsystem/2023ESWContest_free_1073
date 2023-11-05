
-- VHDL Test Bench Created from source file Data_processing.vhd -- Mon Oct 23 02:23:21 2023

--
-- Notes: 
-- 1) This testbench template has been automatically generated using types
-- std_logic and std_logic_vector for the ports of the unit under test.
-- Lattice recommends that these types always be used for the top-level
-- I/O of a design in order to guarantee that the testbench will bind
-- correctly to the timing (post-route) simulation model.
-- 2) To use this template as your testbench, change the filename to any
-- name of your choice with the extension .vhd, and use the "source->import"
-- menu in the ispLEVER Project Navigator to import the testbench.
-- Then edit the user defined section below, adding code to generate the 
-- stimulus for your design.
-- 3) VHDL simulations will produce errors if there are Lattice FPGA library 
-- elements in your design that require the instantiation of GSR, PUR, and
-- TSALL and they are not present in the testbench. For more information see
-- the How To section of online help.  
--
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

ENTITY TB_DP IS end;

ARCHITECTURE BEH OF TB_DP IS 

	COMPONENT Data_processing
	PORT(
		nRST				: in std_logic;
		CLK					: in std_logic;
		data_pdoa			: in std_logic_vector(7 downto 0);	
		valid_pdoa			: in std_logic;
		
		data_out			: out std_logic_vector(31 downto 0);		
		start_sig			: out std_logic_vector(1 downto 0)
		);
	END COMPONENT;

	SIGNAL nRST 		:  std_logic;
	SIGNAL CLK 			:  std_logic;
	SIGNAL data_pdoa 	:  std_logic_vector(7 downto 0);
	SIGNAL valid_pdoa 	:  std_logic;
	SIGNAL data_out 	:  std_logic_vector(31 downto 0);
	SIGNAL start_sig 	:  std_logic_vector(1 downto 0);

	signal CLK_cnt 		: std_logic_vector(10 downto 0);

BEGIN

-- Please check and add your generic clause manually
	uut: Data_processing PORT MAP(
		nRST => nRST,
		CLK => CLK,
		data_pdoa => data_pdoa,
		valid_pdoa => valid_pdoa,
		data_out => data_out,
		start_sig => start_sig
	);


	process
	begin
		CLK <= '0', '1' after 2.08 ns;
		wait for 4.16 ns;
	end process;

	process
	begin
		if (NOW = 0 ns) then
			nRST <= '0', '1' after 50 ns;
		end if;
	wait for 1 sec;
	end process;

	process(nRST, CLK)
	begin
		if ( nRST = '0') then
			CLK_cnt <= (others => '0');
		elsif rising_edge(CLK) then
			CLK_cnt <= CLK_cnt + 1;
		end if;
	end process;

	data_pdoa <= x"5B" when (CLK_cnt > 10) and ( CLK_cnt < 20) else
				 x"43" when (CLK_cnt > 20) and ( CLK_cnt < 30) else
				 x"3A" when (CLK_cnt > 30) and ( CLK_cnt < 40) else
				 x"54" when (CLK_cnt > 40) and ( CLK_cnt < 50) else
				 x"65" when (CLK_cnt > 50) and ( CLK_cnt < 60) else
				 x"73" when (CLK_cnt > 60) and ( CLK_cnt < 70) else
				 x"74" when (CLK_cnt > 70) and ( CLK_cnt < 80) else
				 x"5D" when (CLK_cnt > 80) and ( CLK_cnt < 90) else
				(others => '0');

	valid_pdoa <= '1' when (CLK_cnt = 15) or
					       (CLK_cnt = 25) or
					       (CLK_cnt = 35) or
					       (CLK_cnt = 45) or
					       (CLK_cnt = 55) or
					       (CLK_cnt = 65) or
					       (CLK_cnt = 75) or
					       (CLK_cnt = 85) or
					       (CLK_cnt = 95) else
					'0';
					  
	
END;





