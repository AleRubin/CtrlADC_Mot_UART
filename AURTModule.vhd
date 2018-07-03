library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use IEEE.std_logic_unsigned.all;



entity AURTModule is
	Port(
			posPoli	: in  natural;
			clk 		: in  std_logic;
			leerADC	: in  std_logic;
			Bluet_D	: in  std_logic_vector(11 downto 0);
			we_enR	: in  std_logic_vector(1 downto 0);
			ledg 		: out std_logic_vector(7 downto 0);
			dReciv	: out std_logic_vector(7 downto 0);
			uart_txd : out std_logic;
			uart_rxd : in  std_logic
			);
	end AURTModule;

architecture behavioral of AURTModule is

signal tx_data		: std_logic_vector(7 downto 0);
signal rx_data		: std_logic_vector(7 downto 0);
signal avanPoli	: std_logic_vector(11 downto 0);
signal tx_start	: std_logic:='0';
signal enviar 		: std_logic:='0';
signal cont			: integer:=0;
signal tx_busy 	: std_logic;
signal rx_busy 	: std_logic;
signal iCLK 		: std_logic;

-------------------------------------------------------
component tx
	port
	(
		clk : in std_logic;
		start : in std_logic;
		busy : out std_logic;
		data : in std_logic_vector(7 downto 0);
		tx_line : out std_logic
	);
end component tx;

-------------------------------------------------------
component rx
	port
	(
		clk: in std_logic;
		rx_line : in std_logic;
		data : out std_logic_vector(7 downto 0);
		busy: out std_logic
	);
end component rx;

-----------------------------------------

begin
	
iCLK		<= we_enR(0);
avanPoli <= std_logic_vector(to_unsigned(posPoli, avanPoli'length));

	process(iCLK)
	begin
		if rising_edge(iCLK) then
			if we_enR(1) = '1' then
				cont <= 0;
			else
				cont <= cont + 1;
			end if;
		end if;
	end process;
	

	process(rx_busy)
	begin
		if(rx_busy'event and rx_busy='0') then
			dReciv(7 downto 0)<=rx_data;
		end if;
	end process;
	
	process(clk)
	begin
		if(clk'event and clk='1') then
			if(cont = 1) and (tx_busy='0') and (leerADC='1') then
				tx_data(5 downto 0)	<=	Bluet_D(5 downto 0);
				tx_data(7 downto 6)	<=	"00";
				tx_start					<=	'1';
				ledg						<=	tx_data;
			elsif (cont = 2) then
				tx_start					<=	'0';
			elsif (cont = 3) and (tx_busy='0') and (leerADC='1') then
				tx_data(5 downto 0)	<=	Bluet_D(11 downto 6);
				tx_data(7 downto 6)	<=	"01";
				tx_start					<=	'1';
				ledg						<=	tx_data;
			elsif cont = 4 then
				tx_start					<=	'0';
			elsif cont = 5 and (tx_busy='0') and (leerADC='1') then			-- 11 001100
				tx_data(5 downto 0) 	<= avanPoli(5 downto 0);
				tx_data(7 downto 6)	<=	"10";
				tx_start					<='1';			
			elsif cont = 6 then
				tx_start					<='0';			
			elsif cont = 7 and (tx_busy='0') and (leerADC='1') then			-- 11 001100
				tx_data(5 downto 0) 	<= avanPoli(11 downto 6);
				tx_data(7 downto 6)	<="11";
				tx_start					<='1';
			elsif cont >= 9 then
				tx_start					<='0';			
			end if;
		end if;
	end process;
	
	

	U1: tx port map (clk, tx_start, tx_busy, tx_data, uart_txd);
	U2: rx port map (clk, uart_rxd, rx_data, rx_busy);
	
	
end behavioral;