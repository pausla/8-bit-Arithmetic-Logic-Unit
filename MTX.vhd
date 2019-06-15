LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
 
entity MTX is
port(
         clk : in std_logic;
			rst1: in std_logic;
         col_line : in   std_logic_vector(3 downto 0);
         row_line : out std_logic_vector(3 downto 0);
			liczba : out   std_logic_vector(3 downto 0);
         led : out   std_logic_vector(6 downto 0)
    );
end MTX;
 
architecture Behavioral of MTX is
signal temp : std_logic_vector(10 downto 0);
begin



test: process(clk, rst1) is
begin
if(rst1='0') then
led <= "0000000";
liczba <= "0000";
    elsif rising_edge(clk) then
         temp <= temp + 1;
         case temp(10 downto 8) is
			
		when "000" => row_line <= "1000"; --first row	 
				when "001" =>   
                 if col_line = "1000" then
                      led <= "0000001"; -- 1
							 liczba <= "0001";
                 elsif col_line = "0100" then
                      led <= "0000101"; -- 5
							 liczba <= "0101";
                 elsif col_line = "0010" then
                      led <= "0001001"; -- 9
                 elsif col_line = "0001" then
                      led <= "0001101"; -- 13
                 end if;
					  
					  
		when "010" => row_line <= "0100"; --second row
            when "011" =>
                 if col_line = "1000" then
                      led <= "0000010"; -- 2
							 liczba <= "0010";
                 elsif col_line = "0100" then
                      led <= "0000110"; -- 6
							 liczba <= "0110";
                 elsif col_line = "0010" then
                      led <= "0001010"; -- 10
                 elsif col_line = "0001" then
                      led <= "0001110"; -- 14
                 end if;				
					
					  
		when "100" => row_line <= "0010"; --third row
            when "101" =>
                 if col_line = "1000" then
                      led <= "0000011"; -- 3
							 liczba <= "0011";
                 elsif col_line = "0100" then
                      led <= "0000111"; -- 7
							 liczba <= "0111";
                 elsif col_line = "0010" then
                      led <= "0001011"; -- 11
                 elsif col_line = "0001" then
                      led <= "0001111"; -- 15
                 end if;	
        
					  
		when "110" => row_line <= "0001"; --fourth row
            when "111" =>
                 if col_line = "1000" then
                      led <= "0000100"; -- 4
							 liczba <= "0100";
                 elsif col_line = "0100" then
                      led <= "0001000"; -- 8
							 liczba <= "1000";
                 elsif col_line = "0010" then
                      led <= "0001100"; -- 12
                 elsif col_line = "0001" then
                      led <= "0010000"; -- 16
                 end if;	
        			  
		when others => led <= "0000000" ;
		liczba <= "0000";
		
         end case;
    end if;
end process;
end Behavioral;