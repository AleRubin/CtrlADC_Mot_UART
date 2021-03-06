library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.std_logic_unsigned.all;
--use IEEE.std_logic_arith.all;
USE WORK.COMANDOS_LCD_REVC.ALL;

entity LCDModule is

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
	end LCDModule;

	
architecture Behavioral of LCDModule is		------------SE�ALES DE LA LCD ---------------------

TYPE RAM IS ARRAY (0 TO  60) OF STD_LOGIC_VECTOR(8 DOWNTO 0); 
SIGNAL INSTRUCCION : RAM;

	COMPONENT PROCESADOR_LCD_REVC is
		PORT(
			CLK					: IN STD_LOGIC;
			CORD 					: IN STD_LOGIC;
			CORI 					: IN STD_LOGIC;
			DELAY_COR 			: IN INTEGER RANGE 0 TO 1000;
			VECTOR_MEM			: IN STD_LOGIC_VECTOR(8 DOWNTO 0);
			C1A,C2A,C3A,C4A 	: IN STD_LOGIC_VECTOR(39 DOWNTO 0);
			C5A,C6A,C7A,C8A 	: IN STD_LOGIC_VECTOR(39 DOWNTO 0);
			RS 					: OUT STD_LOGIC;
			RW 					: OUT STD_LOGIC;
			BD_LCD 				: OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
			ENA  					: OUT STD_LOGIC;
			INC_DIR 				: OUT INTEGER RANGE 0 TO 1024;
			DATA 					: OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
			);
			
	end  COMPONENT PROCESADOR_LCD_REVC;
	
	COMPONENT CARACTERES_ESPECIALES_REVC is
		PORT( 
			C1,C2,C3,C4:OUT STD_LOGIC_VECTOR(39 DOWNTO 0);
			C5,C6,C7,C8:OUT STD_LOGIC_VECTOR(39 DOWNTO 0);
			CLK : IN STD_LOGIC
			);
	end COMPONENT CARACTERES_ESPECIALES_REVC;
	

CONSTANT CHAR1 : INTEGER := 1;
CONSTANT CHAR2 : INTEGER := 2;
CONSTANT CHAR3 : INTEGER := 3;
CONSTANT CHAR4 : INTEGER := 4;
CONSTANT CHAR5 : INTEGER := 5;
CONSTANT CHAR6 : INTEGER := 6;
CONSTANT CHAR7 : INTEGER := 7;
CONSTANT CHAR8 : INTEGER := 8;
CONSTANT grado	: INTEGER := 406;


SIGNAL RS_S, RW_S, E_S 		: STD_LOGIC;
SIGNAL DIR_S 					: INTEGER RANGE 0 TO 1024;
SIGNAL DELAY_COR 				: INTEGER RANGE 0 TO 1000;
SIGNAL TempVal, TempVal_1 	: natural;		-- para descomponer el contador de pulsos por cuadratura
SIGNAL TempVal_2, TempVal_3: natural;		-- para descomponer el contador de pulsos por cuadratura
SIGNAL TempVal_4, TempVal_5: natural;		-- para descomponer el contador de pulsos por cuadratura
--SIGNAL uniSeg, decSeg	   : INTEGER RANGE 0 TO 9 :=0;		-- para descomponer el contador de pulsos por cuadratura
--SIGNAL uniGrad,decGrad,cGr	: INTEGER RANGE 0 TO 9 :=0;		-- para descomponer el contador de pulsos por cuadratura
--SIGNAL steps					: INTEGER RANGE 0 TO 999999 := 0;		--paso de 1 o 1/2 grado para polarizador, 0=1/2 grado
--SIGNAL temp 					: natural := 1;	--tiempo valor en entero para indicar seg, 120 = 1 min      
SIGNAL DIR 						: INTEGER RANGE 0 TO 1024 := 0;
--SIGNAL NUMERO_PULSOS 		: INTEGER RANGE 0 TO 999999 :=0 ;-- contador de pulsos por cuadratura
SIGNAL VECTOR_MEM_S 			: STD_LOGIC_VECTOR(8 DOWNTO 0);
SIGNAL DATA_S 					: STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL C1S,C2S,C3S,C4S 		: STD_LOGIC_VECTOR(39 DOWNTO 0);
SIGNAL C5S,C6S,C7S,C8S 		: STD_LOGIC_VECTOR(39 DOWNTO 0);

begin

------------COMPONENTES PARA LCD ---------------
U1 : PROCESADOR_LCD_REVC PORT MAP(
										CLK			=> CLK,
										VECTOR_MEM	=> VECTOR_MEM_S,
										RS				=> RS_S,
										RW				=> RW_S,
										ENA			=> E_S,
										INC_DIR 		=> DIR_S,
										DELAY_COR 	=> DELAY_COR,
										BD_LCD 		=> BLCD,
										CORD 			=> CORD,
										CORI 			=> CORI,
										C1A 			=> C1S,
										C2A 			=> C2S,
										C3A 			=> C3S,
										C4A 			=> C4S,
										C5A 			=> C5S,
										C6A 			=> C6S,
										C7A 			=> C7S,
										C8A 			=> C8S,
										DATA 			=> DATA_S
										);
										
																			
U2 : CARACTERES_ESPECIALES_REVC PORT MAP(
										C1 			=> C1S,
										C2 			=> C2S,
										C3 			=> C3S,
										C4 			=> C4S,
										C5 			=> C5S,
										C6 			=> C6S,
										C7 			=> C7S,
										C8 			=> C8S,
										CLK 			=> CLK
										);

-------direccionamiento de señales a component´s-----------
DIR <= DIR_S;															--
VECTOR_MEM_S <= INSTRUCCION(DIR);								--
																			--
RS <= RS_S;																--
RW <= RW_S;																--
ENA <= E_S;																--
DATA_LCD <= DATA_S;													--
-----------------------------------------------------------


DELAY_COR <= 500; --Modificar esta variable para la velocidad del corrimiento.
			
TempVal   <= (3300 * (to_integer(UNSIGNED(ADC_DataIn))))/4095;
TempVal_1 <= (TempVal) mod 10;
TempVal_2 <= (TempVal/10) mod 10;
TempVal_3 <= (TempVal/100) mod 10;
TempVal_4 <= (TempVal/1000);


			

	--control para leer numero de pulsos del encoder en cuadratura sentido horario adición, antihorario resta.
	
--	process (phaseA, phaseB, rst)
--		begin
--		if (rst='0') then
--			NUMERO_PULSOS <= 0;
--		elsif rising_edge(phaseA) then
--			if  phaseB = '0' then
--				NUMERO_PULSOS <= NUMERO_PULSOS + 1;
--			else
--				NUMERO_PULSOS <= NUMERO_PULSOS - 1;
--			end if;	
--		end if;
--		
--		
--	end process;
--	
--	-- obtencion de valores residous para unidades, decenas, centenas, unidades decenas y centenas de miles
--			
--			centMill <= (NUMERO_PULSOS/100000) mod 10;
--			decMill  <= (NUMERO_PULSOS/10000) mod 10;
--			uniMill  <= (NUMERO_PULSOS/1000) mod 10;
--			centenas <= (NUMERO_PULSOS/100) mod 10;
--			DECENAS  <= (NUMERO_PULSOS/10) mod 10;
--			UNIDADES <=  NUMERO_PULSOS mod 10;
--
--			cGr	  <= (steps/100) mod 10;
--			decGrad <= (steps/10) mod 10;
--			uniGrad <= steps mod 10;
--			
--			
--			decSeg <= (temp/10) mod 10;
--			uniSeg <=  temp mod 10; 
--	-- instrucciones para mandar a escribir en LCD

 INSTRUCCION(0) <= LCD_INI("00"); 				--INICIALIZAMOS LCD, CURSOR A HOME, CURSOR ON, PARPADEO ON.
 INSTRUCCION(1) <= BUCLE_INI(1);
 INSTRUCCION(2) <= POS(1,1);						--EMPEZAMOS A ESCRIBIR EN LA LINEA 1, POSICIï¿½N 1
 INSTRUCCION(3) <= INT_NUM(TempVal_4);
 INSTRUCCION(4) <= POS(1,2);			
 INSTRUCCION(5) <= CHAR_ASCII(x"2E");
 INSTRUCCION(6) <= POS(1,3);			
 INSTRUCCION(7) <= INT_NUM(TempVal_3);
 INSTRUCCION(8) <= POS(1,4);			
 INSTRUCCION(9) <= INT_NUM(TempVal_2);
 INSTRUCCION(10) <= POS(1,5);			
 INSTRUCCION(11) <= INT_NUM(TempVal_1);
 INSTRUCCION(12) <= POS(1,6);			
 INSTRUCCION(13) <= CHAR_ASCII(x"21");
 INSTRUCCION(14) <= CHAR_ASCII(x"21");
 INSTRUCCION(15) <= BUCLE_FIN(1);				-- fin bucle
 
 

end Behavioral;

