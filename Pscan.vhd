	library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.std_logic_unsigned.all;

entity Pscan is									
	port(	-- Conexiones Fisicas
			clk		: in  STD_LOGIC;  
			rst		: in  STD_LOGIC;
			ADC_D		: out STD_LOGIC_VECTOR(11 downto 0);
			-- Conexiones  ADCModule
			iDOUT		: in  STD_LOGIC;
			iGO		: in  STD_LOGIC := '0';
			iCH		: in  STD_LOGIC_VECTOR(2 downto 0);
			oDIN		: out STD_LOGIC;
			oCS_n		: out STD_LOGIC;
			oSCLK		: out STD_LOGIC;
			-- Conexiones  LCD
			RS			: OUT STD_LOGIC;
			RW			: OUT STD_LOGIC;
			ENA		: OUT STD_LOGIC;
			DATA_LCD	: OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
			-- Conexiones  UART
			TX			: OUT STD_LOGIC;
			RX			: IN  STD_LOGIC;
			--conexiones PWM para Motor DC
			encPhases: IN  STD_LOGIC_VECTOR(1 DOWNTO 0);
			motDC		: OUT STD_LOGIC_VECTOR(1 DOWNTO 0)
	  );
end entity;

architecture Pscan_arc of Pscan is

	component ADCModule is
		port ( 
			clk   	: in  STD_LOGIC;
			rst		: in  STD_LOGIC;
			iDOUT 	: in  STD_LOGIC;
			iGO   	: in  STD_LOGIC := '0';
			iCH   	: in  STD_LOGIC_VECTOR(2 downto 0);
			oDIN  	: out STD_LOGIC;
			oCS_n 	: out STD_LOGIC;
			oSCLK 	: out STD_LOGIC;
			we_env 	: out STD_LOGIC_VECTOR(1 downto 0);
			dir_we	: out STD_LOGIC_VECTOR(9 downto 0);
			adc_ld	: out STD_LOGIC_VECTOR(11 downto 0);
			OutCkt	: out STD_LOGIC_VECTOR(11 downto 0)
			);  
	end component;
	
	component LCDModule is
		port (
				clk			: IN STD_LOGIC;										-------------PUERTOS DE LA LCD -------------
				rst			: IN STD_LOGIC;
				corD			: IN STD_LOGIC;
				corI			: IN STD_LOGIC;
				RS				: OUT STD_LOGIC;
				RW				: OUT STD_LOGIC;
				ENA			: OUT STD_LOGIC;
				WaveSel     : IN  STD_LOGIC_VECTOR(2 downto 0);
				ADC_DataIn  : IN  STD_LOGIC_VECTOR(11 downto 0);
				Espera		: IN INTEGER;
				Avance		: IN INTEGER;
				AvncPhas		: IN NATURAL;
				DATA_LCD		: OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
				BLCD 			: OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
				);
	end component;
	
	
	component PWMModule is
		Port(
				clk		: in  STD_LOGIC;											--reloj de 50MHz
				rst		: in  STD_LOGIC;											--rst
				dato_R	: in  STD_LOGIC_VECTOR(7 downto 0);
				phases	: in  STD_LOGIC_VECTOR(1 downto 0);
				tEsp		: out INTEGER;
				Grad		: out INTEGER;
				avance	: out NATURAL;
				leer		: out STD_LOGIC:='0';
				motor1	: out STD_LOGIC_VECTOR (1 downto 0)				-- Primer motor
      );                                 
	end component ;
	
	component AURTModule is
		Port(
			posPoli	: in  natural;
			clk 		: in  std_logic;
			leerADC	: in  std_logic;
			Bluet_D	: in  std_logic_vector(11 downto 0);   -- son los que se hablitan para mandar datos de la FPGA a la PC
			we_enR	: in  std_logic_vector(1 downto 0);    -- al pulsar el pushboton, envia datos(de los switch) 
			ledg 		: out std_logic_vector(7 downto 0);		-- dato a enviar
			dReciv	: out std_logic_vector(7 downto 0);		-- dato recibido
			uart_txd : out std_logic;                  		-- transmisor del bluetooh 
			uart_rxd : in  std_logic                    		-- receptor   del bluetooh
			);
	end component;

	component ROM_1 is
		Port(
			clk	: in  STD_LOGIC;
			we_enU: in 	STD_LOGIC_VECTOR(1 downto 0);
			dir_1 : in  STD_LOGIC_VECTOR(9 downto 0);
			D_ADC : in  STD_LOGIC_VECTOR(11 downto 0);
			D_out : out STD_LOGIC_VECTOR(11 downto 0)
			);
	end component;

signal temp 					: INTEGER;								--tiempo valor en entero para indicar seg, 120 = 1 min      
signal AvancPhases			: NATURAL;
signal Derech,Izq				: STD_LOGIC :='0';
signal we_en					: STD_LOGIC_VECTOR(1 downto 0);
signal dir_wROM				: STD_LOGIC_VECTOR(9 downto 0);
signal dat_env					: STD_LOGIC_VECTOR(7 downto 0);
signal BLCD 					: STD_LOGIC_VECTOR(7 downto 0);
signal dato_Reciv				: STD_LOGIC_VECTOR(7 downto 0);
signal dato_UART				: STD_LOGIC_VECTOR(11 downto 0);
signal dato_Filtro			: STD_LOGIC_VECTOR(11 downto 0);
signal ADC_Data				: STD_LOGIC_VECTOR(11 downto 0):="000000000000";
signal steps					: INTEGER RANGE 0 TO 999999;		-- pasos encoder para determinar grados de cada avance
signal leerTesp				: STD_LOGIC:='0';


begin


ADC	: ADCModule 	port map(clk, rst, iDOUT, iGO, iCH, oDIN, oCS_n, oSCLK, we_en, dir_wROM, ADC_D, ADC_Data);

LCD	: LCDModule 	port map(clk, rst, Derech, Izq, RS, RW, ENA, iCH, ADC_Data,temp,steps, AvancPhases, DATA_LCD, BLCD);

PWM   : PWMModule     port map(clk, rst, dato_Reciv, encPhases, temp, steps, AvancPhases, leerTesp, motDC);

UART	: AURTModule	port map(AvancPhases, clk, leerTesp, dato_UART, we_en, dat_env, dato_Reciv, TX, RX );

ROM	: ROM_1			port map(clk,we_en,dir_wROM,ADC_Data,dato_UART);


end architecture Pscan_arc;

