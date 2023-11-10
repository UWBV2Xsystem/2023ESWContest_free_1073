library ieee;
	use ieee.std_logic_1164.all;
	use ieee.std_logic_arith.all;
	use ieee.std_logic_unsigned.all;


entity UART_TX is
	port(
		nRST		: in std_logic;
		CLK			: in std_logic;
		start_sig	: in std_logic;
		data		: in std_logic_vector(7 downto 0);
		tx			: out std_logic;
		busy		: out std_logic
	);
end UART_TX;




architecture BEH of UART_TX is

	type state_type is (IDLE, START, SEND, STOP);
	signal state : state_type;	
	
	signal start_d	 			: std_logic;
	signal flag					: std_logic;
	signal temp_data			: std_logic_vector(7 downto 0);
	signal cnt					: std_logic_vector(6 downto 0);
	signal pclk					: std_logic;
	signal bit_cnt				: std_logic_vector(2 downto 0);
	signal TX_data				: std_logic_vector(7 downto 0);
	

	begin
		process(nRST, CLK)
		begin
			if(nRST = '0') then
				start_d 	<= '0';
				flag			<= '0';
				temp_data <= (others => '0');

			elsif rising_edge(CLK) then
				start_d <= start_sig;
				if (start_d = '1') and (start_sig = '0') then
					flag 			<= '1';
					temp_data <= data;
				elsif state = START then
					flag 			<= '0';
				end if;
			end if;
		end process;
		

		process(nRST, CLK)
		begin
			if(nRST = '0') then
				cnt 	<= (others => '0');
				pclk 	<= '0';
			elsif rising_edge(CLK) then
				if ( cnt = 51) then
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
				state 	<= IDLE;
				TX_DATA <= (others => '0');
				bit_cnt <= (others => '0');
			elsif rising_edge(pclk) then
				case state is
					when IDLE =>
						if ( flag = '1') then
							state <= START;
						else
							state <= IDLE;
						end if;
						TX_DATA <= (others => '0');
						bit_cnt <= (others => '0');
					when START =>
						state		<= SEND;
						TX_DATA <= temp_data;

					when SEND =>
						if ( bit_cnt = 7) then
							bit_cnt <= (others => '0');
							state 	<= STOP;
						else
							bit_cnt <= bit_cnt + 1;
							TX_DATA <= '0' & tx_data(7 downto 1);
						end if;
						
					when STOP =>
						state <= IDLE;
					when others =>
						state <= IDLE;
				end case;
			end if;
		end process;
		

	tx <= TX_DATA(0) when state = SEND else
		  '0'		 when state = START else
		  '1';

	busy <= '0' when (state = START) or (state = SEND) or (state = STOP) else
			'1';

	end BEH;