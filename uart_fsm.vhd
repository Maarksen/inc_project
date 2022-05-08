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
  
  --when we are on read_bits sets bit_rec to 1
  BIT_REC <= '1' when state = READ_BITS
  else '0';
  --sets bit_vld to 1 if we are on valid_out
  BIT_VLD <= '1' when state = VALID_OUT
  else '0';
  --sets cnt_enabled when we are on start_bit or are reading bits
  CNT_ENABLED <= '1' when state = START_BIT or state = READ_BITS 
  else '0';

  process (CLK) begin 
    if rising_edge(CLK) then
      if RST = '1' then
        --we start on wait_start_bit
        state <= WAIT_START_BIT;
  
      elsif state = WAIT_START_BIT then
        --if constant 1 changes to constant 0
        --it is the start bit
        if DIN = '0' then
          --change state to start bit
          state <= START_BIT;
        end if;
        
      elsif state = START_BIT then
        --if cnt is on 24 we are int the middle
        -- of the first bit
        if CNT = "10110" then
          --we start reading bits
          state <= READ_BITS;
        end if;
        
      elsif state = READ_BITS then
        --if we count 8 bits it is over
        if BIT_CNT = "1000" then
          --end bit comes
          state <= END_READ;
        end if;
        
       elsif state = END_READ then
         --counts to 8
        if CNTSTOP = "1000" then
          --the output is valid
          state <= VALID_OUT;
        end if;
        --after all is finished
        --we are waiting again
       elsif state = VALID_OUT then
         state <= WAIT_START_BIT;
         
      end if;
    end if;
  end process;
end behavioral;

