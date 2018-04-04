library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY PWMModule  is
generic( Max: natural := 1000000);

Port ( 
		clk		:  in  STD_LOGIC;											--reloj de 50MHz
      rst		:  in  STD_LOGIC;											--rst
		selector	:	in  STD_LOGIC;											--grado o medio grado p/ avanzar
		plusGS	:	in  STD_LOGIC;											-- de 1/2s en 1/2 seg tiempo en espera para leer adc
		start		:  in  STD_LOGIC;											--inicio de velocidades
		nPulsos	:	in  INTEGER RANGE 0 TO 999999 :=0 ;				-- contador de pulsos por cuadratura
		t			:  out INTEGER RANGE 1 TO 120 := 1;					--tiempo valor en entero para indicar segundos en espera
		step		:	out INTEGER RANGE 0 TO 999999	:= 0;				
      motor1	:  out STD_LOGIC_VECTOR (1 downto 0)				-- Primer motor
      );                                 
end PWMModule  ;

ARCHITECTURE behavioral of PWMModule  is

signal	PWM_Count   	: INTEGER range 1 to Max;--1000000;
signal 	vel				: INTEGER range 1 to 8;
signal	t_espera			: INTEGER range 0 to 120 := 0;	
signal	pulso,pulso_s	: natural := 0; --range 0 to 7339
signal	pausa,pausa_s	: natural := 0;
signal	grados			: natural := 0;
constant pos0           : INTEGER := 0;
constant pos1           : INTEGER := 180000;   
constant pos2           : INTEGER := 300000;  
constant pos3           : INTEGER := 240000;  

begin

t <= t_espera;
step <= grados;
	
	process (rst,selector,plusGS)
		begin
			if rst = '0' then
				pulso		<= 0;
				pausa		<= 0;
				grados 	<= 0;
				t_espera <= 0;
			elsif plusGS'event and plusGS = '0' then
				if selector = '1' then
					t_espera <= t_espera + 1;
					pausa <= t_espera * 50000000;
				else
					grados <= grados + 5;
					pulso <= pulso + 5;
				end if;
			end if;
		end process;
			

	process (clk,start,rst,nPulsos)
		begin
			if (rst='0') then
				vel <= 4;
				pulso_s <= 0;
			elsif start = '1' then
				if nPulsos <= pulso_s  then
					vel <= 1;
					vel <= 2 after 50ms;
					vel <= 3 after 100ms;
					vel <= 2 after 80ms;
				else 
					if rising_edge(clk) then
						pausa_s <= pausa_s + 1;
						if pausa_s = pausa then
							pulso_s <= pulso_s + pulso;
							pausa_s <= 0;
						else
							vel <= 4;
						end if;
					end if;
				end if;
			end if;
	end process;

	
    process( clk,PWM_Count,vel)
        begin
            if rising_edge(clk)then
            PWM_Count <= PWM_Count + 1;
            end if;
---------------------------------------------------------
---------------------------------------------------------
-------------motor principal-----------------------------
---------------------------------------------------------
    case (vel) is
        -- Velocidades sentido horario
        when 1 =>
            if PWM_Count <= pos1 then
                motor1 <= "10";
            else 
                motor1 <= "00";
            end if;
        when 2 =>
            if PWM_Count <= pos2 then
                motor1 <= "10";
            else
                motor1 <= "00";
            end if;
        when 3 =>
            if PWM_Count <= pos3 then
                motor1 <= "10";
            else
                motor1 <= "00";
            end if;
        
				-- PARO
		  when 4 =>
            if PWM_Count <= pos0  then 
                motor1 <= "00";
            else 
                motor1 <= "00";
            end if;
				-- Velocidades sentido anti-horario
		  when 5 =>
            if PWM_Count <= pos1  then 
                motor1 <= "01";
            else 
                motor1 <= "00";
            end if;
		  when 6 =>
            if PWM_Count <= pos2  then 
                motor1 <= "01";
            else 
                motor1 <= "00";
            end if;
        when 7 =>
            if PWM_Count <= pos3  then 
                motor1 <= "01";
            else 
                motor1 <= "00";
            end if;
        when others => 
            motor1 <= "00";
        end case;
end process;
end behavioral;