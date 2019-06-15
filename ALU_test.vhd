LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY ALU_test IS
END ALU_test;
 
ARCHITECTURE behavior OF ALU_test IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT ALU
    PORT(
         clk : IN  std_logic;
         change_state : IN  std_logic_vector(3 downto 0);
         nreset : IN  std_logic;
         col_line : IN  std_logic_vector(3 downto 0);
         row_line : OUT  std_logic_vector(3 downto 0);
         liczba : OUT  std_logic_vector(3 downto 0);
         lcd_e : OUT  std_logic;
         lcd_rs : OUT  std_logic;
         lcd_rw : OUT  std_logic;
         lcd_db : OUT  std_logic_vector(7 downto 4);
         borrow : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal change_state : std_logic_vector(3 downto 0) := (others => '0');
   signal nreset : std_logic := '0';
   signal col_line : std_logic_vector(3 downto 0) := (others => '0');
	signal op 		 :std_logic_vector(6 downto 0):= (others => '0');
	signal liczba1	 :std_logic_vector(3 downto 0):= (others => '0');
	signal liczba2  :std_logic_vector(3 downto 0):= (others => '0');

 	--Outputs
   signal row_line : std_logic_vector(3 downto 0);
   signal liczba : std_logic_vector(3 downto 0) := "0000";
   signal lcd_e : std_logic;
   signal lcd_rs : std_logic;
   signal lcd_rw : std_logic;
   signal lcd_db : std_logic_vector(7 downto 4);
   signal borrow : std_logic;
	signal result_temp	  :std_logic_vector (7 downto 0):="00000000";
	signal result_temp_reg :std_logic_vector (7 downto 0):="00000000";

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: ALU PORT MAP (
          clk => clk,
          change_state => change_state,
          nreset => nreset,
          col_line => col_line,
          row_line => row_line,
          liczba => liczba,
          lcd_e => lcd_e,
          lcd_rs => lcd_rs,
          lcd_rw => lcd_rw,
          lcd_db => lcd_db,
          borrow => borrow
        );

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for 50 ns;	
		change_state<="0000";
      wait for clk_period*5;
		nreset<='1';
		liczba1 <= "0001";
		op<="0000001";
		wait for clk_period*5;
		change_state<="0001";
		wait for clk_period*5;
		change_state<="0011";
		wait for clk_period*5;
		change_state<="0111";
		wait for clk_period*5;
		liczba2 <= "1011";
		wait for clk_period*5;
		change_state<="1111";
		wait for clk_period*10;
		nreset<='0';
		wait for clk_period*10;
		change_state <= "0000";
		
      wait;
   end process;

END;
