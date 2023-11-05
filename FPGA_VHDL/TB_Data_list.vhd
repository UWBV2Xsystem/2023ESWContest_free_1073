
-- VHDL Test Bench Created from source file Data_list.vhd -- Mon Oct 23 02:25:35 2023

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

ENTITY TB_DI IS END;

ARCHITECTURE BEH OF TB_DI IS 

	COMPONENT Data_list
	PORT(
		nRST				: in std_logic;
		CLK					: in std_logic;
		ready				: in std_logic;

		
		data_pdoa			: in std_logic_vector(31 downto 0);
		data_start_pdoa		: in std_logic_vector(1 downto 0);
		
		data_dist			: in std_logic_vector(31 downto 0);
		data_start_dist		: in std_logic_vector(1 downto 0);

		data_out			: out std_logic_vector(7 downto 0);
		start_sig			: out std_logic
		);
	END COMPONENT;

	SIGNAL nRST :  std_logic;
	SIGNAL CLK :  std_logic;
	SIGNAL ready :  std_logic;
	SIGNAL data_pdoa :  std_logic_vector(31 downto 0);
	SIGNAL data_start_pdoa :  std_logic_vector(1 downto 0);
	SIGNAL data_dist :  std_logic_vector(31 downto 0);
	SIGNAL data_start_dist :  std_logic_vector(1 downto 0);
	SIGNAL data_out :  std_logic_vector(7 downto 0);
	SIGNAL start_sig :  std_logic;

	signal CLK_cnt 		: std_logic_vector(10 downto 0);

BEGIN

-- Please check and add your generic clause manually
	uut: Data_list PORT MAP(
		nRST => nRST,
		CLK => CLK,
		ready => ready,
		data_pdoa => data_pdoa,
		data_start_pdoa => data_start_pdoa,
		data_dist => data_dist,
		data_start_dist => data_start_dist,
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




	data_pdoa <= x"2d313030" when (CLK_cnt > 10) and ( CLK_cnt < 20) else
				(others => '0');

	data_start_pdoa <= "01" when (CLK_cnt = 15) else
					   "00";
					  

	data_dist <= x"39393939" when (CLK_cnt > 20) and ( CLK_cnt < 30)else
				(others => '0');

	data_start_dist <= "01" when (CLK_cnt = 25) else
					   "00";
					  
	ready <= '1' when (CLK_cnt = 80) or 
					  (CLK_cnt = 82) or
					  (CLK_cnt = 84) or
					  (CLK_cnt = 86) or
					  (CLK_cnt = 88) or
					  (CLK_cnt = 90) or
					  (CLK_cnt = 92) or
					  (CLK_cnt = 94) or
					  (CLK_cnt = 96) or
					  (CLK_cnt = 98) or
					  (CLK_cnt = 100) or
					  (CLK_cnt = 102) or
					  (CLK_cnt = 104) or
					  (CLK_cnt = 106) or
					  (CLK_cnt = 108) or
					  (CLK_cnt = 110) or
					  (CLK_cnt = 112) or
					  (CLK_cnt = 114) or
					  (CLK_cnt = 116) or
					  (CLK_cnt = 118) or
					  (CLK_cnt = 120) or
					  (CLK_cnt = 122) or
					  (CLK_cnt = 124) or
					  (CLK_cnt = 126) else 
			'0';

END beh;
