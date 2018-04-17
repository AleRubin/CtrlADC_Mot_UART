Library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity ROM_1 is
	Port (
			clk	: in  STD_LOGIC;
			we_enU: in 	STD_LOGIC_VECTOR(1 downto 0);
			dir_1 : in  STD_LOGIC_VECTOR(9 downto 0);
			D_ADC : in  STD_LOGIC_VECTOR(11 downto 0);
			D_out : out STD_LOGIC_VECTOR(11 downto 0)
			);
end ROM_1;

architecture Behavioral of ROM_1 is

	Type Ram is array (0 to 1023) of STD_LOGIC_VECTOR(11 downto 0);
	
	signal mem		: Ram;
	signal dir_2	: STD_LOGIC_VECTOR(9 downto 0);

	begin

ESCRIBIR_ROM:process (clk)
        begin
            if (rising_edge(clk)) then
                if (we_enU(1) = '1') then
                mem(conv_integer(dir_1)) <= D_ADC;
            end if;
        end if;
    end process;


	 
LEER_ROM:process (clk)
        begin
        if (rising_edge(clk)) then
            if we_enU(1) = '0' then
					D_out <= mem(conv_integer(dir_1));
            end if;
        end if;
    end process;
	
end Behavioral;