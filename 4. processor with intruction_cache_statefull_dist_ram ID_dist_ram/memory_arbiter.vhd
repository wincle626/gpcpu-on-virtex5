library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.types.all;

entity memory_arbiter is
    port (
        cpuport1_mem_in : in memory_in;
        cpuport1_mem_out : out memory_out;
            
        cpuport2_mem_in : in memory_in;
        cpuport2_mem_out : out memory_out;
            
        ma_to_mem : out memory_in;   
        mem_to_ma : in memory_out;
        
        clk : in std_logic;
        reset : in std_logic
        );
end entity memory_arbiter;
    
architecture behaviour of memory_arbiter is
    type state_type is (port1grant,port2grant);
    signal current_state, next_state : state_type := port1grant;
    signal dummy_out : memory_out := (x"ffffffff", '0');
    signal dummy_in : memory_in := (x"ffffffff", '0', '0', x"ffffffff");
begin
  
  ----------------**** added later due to timing issues 24 nov*****-----
  ma_to_mem <=    cpuport1_mem_in when current_state = port1grant and cpuport2_mem_in.enable = '0' else
                  cpuport2_mem_in when current_state = port2grant else
                  dummy_in;
  
  cpuport1_mem_out <= mem_to_ma when current_state = port1grant else dummy_out;
               
  cpuport2_mem_out <= mem_to_ma when current_state = port2grant else dummy_out;
  ----------------**** added later due to timing issues *****-----
  
  
  state_process : process (clk, reset)
  begin
    if reset = '1' then
            current_state <= port1grant;
    elsif rising_edge (clk) then
            current_state <= next_state;
    end if;
  end process state_process;
    
    next_state_decode : process (current_state, cpuport1_mem_in.enable, cpuport2_mem_in.enable)
    begin
        case current_state is
            when port1grant => 
                if cpuport2_mem_in.enable = '1' then
                    next_state <= port2grant;
                else
                    next_state <= port1grant;
                end if;
            when others =>
                if cpuport2_mem_in.enable = '0' then
                    next_state <= port1grant;
                else
                    next_state <= port2grant;
                end if;
        end case;
  end process next_state_decode;


---**************commented out due to timing issue 24 nov**********-----------  
--  output : process (current_state, cpuport1_mem_in.enable, cpuport2_mem_in.enable, mem_to_ma)
--    begin
--    case current_state is
--      when port1grant =>
--        if cpuport1_mem_in.enable = '1' and cpuport2_mem_in.enable = '1' then
--          ma_to_mem <= (x"00000000", '0' , '0' , x"00000000");
--          cpuport1_mem_out <= (x"00000000", '0');
--          cpuport2_mem_out <= (x"00000000", '0');
--        else
--          ma_to_mem <= cpuport1_mem_in;
--          cpuport1_mem_out <= mem_to_ma;
--          cpuport2_mem_out <= (x"00000000", '0');  
--        end if;
--      when others =>
--          ma_to_mem <= cpuport2_mem_in;
--          cpuport1_mem_out <= (x"00000000", '0');
--          cpuport2_mem_out <= mem_to_ma;     
--    end case;    
--  end process;
---**************commented out due to timing issue**********----------- 
end architecture behaviour;                 
                          
    