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
			start		: IN  STD_LOGIC;
			selGrSeg	: IN  STD_LOGIC;										-- selector para incrementar grados(1) o tiempo en espera(0)
			plusGrSg : IN  STD_LOGIC;										-- push para aumentar Num de pulsos de DC o tiempo en espera .5s
			phaseA	: IN  STD_LOGIC;
			phaseB	: IN  STD_LOGIC;
			motDC		: OUT STD_LOGIC_VECTOR(1 DOWNTO 0)
	  );
end entity;

architecture Pscan_arc of Pscan is

	component ADCModule is
		port ( 
			clk   : in  STD_LOGIC;
			rst	: in  STD_LOGIC;
			iDOUT : in  STD_LOGIC;
			iGO   : in  STD_LOGIC := '0';
			iCH   : in  STD_LOGIC_VECTOR(2 downto 0);
			oDIN  : out STD_LOGIC;
			oCS_n : out STD_LOGIC;
			oSCLK : out STD_LOGIC;
			Dat_B : out STD_LOGIC;
			OutCkt: out STD_LOGIC_VECTOR(11 downto 0)
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
				DATA_LCD		: OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
				BLCD 			: OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
				);
	end component;
	
	
	component PWMModule is
		Port(
			clk		:  in  STD_LOGIC;											--reloj de 50MHz
			rst		:  in  STD_LOGIC;											--rst
			selector	:	in  STD_LOGIC;											-- selector para incrementar grados(1) o tiempo en espera(0)
			plusGS	:	in  STD_LOGIC;											-- push para aumentar Num de pulsos de DC o tiempo en espera .5s
			start		:  in  STD_LOGIC;											--inicio de velocidades
			nPulsos	:	in  INTEGER RANGE 0 TO 999999 :=0 ;				-- contador de pulsos por cuadratura
			t			:  out INTEGER RANGE 1 TO 120 := 1;					--tiempo valor en entero para indicar seg, 120 = 1 min
			step		:	out INTEGER RANGE 0 TO 999999	:= 0;				--paso de 1 o 1/2 grado para polarizador, 0=1/2 grado
			motor1	:  out STD_LOGIC_VECTOR (1 downto 0)				--motor
			);                                 
	end component ;
	
	component AURTModule is
		Port(
			clk 		: in std_logic;
			Bluet_D	: in std_logic_vector(9 downto 0);      -- son los que se hablitan para mandar datos de la FPGA a la PC
			enviar	: in std_logic;                        -- al pulsar el pushboton, envia datos(de los switch) 
			ledr 		: out std_logic_vector(9 downto 0);		--dato recibido
			ledg 		: out std_logic_vector(7 downto 0);		-- dato a enviar
			uart_txd : out std_logic;                  		-- transmisor del bluetooh 
			uart_rxd : in std_logic                    		-- receptor   del bluetooh
			);
	end component;


	
signal env_Bluet				: STD_LOGIC;
signal temp 					: NATURAL := 1;								--tiempo valor en entero para indicar seg, 120 = 1 min      
signal Derech,Izq				: STD_LOGIC :='0';
signal dato_recib,D_Bluet	: STD_LOGIC_VECTOR(9 downto 0);
signal dato_env				: STD_LOGIC_VECTOR(7 downto 0);
signal BLCD 					: STD_LOGIC_VECTOR(7 downto 0);
signal ADC_Data				: STD_LOGIC_VECTOR(11 downto 0);
signal NUMERO_PULSOS 		: INTEGER RANGE 0 TO 999999 := 0;		-- contador de pulsos por cuadratura
signal steps					: INTEGER RANGE 0 TO 999999 := 0;		--paso de 1 o 1/2 grado para polarizador, 0=1/2 grado
signal Bluet_Val,valorD		: NATURAL;


begin
--Bluet_Val   <=(3300 * (to_integer(UNSIGNED(ADC_Data))))/4095;
--Bluet_Val   <= to_integer(UNSIGNED(ADC_Data));
--valorD <= (Bluet_Val/1000);
--D_Bluet <= std_logic_vector(to_unsigned(Bluet_Val, D_Bluet'length));

ADC_D		<= ADC_Data;


ADC_1	: ADCModule 	port map(clk, rst, iDOUT, iGO, iCH, oDIN, oCS_n, oSCLK, env_Bluet, ADC_Data);

LCD_2	: LCDModule 	port map(clk, rst, Derech, Izq, RS, RW, ENA, iCH, ADC_Data, DATA_LCD, BLCD);

PWM_3	: PWMModule 	port map(clk, rst,selGrSeg,plusGrSg,start,NUMERO_PULSOS,temp,steps,motDC);

UART_4: AURTModule	port map(clk, D_Bluet, env_Bluet, dato_recib, dato_env, TX, RX );


end architecture Pscan_arc;

