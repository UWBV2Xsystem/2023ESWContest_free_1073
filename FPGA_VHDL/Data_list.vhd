library ieee;
	use ieee.std_logic_1164.all;
	use ieee.std_logic_arith.all;
	use ieee.std_logic_unsigned.all;


entity Data_list is
	port(
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
end Data_list;




architecture BEH of Data_list  is
		type state_type is (IDLE, WAIT_F , SEND);
		signal state : state_type;	
		
		signal temp_dist			: std_logic_vector(31 downto 0);
		
		signal Car_dist				: std_logic_vector(31 downto 0);
		signal Ped_dist				: std_logic_vector(31 downto 0);
		
		
		signal temp_pdoa			: std_logic_vector(31 downto 0);
		
		signal Car_pdoa				: std_logic_vector(31 downto 0);
		signal Ped_pdoa				: std_logic_vector(31 downto 0);
		signal Trl_pdoa				: std_logic_vector(31 downto 0);
		
		signal Car_pdoa_flag		: std_logic;
		signal Ped_pdoa_flag		: std_logic;
		signal Trl_pdoa_flag		: std_logic;
		
		signal Car_dist_flag		: std_logic;
		signal Ped_dist_flag		: std_logic;
		
		signal Car_data_use_flag 	: std_logic;
		signal Ped_data_use_flag 	: std_logic;
		signal Trl_data_use_flag 	: std_logic;

		signal SEND_DATA			: std_logic_vector(191 downto 0);
		signal SEND_DATA_ped		: std_logic_vector(191 downto 0);
		signal SEND_DATA_trl		: std_logic_vector(191 downto 0);
		
		signal bit_cnt				: std_logic_vector(4 downto 0);

		

		signal data_start_dist_sig_d : std_logic_vector(1 downto 0);

		signal data_start_pdoa_sig_d : std_logic_vector(1 downto 0);


		signal ready_sig 	: std_logic;
		signal ready_sig_d 	: std_logic;
		
		signal TRL_data_d	: std_logic_vector(31 downto 0);

begin
	
	process(nRST, CLK)
	begin
		if ( nRST = '0') then
			data_start_dist_sig_d <= (others =>  '0');
			data_start_pdoa_sig_d <= (others =>  '0');
		elsif rising_edge(CLK) then
			data_start_dist_sig_d <= data_start_dist;
			data_start_pdoa_sig_d <= data_start_pdoa;
		end if;
	end process;


	process(nRST, CLK)
	begin
		if ( nRST = '0') then
			Car_dist <= (others => '0');
			Ped_dist <= (others => '0');
			Car_dist_flag <= '0';
			Ped_dist_flag <= '0';
			
		elsif rising_edge(CLK) then
			temp_dist <= data_dist;
			
			if (data_start_dist_sig_d = "01") then
				Car_dist <= temp_dist;
				Car_dist_flag <= '1';
			elsif (data_start_dist_sig_d = "10") then
				Ped_dist <= temp_dist;	
				Ped_dist_flag <= '1';			
			end if;
			if (state = SEND) then
				Car_dist_flag <= '0';
				Ped_dist_flag <= '0';
			end if;
			
			
		end if;
	end process;
	
	process(nRST, CLK)
	begin
		if ( nRST = '0') then
			Car_pdoa <= (others => '0');
			Ped_pdoa <= (others => '0');
			Trl_pdoa <= (others => '0');

			Car_pdoa_flag <= '0';
			Ped_pdoa_flag <= '0';
			Trl_pdoa_flag <= '0';
			
		elsif rising_edge(CLK) then
			temp_pdoa <= data_pdoa(31 downto 0);
			if (data_start_pdoa_sig_d = "01")then
				Car_pdoa <= temp_pdoa;
				Car_pdoa_flag <= '1';

			elsif (data_start_pdoa_sig_d = "10") then
				Ped_pdoa <= temp_pdoa;	
				Ped_pdoa_flag <= '1';

			elsif (data_start_pdoa_sig_d = "11") then
				Trl_pdoa <= temp_pdoa;	
				Trl_pdoa_flag <= '1';
				
			end if;
			
			if (state = SEND) then
				Car_pdoa_flag <= '0';
				Ped_pdoa_flag <= '0';
				Trl_pdoa_flag <= '0';
			end if;			
		end if;
	end process;
	
	
	process(nRST, CLK)
	begin
		if (nRST = '0') then
			start_sig <= '0';
			state <= IDLE;
			SEND_DATA 		<= (others => '0');
			SEND_DATA_ped 	<= (others => '0');
			SEND_DATA_trl	<= (others => '0');
			
			bit_cnt <= (others => '0');
			
			Car_data_use_flag <= '0';
			Ped_data_use_flag <= '0';
			Trl_data_use_flag <= '0';
			
			TRL_data_d <= (others => '0');
			ready_sig <= '0';
			ready_sig_d <= '0';

		elsif rising_edge(CLK) then
			case state is
					when IDLE =>
						Car_data_use_flag <= '0';
						Ped_data_use_flag <= '0';
						Trl_data_use_flag <= '0';
						
						SEND_DATA 		<= x"202020202020202020202020202020202020202020202020";
						SEND_DATA_ped 	<= x"202020202020202020202020202020202020202020202020";
						SEND_DATA_trl 	<= x"202020202020202020202020202020202020202020202020";
						
						start_sig 	<= '0';
						bit_cnt 	<= (others => '0');
						
						state <= WAIT_F;
						
					when WAIT_F =>
						bit_cnt <= (others => '0');
						
						if ( Car_pdoa_flag = '1') and (Car_dist_flag = '1') then
							SEND_DATA(191 downto 120) <= x"5b54593a632c50443a"; -- [TY:c,PD:--
							SEND_DATA(119 downto 88) <= Car_pdoa; -- -999
							SEND_DATA(87 downto 56) <= x"2c44543a"; -- ,DT:
							SEND_DATA(55 downto 40) <= Car_dist(31 downto 16); -- 99
							SEND_DATA(39 downto 32) <= x"2e"; -- .
							SEND_DATA(31 downto 16) <= Car_dist(15 downto 0);  -- 99
							SEND_DATA(15 downto 0) <= x"5d0d"; -- ]\n
							
							Car_data_use_flag <= '1';		
						end if;
						
						if ( Ped_pdoa_flag = '1') and (Ped_dist_flag = '1') then
							SEND_DATA_ped(191 downto 120) <= x"5b54593a702c50443a"; -- [TY:c,PD:--
							SEND_DATA_ped(119 downto 88) <= Ped_pdoa; -- -999
							SEND_DATA_ped(87 downto 56) <= x"2c44543a"; -- ,DT:
							SEND_DATA_ped(55 downto 40) <= Ped_dist(31 downto 16); -- 99
							SEND_DATA_ped(39 downto 32) <= x"2e"; -- .
							SEND_DATA_ped(31 downto 16) <= Ped_dist(15 downto 0);  -- 99
							SEND_DATA_ped(15 downto 0) <= x"5d0d"; -- ]\n
							
							Ped_data_use_flag <= '1';
						end if;
						
						if ( Trl_pdoa_flag = '1') and not(trl_pdoa = TRL_data_d) then
							SEND_DATA_trl(191 downto 128) <= x"5b54593a542c433a"; -- [TY:T,PD:--
							SEND_DATA_trl(127 downto 120) <= trl_pdoa(15 downto 8); -- -999
							SEND_DATA_trl(119 downto 96) <= x"2c543a"; -- ,C:
							SEND_DATA_trl(95 downto 88) <= trl_pdoa(7 downto 0);
							SEND_DATA_trl(87 downto 72) <= x"5d0d"; -- ]\n
							SEND_DATA_trl(71 downto 0) <= x"202020202020202020";
							TRL_data_d <= trl_pdoa;
							
							Trl_data_use_flag <= '1';
						end if;
						
						if (Car_data_use_flag = '1') or (Ped_data_use_flag = '1') or (Trl_data_use_flag = '1') then
							state <= SEND; 
						else 
							state <= WAIT_F;
						end if;
						
						
					when SEND =>
						ready_sig <= ready;
						ready_sig_d <= ready_sig;

						if (Car_data_use_flag = '1') then
							if ( bit_cnt = 24) then
								bit_cnt 			<= (others => '0');
								start_sig 			<= '0';
								Car_data_use_flag 	<= '0';
							elsif ( bit_cnt = 0) then
								if (ready_sig_d = '1') then
									bit_cnt 		<= bit_cnt + 1; 
									start_sig 		<= '1';
								else
									start_sig 		<= '0';
								end if;
							else
								if ( ready_sig_d = '0') and (ready_sig = '1') then
									SEND_DATA 		<= SEND_DATA(183 downto 0) & x"00";
									bit_cnt 		<= bit_cnt + 1; 
									start_sig 		<= '1';								
								else
									start_sig 		<= '0';
								end if;
							end if;  
						end if;
						
						if (Ped_data_use_flag = '1') then
							if ( bit_cnt = 24) then 
								bit_cnt 			<= (others => '0');
								start_sig 			<= '0';
								Ped_data_use_flag 	<= '0';
							elsif ( bit_cnt = 0) then
								SEND_DATA 			<= SEND_DATA_Ped;
								if (ready_sig_d = '1')  then
									bit_cnt 		<= bit_cnt + 1; 
									start_sig 		<= '1';
								else
									start_sig 		<= '0';
								end if;
							else
								if ( ready_sig_d = '0') and (ready_sig = '1')  then
									SEND_DATA 		<= SEND_DATA(183 downto 0) & x"00";
									bit_cnt 		<= bit_cnt + 1; 
									start_sig 		<= '1';
								else
									start_sig 		<= '0';
								end if; 
							end if;  
						end if;
												
						if (Trl_data_use_flag = '1') then
							if ( bit_cnt = 24) then
								bit_cnt <= (others => '0');
								start_sig <= '0';
								Trl_data_use_flag <= '0';
							elsif ( bit_cnt = 0) then
								SEND_DATA <= SEND_DATA_Trl;
								if (ready_sig_d = '1') then
									bit_cnt <= bit_cnt + 1; 
									start_sig <= '1';
								else
									start_sig <= '0';
								end if;
							else
								if ( ready_sig_d = '0') and (ready_sig = '1') then
									SEND_DATA <= SEND_DATA(183 downto 0) & x"00";
									bit_cnt <= bit_cnt + 1; 
									start_sig <= '1';
								else
									start_sig <= '0';
								end if;
							end if;  
						
						end if; -- Trl_data_use_flag
						
						if (Car_data_use_flag = '1') or (Ped_data_use_flag = '1') or (Trl_data_use_flag = '1') then
							state <= SEND; 
						else 
							state <= IDLE;
						end if;
														
						
					when others =>
						state <= IDLE;
			end case;
		end if;
	end process;
	
	data_out <= SEND_DATA(191 downto 184) when state = SEND else (others => '0');
	
end BEH;