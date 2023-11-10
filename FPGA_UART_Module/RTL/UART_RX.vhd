library ieee;
	use ieee.std_logic_1164.all;
	use ieee.std_logic_arith.all;
	use ieee.std_logic_unsigned.all;


entity UART_RX is
	port(
		nRST		: in std_logic;
		CLK			: in std_logic;
		rx			: in std_logic;
		data		: out std_logic_vector(7 downto 0);
		valid		: out std_logic
	);
end UART_RX;




architecture BEH of UART_RX is

	type state_type is (IDLE, START, RECEIVE, STOP);
	signal state : state_type;	
	
	signal rx_d			: std_logic;
	signal flag			: std_logic;

	signal RX_data		: std_logic_vector(7 downto 0);
	signal pclk			: std_logic;
	signal pclk_cnt		: std_logic_vector(2 downto 0);
	signal cnt			: std_logic_vector(8 downto 0);

	signal Bit_cnt		: std_logic_vector(2 downto 0);
	


	begin
		process(nRST, CLK)
		begin
			if(nRST = '0') then
				rx_d <= '0';
				flag <= '0';
			elsif rising_edge(CLK) then
				rx_d <= rx;
				if state = IDLE then
					if (rx_d = '1') and (rx = '0') then
						flag <= '1';
					end if;
				elsif state = START then
					flag <= '0';
				end if;
			end if;
		end process;
		

		process(nRST, CLK)
		begin
			if(nRST = '0') then
				cnt		 <= (others => '0');
				pclk	 <= '0';
				

			elsif rising_edge(CLK) then
				if ( cnt = 155) then
					cnt 	<= (others => '0');
					pclk 	<= not pclk;
				else
					cnt 	<= cnt + 1;
				end if;
			end if;
		end process;

		

		process(nRST, pclk) 
		begin
			if(nRST = '0') then
				state <= IDLE;
				RX_data 	<= (others => '0');
				pclk_cnt 	<= (others => '0');
				Bit_cnt	 	<= (others => '0');
				data 	 	<= (others => '0');
			elsif rising_edge(pclk) then
				case state is
					when IDLE =>
						if (flag = '1') then
							state <= START;
						else 
							state <= IDLE;
						end if;
						RX_data  <= (others => '0');
						pclk_cnt <= (others => '0');
						Bit_cnt	 <= (others => '0');
						data 	 <= (others => '0');
					when START =>
						if (pclk_cnt = 3) then
							pclk_cnt <= (others => '0');
							state <= RECEIVE;
						else
							pclk_cnt <= pclk_cnt + 1;
							state <= START;
						end if;

					when RECEIVE =>	
						if (pclk_cnt = 7) then
							pclk_cnt <= (others => '0');
							rx_data <= rx & rx_data(7 downto 1);
							
							if ( Bit_cnt = 7 ) then
								Bit_cnt <= ( others => '0');
								state <= STOP;
							else
								Bit_cnt <= Bit_cnt + 1;
								state <= RECEIVE;
							end if;
						else
							pclk_cnt <= pclk_cnt + 1;
						end if;

					when STOP =>
						if (pclk_cnt = 7) then
							pclk_cnt <= (others => '0');
							state<= IDLE;
						else
							pclk_cnt <= pclk_cnt + 1;
							state <= STOP;
						end if;
						data <= rx_data;

					when others =>
						state <= IDLE;
				end case;
			end if;
		end process;
		
		valid <= '1' when (state = STOP and pclk_cnt = 7 ) else '0';


	end BEH;