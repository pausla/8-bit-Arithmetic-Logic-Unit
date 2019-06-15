library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;


ENTITY ALU is
	port(
		clk 			 : in  std_logic; --zegar do taktowania rejestu wyjsciowego
		change_state : in  std_logic_vector(3 downto 0);
		nreset		 : in  std_logic;
		col_line 	 : in  std_logic_vector(3 downto 0);
      row_line 	 : out std_logic_vector(3 downto 0);
		liczba		 : out std_logic_vector(3 downto 0);
		lcd_e        : out std_logic;
		lcd_rs       : out std_logic;
		lcd_rw       : out std_logic;
		lcd_db       : out std_logic_vector(7 downto 4);		
		borrow 		 : out std_logic :='0'
		);
end ALU;



architecture behavioral of ALU is

component MTX
	port( clk 		: in 	 std_logic;
			rst1		: in std_logic;
         col_line : in   std_logic_vector(3 downto 0);
         row_line : out  std_logic_vector(3 downto 0);
			liczba 	: out  std_logic_vector(3 downto 0);
         led 		: out  std_logic_vector(6 downto 0)
    );
end component;

component lcd16x2_ctrl is
  generic (
    CLK_PERIOD_NS : positive := 20);    -- 50MHz
  port (
			 clk          : in  std_logic;
			 rst          : in  std_logic;
			 lcd_e        : out std_logic;
			 lcd_rs       : out std_logic;
			 lcd_rw       : out std_logic;
			 lcd_db       : out std_logic_vector(7 downto 4);
			 line1_buffer : in  std_logic_vector(127 downto 0);  -- 16x8bit
			 line2_buffer : in  std_logic_vector(127 downto 0)
	 );

end component;

signal result_temp	  :std_logic_vector (7 downto 0);
signal result_temp_reg :std_logic_vector (7 downto 0);
signal line1           :std_logic_vector(127 downto 0);
signal line2           :std_logic_vector(127 downto 0);
signal led 				  :std_logic_vector(6 downto 0);
signal op 				  :std_logic_vector(6 downto 0);
signal liczba_temp 	  :std_logic_vector(3 downto 0);
signal line1_buffer    :std_logic_vector(127 downto 0); --lcd buffer
signal line2_buffer 	  :std_logic_vector(127 downto 0); --lcd buffer
signal col_line_in	  :std_logic_vector(3 downto 0);
signal row_line_in	  :std_logic_vector(3 downto 0);
signal rst_in			  :std_logic;
signal lcd_e_in		  :std_logic;
signal lcd_rs_in		  :std_logic;
signal lcd_db_in		  :std_logic_vector(7 downto 4);
signal lcd_rw_in		  :std_logic;
signal liczba1			  :std_logic_vector(3 downto 0);
signal liczba2			  :std_logic_vector(3 downto 0);

type state_type is(idle, read_number1, read_number2, operation, result); --stany
signal state: state_type;	

--function  divide (
--	liczba1 : std_logic_vector(3 downto 0);
--	liczba2 : std_logic_vector(3 downto 0)) 
--	return std_logic_vector is
--
--	variable a1 : std_logic_vector(3 downto 0) :=liczba1;
--	variable b1 : std_logic_vector(3 downto 0) :=liczba2;
--	variable p1 : std_logic_vector(4 downto 0):= (others => '0');
--	variable i : integer:=0; 
--	begin
--		for i in 0 to 3 loop
--			i:=i+1;
--			p1(3 downto 1) := p1(2 downto 0);
--			p1(0) := a1(3);
--			a1(3 downto 1) := a1(2 downto 0);			
--				p1 := p1-b1; 
--			if(p1(4) ='1') then --gdy p1<b1 czyli wynik p1-b1 ujemny
--				a1(0) :='0';
--				p1 := p1+b1;
--			else
--				a1(0) :='1';
--			end if;			
--		end loop;
--	return a1;
--end divide;


--function  mul (
--	liczba1 : std_logic_vector(3 downto 0);
--	liczba2 : std_logic_vector(3 downto 0)) 
--	return std_logic_vector is
--	
--	variable a1 : std_logic_vector(3 downto 0) :=liczba1;
--	variable b1 : std_logic_vector(3 downto 0) :=liczba2;
--	variable p1 : std_logic_vector(7 downto 0):= (others => '0');
--	variable i : integer:=0; 
--	begin
--		while b1>"0000" loop
--			p1 := p1+ a1;					
--			b1 := b1 - "0001";
--		end loop;
--	return p1;
--end mul;


begin

M1: MTX port map(clk =>clk,
					  rst1=>nreset,
					  col_line => col_line_in,
					  row_line =>row_line_in,
				     led =>led,
					  liczba => liczba_temp);
L1: lcd16x2_ctrl generic map(20)
					  port map(clk =>clk,
								  rst => rst_in, 
								  lcd_e =>lcd_e_in,
								  lcd_rs =>lcd_rs_in,
								  lcd_rw =>lcd_rw_in,
								  lcd_db =>lcd_db_in,
								  line1_buffer=>line1_buffer,
								  line2_buffer=>line2_buffer);
								  
 rst_in <= '0';

				
komb: process(change_state,nreset,clk, op, led, liczba_temp)
	begin
	if(nreset = '0') then
		result_temp_reg<= (others =>'0');
		borrow <= '0';
		state <= idle;
	elsif (clk'event and clk ='1') then
		case state is
			when idle =>
				if change_state = "0001" then
					state <= read_number1;
				end if;
			when read_number1 =>
			liczba1<=liczba_temp;
				if(liczba1(3)='0') then line1(127 downto 120) <=X"30"; 
				line1_buffer(127 downto 120) <= line1(127 downto 120);
				else line1(127 downto 120) <=X"31"; 
				line1_buffer(127 downto 120) <= line1(127 downto 120); end if;
				if(liczba1(2)='0') then line1(119 downto 112) <=X"30"; line1_buffer(119 downto 112) <= line1(119 downto 112);
				else line1(119 downto 112) <=X"31"; line1_buffer(119 downto 112) <= line1(119 downto 112); end if;
				if(liczba1(1)='0') then line1(111 downto 104) <=X"30"; line1_buffer(111 downto 104) <= line1(111 downto 104);
				else line1(111 downto 104) <=X"31"; line1_buffer(111 downto 104) <= line1(111 downto 104); end if; 			
				if(liczba1(0)='0') then line1(103 downto 96)  <=X"30"; line1_buffer(103 downto 96) <= line1(103 downto 96);
				else line1(103 downto 96)  <=X"31"; line1_buffer(103 downto 96) <= line1(103 downto 96); end if; --wyœwietl liczbe1
				line1(95 downto 88)<=X"20"; 
				line1(87 downto 80)<=X"20"; 
				line1(79 downto 72)<=X"20"; 
				line1(71 downto 64)<=X"20";
				line1(63 downto 56)<=X"20"; 
				line1(55 downto 48)<=X"20"; 
				line1(47 downto 40)<=X"20"; 
				line1(39 downto 32)<=X"20"; 
				line1(31 downto 24)<=X"20"; 
				line1(23 downto 16)<=X"20"; 
				line1(15 downto 8) <=X"20"; 
				line1(7 downto 0)  <=X"20";
				line1_buffer(95 downto 0) <= line1(95 downto 0);
				
				if change_state = "0011" then
				state <= operation;
				end if;				
			when operation =>
				op<=led;
				if change_state = "0111" then
					state <= read_number2;
				end if;
			when read_number2 =>
				liczba2<=liczba_temp;
				if(liczba2(3)='0') then line2(127 downto 120) <=X"30"; line2_buffer(127 downto 120) <= line2(127 downto 120);
				else line2(127 downto 120) <=X"31"; line2_buffer(127 downto 120) <= line2(127 downto 120); end if;
				if(liczba2(2)='0') then line2(119 downto 112) <=X"30"; line2_buffer(119 downto 112) <= line2(119 downto 112); 
				else line2(119 downto 112) <=X"31"; line2_buffer(119 downto 112) <= line2(119 downto 112); end if;
				if(liczba2(1)='0') then line2(111 downto 104) <=X"30"; line2_buffer(111 downto 104) <= line2(111 downto 104);
				else line2(111 downto 104) <=X"31"; line2_buffer(111 downto 104) <= line2(111 downto 104); end if;
				if(liczba2(0)='0') then line2(103 downto 96)  <=X"30"; line2_buffer(103 downto 96) <= line2(103 downto 96);
				else line2(103 downto 96)  <=X"31"; line2_buffer(103 downto 96) <= line2(103 downto 96); end if; --wyœwietl liczbe2
				line2(95 downto 88)<=X"20"; 
				line2(87 downto 80)<=X"20"; 
				line2(79 downto 72)<=X"20"; 
				line2(71 downto 64)<=X"20";
				line2(63 downto 56)<=X"20"; 
				line2(55 downto 48)<=X"20"; 
				line2(47 downto 40)<=X"20"; 
				line2(39 downto 32)<=X"20"; 
				line2(31 downto 24)<=X"20"; 
				line2(23 downto 16)<=X"20"; 
				line2(15 downto 8) <=X"20"; 
				line2(7 downto 0)  <=X"20";				
				line2_buffer(95 downto 0) <= line2(95 downto 0);
				if (led= "0001001" and liczba1<liczba2) then --odejmowanie  
					borrow <= '1'; --konieczny bit pozyczki jesli odjemna jest mniejsza od odjemnika 
				else
					borrow <= '0'; 
				end if;
				if change_state = "1111" then
					state <= result;
				end if;
			when result =>
				result_temp_reg <= result_temp;
				
				if(result_temp_reg(7)='0') then line1(127 downto 120) <=X"30"; line1_buffer(127 downto 120) <= line1(127 downto 120);
				else line1(127 downto 120) <=X"31"; line1_buffer(127 downto 120) <= line1(127 downto 120); end if;
				if(result_temp_reg(6)='0') then line1(119 downto 112) <=X"30"; line1_buffer(119 downto 112) <= line1(119 downto 112);
				else line1(119 downto 112) <=X"31"; line1_buffer(119 downto 112) <= line1(119 downto 112); end if;
				if(result_temp_reg(5)='0') then line1(111 downto 104) <=X"30"; line1_buffer(111 downto 104) <= line1(111 downto 104);
				else line1(111 downto 104) <=X"31"; line1_buffer(111 downto 104) <= line1(111 downto 104); end if;
				if(result_temp_reg(4)='0') then line1(103 downto 96)  <=X"30"; line1_buffer(103 downto 96) <= line1(103 downto 96);
				else line1(103 downto 96)  <=X"31"; line1_buffer(103 downto 96) <= line1(103 downto 96); end if;
				if(result_temp_reg(3)='0') then line1(95 downto 88)   <=X"30"; line1_buffer(95 downto 88) <= line1(95 downto 88);
				else line1(95 downto 88)   <=X"31"; line1_buffer(95 downto 88) <= line1(95 downto 88); end if; --wyœwietl wynik
				if(result_temp_reg(2)='0') then line1(87 downto 80) 	<=X"30"; line1_buffer(87 downto 80) <= line1(87 downto 80);
				else line1(87 downto 80)	<=X"31"; line1_buffer(87 downto 80) <= line1(87 downto 80); end if;
				if(result_temp_reg(1)='0') then line1(79 downto 72) 	<=X"30"; line1_buffer(79 downto 72) <= line1(79 downto 72);
				else line1(79 downto 72) 	<=X"31"; line1_buffer(79 downto 72) <= line1(79 downto 72); end if;
				if(result_temp_reg(0)='0') then line1(71 downto 64)  	<=X"30"; line1_buffer(71 downto 64) <= line1(71 downto 64);
				else line1(71 downto 64) 	<=X"31"; line1_buffer(71 downto 64) <= line1(71 downto 64); end if;
				line1(63 downto 56)<=X"20"; 
				line1(55 downto 48)<=X"20"; 
				line1(47 downto 40)<=X"20"; 
				line1(39 downto 32)<=X"20"; 
				line1(31 downto 24)<=X"20"; 
				line1(23 downto 16)<=X"20"; 
				line1(15 downto 8) <=X"20"; 
				line1(7 downto 0)  <=X"20"; 
				line1_buffer(63 downto 0) <= line1(63 downto 0);
							
				line2(127 downto 120) <=X"20";
				line2(119 downto 112) <=X"20"; 				
				line2(111 downto 104) <=X"20"; 
				line2(103 downto 96)  <=X"20"; --pusta linia
				line2_buffer(127 downto 96) <= line2(127 downto 96);
				if change_state = "0000" then
					state <= idle;
				end if;
			when others =>
				state<= idle;
		end case;
	end if;
end process;
		

--reg: process(clk, nreset)
--	begin
--	if (nreset='0')then	
--		result_temp_reg<= (others =>'0');
--		borrow <= '0';
--	elsif (clk'event and clk ='0') then -- dane ustawiane na zboczu opadaj¹cym
--		result_temp_reg <= result_temp; -- wartoœæ rejetru na wyjœcie
--		
--		if (op= "1001" and liczba1<liczba2) then --odejmowanie  
--				borrow <= '1'; --konieczny bit pozyczki jesli odjemna jest mniejsza od odjemnika 
--			else
--				borrow <= '0'; 
--		end if;
--		
--	end if;
--end process reg;
	
liczba <= liczba_temp;
row_line <= row_line_in;
col_line_in  <= col_line;
lcd_e <= lcd_e_in;
lcd_rs <= lcd_rs_in;
lcd_db <= lcd_db_in;
lcd_rw <= lcd_rw_in;

process(op, liczba1, liczba2)
	begin
		case op is
		when "0000001" =>	--and
			result_temp <= "0000" &(liczba1 and liczba2);
		when "0000010" =>	--or
			result_temp <= "0000" &(liczba1 or liczba2);	
		
		when "0000011" =>	--xor
			result_temp <= "0000" &(liczba1 xor liczba2);	
			
		when "0000100" =>	--not na argumencie
			result_temp <= "1111" &(not liczba1);	
			
		when "0000101" => --porównanie liczba1=liczba2
			if liczba1 = liczba2 then
			result_temp <= "11111111";
			else
			result_temp <= "00000000";
			end if;
			
		when "0000110" => --porównanie liczba1>liczba2
			if liczba1 > liczba2 then
			result_temp <= "11111111";
			else
			result_temp <= "00000000";
			end if;
			
		when "0000111" => --porównanie liczba1<liczba2
			if liczba1 < liczba2 then
			result_temp <= "11111111";
			else
			result_temp <= "00000000";
			end if;
						
		when "0001000" => --dodawanie
			result_temp <= "000" & (('0' & liczba1) + ('0' &liczba2));		
		
		when "0001001" => --odejmowanie  
			if liczba1>= liczba2 then 
			result_temp <= "0000" &(liczba1 - liczba2);
			else 
				result_temp <= "000" &(('1' & liczba1) - liczba2);
			end if;
			
		when "0001010" => --dzielenie
			result_temp <= "000" & (('0' & liczba1) + ('0' &liczba2));--"0000" & divide ( liczba1 , liczba2 ); --dzielenie
			
		when "0001011" => --mno¿enie
			result_temp <= "000" & (('0' & liczba1) + ('0' &liczba2));--mul (liczba1, liczba2);
		
		when others =>
			result_temp <= "00000000";
	end case;	
							
	end process;
			
end behavioral;

