-- uart.vhd: UART controller - receiving part
-- Author(s): Marek Buch xbuchm02

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity UART_RX is
port( 
  CLK      : in std_logic;
  RST      : in std_logic;
  DIN      : in std_logic;
  DOUT     : out std_logic_vector(7 downto 0);
  DOUT_VLD : out std_logic
);
end UART_RX;   

architecture behavioral of UART_RX is
signal cnt        : std_logic_vector(4 downto 0):= "00001" ;
signal cnt_bit    : std_logic_vector(3 downto 0):= "0000" ;
signal cnt_stop   : std_logic_vector(3 downto 0):= "0000" ;
signal cnts_enbld : std_logic := '0';
signal rec        : std_logic := '0';
signal bit_vld    : std_logic := '0';
begin
  
  --my finite state machine
  FSM: entity work.UART_FSM(behavioral)
    port map (
        --clock
        CLK => CLK,
        --reset 
        RST => RST,
        --input to our circuit   
        DIN => DIN,
        --counter 
        CNT => cnt,
        --bit counter   
        BIT_CNT => cnt_bit,
        --recieves bits
        BIT_REC => rec,
        --validates data 
        BIT_VLD => bit_vld,
        --enables counters
        CNT_ENABLED => cnts_enbld,
        --counter to end_read
        CNTSTOP => cnt_stop  
    );
  
    
    process(CLK) begin
      if rising_edge(CLK) then
        
        --sets to default
        DOUT_VLD <= '0';
        
        if cnts_enbld = '1' then
          --increments count
          cnt <= cnt + "1";  
        else
          --sets to 1
          cnt <= "00001";  
        end if;
        
        --sets to default
        if rst = '1' then
          DOUT <= "00000000"; 
        end if;
        
        if bit_vld = '0' then
          bit_vld <= '1'; 
        end if;
        
        --when cnt_bits is max
        if cnt_bit = "1000" then
           --increments counter
           cnt_stop <= cnt_stop + "1";
        end if;
        --when cnt_stop is 8 resets counters and out is valid 
        if cnt_stop = "1000" then
            DOUT_VLD <= '1';
            cnt_bit  <= "0000";
            cnt_stop <= "0000";
        end if;
       
        if rec = '1' then
          
          if cnt(4) = '1' then
            --sets cnt to 1
            cnt <= "00001"; 
            
            case cnt_bit is
              --outputs 0
              when "0000" => DOUT(0) <= DIN;
              --outputs 1
              when "0001" => DOUT(1) <= DIN;
              --outputs 2 
              when "0010" => DOUT(2) <= DIN;
              --outputs 3 
              when "0011" => DOUT(3) <= DIN;
              --outputs 4 
              when "0100" => DOUT(4) <= DIN;
              --outputs 5 
              when "0101" => DOUT(5) <= DIN;
              --outputs 6  
              when "0110" => DOUT(6) <= DIN;
              --outputs 7 
              when "0111" => DOUT(7) <= DIN;  
              when others => null;
            end case;
            
            --adds 1 to the count of bits
            cnt_bit <= cnt_bit + "1";   
            
          end if; 
      end if;
  end if;
end process;

end behavioral;