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
			AvncPhas		: IN INTEGER;
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


SIGNAL TempVal, TempVal_1 	: NATURAL;		-- para descomponer el contador de pulsos por cuadratura
SIGNAL TempVal_2, TempVal_3: NATURAL;		-- para descomponer el contador de pulsos por cuadratura
SIGNAL TempVal_4, TempVal_5: NATURAL;		-- para descomponer el contador de pulsos por cuadratura
SIGNAL GradosAvanz			: INTEGER;
SIGNAL centMill,decMill		: INTEGER;
SIGNAL uniMill,centenas		: INTEGER;
SIGNAL DECENAS,UNIDADES		: INTEGER;
SIGNAL RS_S, RW_S, E_S 		: STD_LOGIC;
SIGNAL DIR_S 					: INTEGER RANGE 0 TO 1024;
SIGNAL DELAY_COR 				: INTEGER RANGE 0 TO 1000;
SIGNAL uniSeg, decSeg	   : INTEGER RANGE 0 TO 9 :=0;		-- para descomponer el contador de pulsos por cuadratura
SIGNAL uniGrad,decGrad,cGr	: INTEGER RANGE 0 TO 9 :=0;		-- para descomponer el contador de pulsos por cuadratura
SIGNAL DIR 						: INTEGER RANGE 0 TO 1024 := 0;
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

			-- obtencion de valores de cuanto ha avanzado
			GradosAvanz <= (AvncPhas*360)/28880;
			centMill <= (GradosAvanz*100000) mod 10; 
			decMill  <= (GradosAvanz*10000) mod 10; 
			uniMill  <= (GradosAvanz*1000) mod 10; 
			centenas <= (GradosAvanz/100) mod 10;
			DECENAS  <= (GradosAvanz/10) mod 10;
			UNIDADES <= (GradosAvanz) mod 10;
--
			-- obtencion de valores de cuanto va avanzado
			cGr	  <= (Avance/100) mod 10;
			decGrad <= (Avance/10) mod 10;
			uniGrad <= Avance mod 10;

			-- obtencion de valores de cuanto tiempo va a esperar
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
 INSTRUCCION(13) <= CHAR(MP);						-- Escribimos letra A Mayuscula
 INSTRUCCION(14) <= CHAR(MA);						-- Escribimos letra V Mayuscula
 INSTRUCCION(15) <= CHAR(MAS);						-- Escribimos letra A Mayuscula
 INSTRUCCION(16) <= CHAR_ASCII(x"3D");
 INSTRUCCION(17) <= BUCLE_INI(1);
 INSTRUCCION(18) <= POS(1,5);
 INSTRUCCION(19) <= INT_NUM(TempVal_4);
 INSTRUCCION(20) <= POS(1,6);			
 INSTRUCCION(21) <= CHAR_ASCII(x"2E");
 INSTRUCCION(22) <= POS(1,7);			
 INSTRUCCION(23) <= INT_NUM(TempVal_3);
 INSTRUCCION(24) <= POS(1,8);			
 INSTRUCCION(25) <= INT_NUM(TempVal_2);
 INSTRUCCION(26) <= POS(1,9);			
 INSTRUCCION(27) <= INT_NUM(TempVal_1);
 INSTRUCCION(28) <= POS(1,15);			
 INSTRUCCION(29) <= INT_NUM(decSeg);
 INSTRUCCION(30) <= POS(1,16);			
 INSTRUCCION(31) <= INT_NUM(uniSeg);
 INSTRUCCION(32) <= POS(2,5);			
 INSTRUCCION(33) <= INT_NUM(cGr);
 INSTRUCCION(34) <= POS(2,6);			
 INSTRUCCION(35) <= INT_NUM(decGrad);
 INSTRUCCION(36) <= POS(2,7);			
 INSTRUCCION(37) <= INT_NUM(uniGrad);
 INSTRUCCION(38) <= POS(2,9);			
 INSTRUCCION(39) <= INT_NUM(centMill);
 INSTRUCCION(40) <= POS(2,10);			
 INSTRUCCION(41) <= INT_NUM(decMill);
 INSTRUCCION(42) <= POS(2,11);			
 INSTRUCCION(43) <= INT_NUM(uniMill);
 INSTRUCCION(44) <= POS(2,12);
 INSTRUCCION(45) <= CHAR_ASCII(x"2E");
 INSTRUCCION(46) <= POS(2,13);
 INSTRUCCION(47) <= INT_NUM(centenas);
 INSTRUCCION(48) <= POS(2,14);			
 INSTRUCCION(49) <= INT_NUM(DECENAS);
 INSTRUCCION(50) <= POS(2,15);			
 INSTRUCCION(51) <= INT_NUM(UNIDADES);
 INSTRUCCION(52) <= CREAR_CHAR(CHAR1);
 INSTRUCCION(53) <= POS(2,16);
 INSTRUCCION(54) <= CHAR_CREADO(CHAR1);
 INSTRUCCION(55) <= BUCLE_FIN(1);				-- fin bucle
 
end Behavioral;

