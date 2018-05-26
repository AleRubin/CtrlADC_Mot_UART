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
			Espera		: IN INTEGER;
			Avance		: IN INTEGER;
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
SIGNAL uniSeg, decSeg	   : INTEGER RANGE 0 TO 9 :=0;		-- para descomponer el contador de pulsos por cuadratura
SIGNAL uniGrad,decGrad,cGr	: INTEGER RANGE 0 TO 9 :=0;		-- para descomponer el contador de pulsos por cuadratura
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
			cGr	  <= (Avance/100) mod 10;
			decGrad <= (Avance/10) mod 10;
			uniGrad <= Avance mod 10;
			
			
			decSeg <= (Espera/10) mod 10;
			uniSeg <=  Espera mod 10; 

			
			--	-- instrucciones para mandar a escribir en LCD

 INSTRUCCION(0) <= LCD_INI("00"); 				-- INICIALIZAMOS LCD, CURSOR A HOME, CURSOR ON, PARPADEO ON.
 INSTRUCCION(1) <= POS(1,1);						-- EMPEZAMOS A ESCRIBIR EN LA LINEA 1, POSICIï¿½N 1
 INSTRUCCION(2) <= CHAR(MA);						-- Escribimos letra A Mayuscula
 INSTRUCCION(3) <= CHAR(MD);						-- Escribimos letra D Mayuscula
 INSTRUCCION(4) <= CHAR(MC);						-- Escribimos letra C Mayuscula
 INSTRUCCION(5) <= CHAR_ASCII(x"3D");			-- ESCRIBIMOS EL CARACTER "="
 INSTRUCCION(6) <= POS(1,10);			
 INSTRUCCION(7) <= CHAR_ASCII(x"20");			-- ESCRIBIMOS EL CARACTER space
 INSTRUCCION(8) <= CHAR(MAS);						-- Escribimos letra S Mayuscula
 INSTRUCCION(9) <= CHAR(ME);						-- Escribimos letra E Mayuscula
 INSTRUCCION(10) <= CHAR(MG);						-- Escribimos letra G Mayuscula
 INSTRUCCION(11) <= CHAR_ASCII(x"3D");			-- ESCRIBIMOS EL CARACTER "="
 INSTRUCCION(12) <= POS(2,1);
 INSTRUCCION(13) <= CHAR(MA);						-- Escribimos letra A Mayuscula
 INSTRUCCION(14) <= CHAR(MV);						-- Escribimos letra V Mayuscula
 INSTRUCCION(15) <= CHAR(MA);						-- Escribimos letra A Mayuscula
 INSTRUCCION(16) <= CHAR(MN);						-- Escribimos letra N Mayuscula
 INSTRUCCION(17) <= CHAR(MC);						-- Escribimos letra C Mayuscula
 INSTRUCCION(18) <= CHAR(ME);						-- Escribimos letra E Mayuscula
 INSTRUCCION(19) <= CHAR_ASCII(x"3D");			-- ESCRIBIMOS EL CARACTER "="
 INSTRUCCION(20) <= BUCLE_INI(1);
 INSTRUCCION(21) <= POS(1,5);
 INSTRUCCION(22) <= INT_NUM(TempVal_4);
 INSTRUCCION(23) <= POS(1,6);			
 INSTRUCCION(24) <= CHAR_ASCII(x"2E");
 INSTRUCCION(25) <= POS(1,7);			
 INSTRUCCION(26) <= INT_NUM(TempVal_3);
 INSTRUCCION(27) <= POS(1,8);			
 INSTRUCCION(28) <= INT_NUM(TempVal_2);
 INSTRUCCION(29) <= POS(1,9);			
 INSTRUCCION(30) <= INT_NUM(TempVal_1);
 INSTRUCCION(31) <= POS(1,15);			
 INSTRUCCION(32) <= INT_NUM(decSeg);
 INSTRUCCION(33) <= POS(1,16);			
 INSTRUCCION(34) <= INT_NUM(uniSeg);
 INSTRUCCION(35) <= POS(2,8);			
 INSTRUCCION(36) <= INT_NUM(cGr);
 INSTRUCCION(37) <= POS(2,9);			
 INSTRUCCION(38) <= INT_NUM(decGrad);
 INSTRUCCION(39) <= POS(2,10);			
 INSTRUCCION(40) <= INT_NUM(uniGrad);
 INSTRUCCION(41) <= BUCLE_FIN(1);				-- fin bucle
 
 

end Behavioral;

