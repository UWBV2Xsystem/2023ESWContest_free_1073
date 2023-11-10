library ieee;
	use ieee.std_logic_1164.all;
	use ieee.std_logic_arith.all;
	use ieee.std_logic_unsigned.all;


entity Data_processing is
	port(
		nRST				: in std_logic;
		CLK					: in std_logic;
		data_pdoa			: in std_logic_vector(7 downto 0);	
		valid_pdoa			: in std_logic;
		
		data_out			: out std_logic_vector(31 downto 0);		
		start_sig			: out std_logic_vector(1 downto 0)
	);
end Data_processing;




architecture BEH of Data_processing  is

	type state_type is (IDLE, ID_F, CAR, TRL, PED, SEND);
	signal state_pdoa : state_type;	
	
	
	signal pdoa_valid_d			: std_logic;
	signal pdoa_flag			: std_logic;
	
	signal pdoa_id				: std_logic_vector(7 downto 0);
	signal pdoa_car				: std_logic_vector(31 downto 0);
	signal pdoa_ped				: std_logic_vector(31 downto 0);
	signal pdoa_trl				: std_logic_vector(31 downto 0);
	
	signal temp_data			: std_logic_vector(7 downto 0);
	
	signal flag_car				: std_logic;
	signal flag_trl				: std_logic;
	signal flag_ped				: std_logic;
	
	
	begin
	
	process(nRST, CLK) -- 
	begin
		if(nRST = '0') then
			pdoa_valid_d 	<= '0';
			pdoa_flag	 	<= '0';
			
			temp_data <= (others => '0');
		elsif rising_edge(CLK) then
			pdoa_valid_d <= valid_pdoa;
			if (pdoa_valid_d = '1') and (valid_pdoa = '0') then
				pdoa_flag <= '1';
				temp_data <= data_pdoa;
			else
				pdoa_flag <= '0';
			end if;
		end if;
	end process;
	


	process(nRST, CLK)
	begin
		if(nRST = '0') then
			state_pdoa <= IDLE;
			pdoa_id  <= (others => '0');
			pdoa_car <= (others => '0');
			pdoa_ped <= (others => '0');
			pdoa_trl <= (others => '0');
			
			flag_car <= '0';
			flag_ped <= '0';
			flag_trl <= '0';
			
			start_sig <= (others => '0');
			
		elsif rising_edge(CLK) then
			case state_pdoa is
					when IDLE =>
						if (pdoa_flag = '1') then
							if (temp_data = x"5B") then
								state_pdoa <= ID_F;
							end if;
						else
							state_pdoa <= IDLE;
						end if;
						flag_car <= '0';
						flag_ped <= '0';
						flag_trl <= '0';
						
						pdoa_car <= x"20202020";
						pdoa_ped <= x"20202020";
						pdoa_trl <= x"20202020";
						
						start_sig <= (others => '0');
						
					when ID_F =>
						if ( pdoa_flag = '1') then
							pdoa_id <= temp_data;
							if ( temp_data = x"43") then		 -- C
								state_pdoa <= CAR;
							elsif ( temp_data = x"54") then 	 -- T
								state_pdoa <= TRL;
							elsif ( temp_data = x"50") then	 	-- P
								state_pdoa <= PED;
							else
								state_pdoa <= IDLE;
							end if;
						end if;
							
							
					when CAR =>
						if ( pdoa_flag = '1') then
							if (temp_data = x"5D") then
								flag_car <= '1';
								
								state_pdoa <= SEND;
							else
								flag_car <= '0';
								pdoa_car <=  pdoa_car(23 downto 0) & temp_data;
								state_pdoa <= CAR;
							end if;
						else
							state_pdoa <= CAR;
						end if;
						
					when TRL =>
						if ( pdoa_flag = '1') then
							if (temp_data = x"5D") then	
								flag_trl <= '1';
								
								state_pdoa <= SEND;
							else
								flag_trl <= '0';
								pdoa_trl <= pdoa_trl(23 downto 0) & temp_data;
								state_pdoa <= TRL;
							end if;
						else 
							state_pdoa <= TRL;
						end if;
						
					when PED =>
						if ( pdoa_flag = '1') then
							if (temp_data = x"5D") then
								flag_ped <= '1';
								
								state_pdoa <= SEND;
							else
								flag_ped <= '0';
								pdoa_ped <= pdoa_ped(23 downto 0) & temp_data;
								state_pdoa <= PED;
							end if;
						end if;
					
					when SEND => 
						if 	( flag_car = '1') then 
							data_out <= pdoa_car;
							start_sig <= "01";
						elsif (flag_ped = '1') then
							data_out <= pdoa_ped;
							start_sig <= "10";
						elsif (flag_trl = '1') then
							data_out <= pdoa_trl;
							start_sig <= "11";
							
						end if;
						
						flag_car <= '0';
						flag_ped <= '0';
						flag_trl <= '0';
						
						state_pdoa <= IDLE;
					when others => 
						state_pdoa <= IDLE;
			end case;
		end if;
	end process;
end BEH;