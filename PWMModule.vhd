library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.std_logic_unsigned.all;



ENTITY PWMModule  is
generic( Max: natural := 1000000);

Port ( 
		clk		: in  STD_LOGIC;											--reloj de 50MHz
      rst		: in  STD_LOGIC;											--rst
		dato_R	: in  STD_LOGIC_VECTOR(7 downto 0);
		phases	: in  STD_LOGIC_VECTOR(1 downto 0);
      tEsp		: out INTEGER;
		Grad		: out INTEGER;
		leer		: out STD_LOGIC:='0';
		motor1	: out STD_LOGIC_VECTOR (1 downto 0)				-- Primer motor
      );                                 
end PWMModule  ;

ARCHITECTURE behavioral of PWMModule  is

signal	phaseA,phaseB	: STD_LOGIC;
signal	pulso,pulso_s	: NATURAL:=0; 
signal	pausa,pausa_s	: NATURAL:=0;
constant pos0           : INTEGER:=0;
signal	start				: STD_LOGIC:='0';
constant pos1           : INTEGER := 220000;   
constant pos2           : INTEGER := 440000;  
constant pos3           : INTEGER := 550000;  
constant pos4           : INTEGER := 660000;  
constant pos5           : INTEGER := 770000;  
constant pos6           : INTEGER := 880000;  
constant pos7           : INTEGER := 770000;  
constant pos8           : INTEGER := 660000;  
signal 	vel				: INTEGER RANGE 0 TO 9 :=0;
signal	PWM_Count   	: INTEGER RANGE 1 TO Max;							--1000000;


begin
phaseA		<= phases(1);
phaseB		<= phases(0);
tEsp			<= pausa;
Grad			<= pulso;

start			<= dato_R(0);
pulso			<= 5*(1+(to_integer(UNSIGNED(dato_R(4 downto 1)))));
pausa			<= 1+(to_integer(UNSIGNED(dato_R(7 downto 5))));

	--control para leer numero de pulsos del encoder en cuadratura sentido horario adición, antihorario resta.
		
	process (phaseA, phaseB, rst)
		begin
		if (rst='0') then
			nPulsos <= 0;
		elsif rising_edge(phaseA) then
			if  phaseB = '0' then
				nPulsos <= nPulsos + 1;
			else
				nPulsos <= nPulsos - 1;
			end if;	
		end if;
	end process;
	process (clk,start,rst,nPulsos)
		begin
			if (rst='0') then
				vel <= 4;
				pulso_s <= 0;
				leer <= '0';
			elsif start = '1' then
				if nPulsos <= pulso_s  then
					vel <= 1;
					vel <= 2 after 50ms;
					vel <= 3 after 100ms;
					vel <= 2 after 80ms;
				else 
					if rising_edge(clk) then
						pausa_s <= pausa_s + 1;
						if pausa_s = ((pausa+1) * 50000000)  then
							pulso_s <= pulso_s + (pulso+5);
							pausa_s <= 0;
							leer <= '0';
						else
							vel <= 4;
							leer <= '1';
						end if;
					end if;
				end if;
			elsif start = '0' then
				leer <= '0';
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