-- uart_fsm.vhd: UART controller - finite state machine
-- Author(s): Marek Buch xbuchm02
--
library ieee;
use ieee.std_logic_1164.all;

entity UART_FSM is
port(
   CLK          : in std_logic;
   RST          : in std_logic;
   DIN          : in std_logic;
   CNT          : in std_logic_vector(4 downto 0);
   BIT_CNT      : in std_logic_vector(3 downto 0);
   CNTSTOP      : in std_logic_vector(3 downto 0);
   BIT_VLD      : out std_logic;
   BIT_REC      : out std_logic;
   CNT_ENABLED  : out std_logic
   );
end entity UART_FSM;

architecture behavioral of UART_FSM is
type CURR_STATE is (WAIT_START_BIT, START_BIT, READ_BITS, END_READ, VALID_OUT);
signal state : CURR_STATE := WAIT_START_BIT;
begin 
  
  BIT_REC <= '1' when state = READ_BITS
  else '0';
  BIT_VLD <= '1' when state = VALID_OUT
  else '0';
  CNT_ENABLED <= '1' when state = START_BIT or state = READ_BITS 
  else '0';

  process (CLK) begin 
    if rising_edge(CLK) then
      if RST = '1' then
        
        state <= WAIT_START_BIT;
  
      elsif state = WAIT_START_BIT then
        if DIN = '0' then
          state <= START_BIT;
        end if;
        
      elsif state = START_BIT then
        if CNT = "10110" then
          state <= READ_BITS;
        end if;
        
      elsif state = READ_BITS then
        if BIT_CNT = "1000" then
          state <= END_READ;
        end if;
        
       elsif state = END_READ then
        if CNTSTOP = "1000" then
          state <= VALID_OUT;
        end if;
        
       elsif state = VALID_OUT then
         state <= WAIT_START_BIT;
         
      end if;
    end if;
  end process;
end behavioral;

