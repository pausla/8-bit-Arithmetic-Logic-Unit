library ieee;
use ieee.std_logic_1164.all;

-------------------------------------------------------------------------------

entity LCD is
  port (
    clk    : in  std_logic;
    lcd_e  : out std_logic;
    lcd_rs : out std_logic;
    lcd_rw : out std_logic;
    lcd_db : out std_logic_vector(7 downto 4));

end entity LCD;

-------------------------------------------------------------------------------

architecture behavior of LCD is

  -- 
  signal timer : natural range 0 to 100000000 := 0;
  signal switch_lines : std_logic := '0';
  signal line1 : std_logic_vector(127 downto 0);
  signal line2 : std_logic_vector(127 downto 0);
  

  -- component generics
  constant CLK_PERIOD_NS : positive := 20;  -- 50 Mhz

  -- component ports
  signal rst          : std_logic;
  signal line1_buffer : std_logic_vector(127 downto 0);
  signal line2_buffer : std_logic_vector(127 downto 0);

begin  -- architecture behavior

  -- component instantiation
  DUT : entity work.lcd16x2_ctrl
    generic map (
      CLK_PERIOD_NS => CLK_PERIOD_NS)
    port map (
      clk          => clk,
      rst          => rst,
      lcd_e        => lcd_e,
      lcd_rs       => lcd_rs,
      lcd_rw       => lcd_rw,
      lcd_db       => lcd_db,
      line1_buffer => line1_buffer,
      line2_buffer => line2_buffer);

  rst <= '0';

  -- see the display's datasheet for the character map
  line1(127 downto 120) <= X"20"; 
  line1(119 downto 112) <= X"20";
  line1(111 downto 104) <= x"50";  -- P
  line1(103 downto 96)  <= x"55";  -- U
  line1(95 downto 88)   <= x"4C";  -- L
  line1(87 downto 80)   <= X"20";   
  line1(79 downto 72)   <= X"32";  -- 2
  line1(71 downto 64)   <= X"30";  -- 0 
  line1(63 downto 56)   <= X"31";  -- 1
  line1(55 downto 48)   <= X"36";  -- 6
  line1(47 downto 40)   <= X"20";  
  line1(39 downto 32)   <= x"50";  -- P
  line1(31 downto 24)   <= x"55";  -- U 
  line1(23 downto 16)   <= x"4C";  -- L
  line1(15 downto 8)    <= X"20";
  line1(7 downto 0)     <= X"20";

  line2(127 downto 120) <= X"30";  -- 0 
  line2(119 downto 112) <= X"31";  -- 1
  line2(111 downto 104) <= X"32";  -- 2
  line2(103 downto 96)  <= X"33";  -- 3
  line2(95 downto 88)   <= X"34";  -- 4
  line2(87 downto 80)   <= X"35";  -- 5
  line2(79 downto 72)   <= X"36";  -- 6
  line2(71 downto 64)   <= X"37";  -- 7
  line2(63 downto 56)   <= X"38";  -- 8
  line2(55 downto 48)   <= X"39";  -- 9
  line2(47 downto 40)   <= X"3a";  -- :
  line2(39 downto 32)   <= X"3b";  -- ;
  line2(31 downto 24)   <= X"3c";  -- <
  line2(23 downto 16)   <= X"3d";  -- =
  line2(15 downto 8)    <= X"3e";  -- >
  line2(7 downto 0)     <= X"3f";  -- ?

  line1_buffer <= line2 when switch_lines = '1' else line1;
  line2_buffer <= line1 when switch_lines = '1' else line2;

  -- switch lines every second
  process(clk)
  begin
    if rising_edge(clk) then
      if timer = 0 then
        timer <= 100000000;
        switch_lines <= not switch_lines;
      else
        timer <= timer - 1;
      end if;
    end if;
      
  end process;
end architecture behavior;