library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.std_logic_unsigned.all;
use work.types.all;

entity write_fifo is
generic(
SIZE : natural := 4); -- FIFO address width
port(
clk : in Std_Logic;
res : in Std_Logic;
cpu_from : in memory_in;
cpu_to : out memory_out;
mem_to : out memory_in;
mem_from : in memory_out);
end write_fifo;


architecture behaviour of write_fifo is
	subtype fifo_range is natural range 3 downto 0;
	type wbf is array(fifo_range) of Tdata;
	type stored_reg is array(fifo_range) of std_logic;
	signal stored : stored_reg := (others => '1');
	signal data_wr_bf : wbf := (others => (others => '0'));
	signal addr_wr_bf : wbf := (others => (others => '0'));
	signal valid_wr_bf : std_logic := '0';
	signal filling_count, storing_count : std_logic_vector(1 downto 0) := "00";
	signal full_check, empty_check : std_logic := '0';
	type state_type is (EMPTY, FULL, PARTIAL);
  signal current_state, next_state : state_type := EMPTY;
  signal buffer_filled_nw : std_logic := '0';
  
  --neu design
  signal empty_buffer, full_buffer, load_comm, store_comm : std_logic := '0';
  --


begin 
 
 load_comm <= '1' when cpu_from.enable = '1' and cpu_from.we = '0' and res = '0' else
              '0'; 
 store_comm <= '1' when cpu_from.enable = '1' and cpu_from.we = '1' and res = '0' else
              '0';
              
 empty_buffer <= '1' when stored(0) = '1' and stored(1) = '1' and stored(2) = '1' and stored(3) = '1' else
                       '0'; 
 full_buffer <= '1' when stored(0) = '0' and stored(1) = '0' and stored(2) = '0' and stored(3) = '0' else
                        '0';
                        
 state_process : process (clk, res)
 begin
   if res = '1' then
           current_state <= EMPTY;
   elsif rising_edge (clk) then
           current_state <= next_state;
   end if;
 end process state_process;
   
 next_state_decode : process (current_state, cpu_from, mem_from, load_comm, store_comm, filling_count)
 begin
   case current_state is
      when EMPTY => 
          if store_comm = '1' then
             next_state <= PARTIAL;
          else
             next_state <= EMPTY;
          end if;
      when FULL =>
          if mem_from.rdy = '1' then
             next_state <= PARTIAL;
           else
             next_state <= FULL;
           end if;
      when others => 
          if store_comm = '1' and filling_count = "11" then
             next_state <= FULL;
          elsif store_comm = '1' and filling_count /= "11" then
             next_state <= PARTIAL;
          elsif load_comm = '1' and filling_count = "01" and mem_from.rdy = '1' then
             next_state <= EMPTY;
          elsif load_comm = '1' then
             next_state <= PARTIAL;
          elsif store_comm = '0' and load_comm = '0' and filling_count = "01" and mem_from.rdy = '1' then
             next_state <= EMPTY;
          else
             next_state <= PARTIAL;
          end if;
    end case;
  end process;
    
  output_process : process (current_state, cpu_from, mem_from, load_comm, store_comm)
  begin
    case current_state is
      when EMPTY => 
        if load_comm = '1' then
          mem_to <= cpu_from;
          cpu_to.rdy <= '0';
        elsif store_comm = '1' then
          data_wr_bf(to_integer(unsigned(filling_count))) <= cpu_from.data;
          addr_wr_bf(to_integer(unsigned(filling_count))) <= cpu_from.adr;
          cpu_to.rdy <= '1';
          mem_to <= memory_in_0;
          stored(to_integer(unsigned(filling_count))) <= '0';
          filling_count <= filling_count + '1';
        else
          cpu_to.rdy <= '1';
          mem_to <= memory_in_0;
        end if;
      when PARTIAL => 
        if load_comm = '1' and mem_from.rdy = '0' then
          cpu_to.rdy <= '0';
          mem_to.enable <= '1';
          mem_to.we <= '1';
          mem_to.adr <= addr_wr_bf(to_integer(unsigned(storing_count)));
          mem_to.data <= data_wr_bf(to_integer(unsigned(storing_count)));
        elsif load_comm = '1' and mem_from.rdy = '1' then
          stored(to_integer(unsigned(storing_count))) <= '1';
          storing_count <= storing_count + 1;
          cpu_to.rdy <= '0';
        elsif store_comm = '1' then
          data_wr_bf(to_integer(unsigned(filling_count))) <= cpu_from.data;
          addr_wr_bf(to_integer(unsigned(filling_count))) <= cpu_from.adr;
          cpu_to.rdy <= '1';
          mem_to <= memory_in_0;
          stored(to_integer(unsigned(filling_count))) <= '0';
          filling_count <= filling_count + '1';
        elsif mem_from.rdy = '0' then
          cpu_to.rdy <= '1';
          mem_to.enable <= '1';
          mem_to.we <= '1';
          mem_to.adr <= addr_wr_bf(to_integer(unsigned(storing_count)));
          mem_to.data <= data_wr_bf(to_integer(unsigned(storing_count)));
        else
          cpu_to.rdy <= '1';
          stored(to_integer(unsigned(storing_count))) <= '1';
          storing_count <= storing_count + 1;
        end if;
      when others => 
        if (load_comm = '1' or store_comm = '1') and mem_from.rdy = '0' then
          cpu_to.rdy <= '0';
          mem_to.enable <= '1';
          mem_to.we <= '1';
          mem_to.adr <= addr_wr_bf(to_integer(unsigned(storing_count)));
          mem_to.data <= data_wr_bf(to_integer(unsigned(storing_count)));
        elsif mem_from.rdy = '1' then
          stored(to_integer(unsigned(storing_count))) <= '1';
          storing_count <= storing_count + 1;
          if load_comm = '1' then
            cpu_to.rdy <= '0';
          else
            cpu_to.rdy <= '1';
          end if;
        else
          cpu_to.rdy <= '1';
          mem_to.enable <= '1';
          mem_to.we <= '1';
          mem_to.adr <= addr_wr_bf(to_integer(unsigned(storing_count)));
          mem_to.data <= data_wr_bf(to_integer(unsigned(storing_count)));
        end if;  
    end case;     
  end process;
 end architecture behaviour; 
 
--  
-- load_comm <= '1' when cpu_from.enable = '1' and cpu_from.we = '0' and res = '0' else
--              '0'; 
-- store_comm <= '1' when cpu_from.enable = '1' and cpu_from.we = '1' and res = '0' else
--              '0';
-- 
-- empty_buffer <= '1' when stored(0) = '1' and stored(1) = '1' and stored(2) = '1' and stored(3) = '1' else
--                      '0'; 
-- full_buffer <= '1' when stored(0) = '0' and stored(1) = '0' and stored(2) = '0' and stored(3) = '0' else
--                       '0';
--
-- cpu_to.rdy <= '0' when (load_comm = '1' and mem_from.rdy = '0') or (full_buffer = '1' and (load_comm = '1' or store_comm = '1')) else
--               '1';
--               
-- cpu_to.data <= mem_from.data when mem_from.rdy = '1' else
--                x"ffffffff";
--                
-- mem_to.enable <= '1' when load_comm = '1' or empty_buffer = '0'
--                      
--  buff : process(cpu_from, mem_from, res)
--  begin
--    ---buffer is empty--------
--    if empty_buffer = '1' then
--      storing_count <= "00";
--      if cpu_from.enable = '1' and cpu_from.we = '0' then --load command
--        mem_to <= cpu_from;
--        filling_count <= "00";
--        if mem_from.rdy = '1' then
--          cpu_to <= mem_from;
--        else
--          cpu_to.rdy <= '0';
--        end if;
--      elsif cpu_from.enable = '1' and cpu_from.we = '1' then  --store command
--        data_wr_bf(0) <= cpu_from.data;
--        addr_wr_bf(0) <= cpu_from.adr;
--        stored(0) <= '0';
--        filling_count <= "01";
--        cpu_to.rdy <= '1';
--      else
--        filling_count <= "00";
--        mem_to.enable <= '0';
--      end if;
--
--    ---buffer is full--------      
--    elsif full_buffer = '1' then
----      storing_count <= "00";
----      filling_count <= "00";
--      cpu_to.rdy <= '0';
--      mem_to.enable <= '1';
--      mem_to.adr <= addr_wr_bf(to_integer(unsigned(storing_count)));
--      mem_to.data <= data_wr_bf(to_integer(unsigned(storing_count)));
--      mem_to.we <= '1';
--      if mem_from.rdy = '1' then
--        mem_to.enable <= '0';
--        mem_to.we <= '0';
--        storing_count <= storing_count + 1;
--        stored(to_integer(unsigned(storing_count))) <= '1';
--      else
--        stored(to_integer(unsigned(storing_count))) <= '0';
--      end if;
--        
--    ---buffer is neither empty nor full--------
--    else
--      if cpu_from.enable = '1' and cpu_from.we = '1' then  --store command
--        data_wr_bf(to_integer(unsigned(filling_count))) <= cpu_from.data;
--        addr_wr_bf(to_integer(unsigned(filling_count))) <= cpu_from.adr;
--        stored(to_integer(unsigned(filling_count))) <= '0';
--        filling_count <= filling_count + 1;
--        cpu_to.rdy <= '1';
--      elsif cpu_from.enable = '1' and cpu_from.we = '0' then  --load command
--        mem_to.enable <= '1';
--        mem_to.adr <= addr_wr_bf(to_integer(unsigned(storing_count)));
--        mem_to.data <= data_wr_bf(to_integer(unsigned(storing_count)));
--        mem_to.we <= '1';
--        if mem_from.rdy = '1' then
--          mem_to.enable <= '0';
--          mem_to.we <= '0';
--          storing_count <= storing_count + 1;
--          cpu_to <= mem_from;
--          stored(to_integer(unsigned(storing_count))) <= '1';
--        else
--          cpu_to.rdy <= '0';
--        end if;
--      else
--        mem_to.enable <= '1';
--        mem_to.adr <= addr_wr_bf(to_integer(unsigned(storing_count)));
--        mem_to.data <= data_wr_bf(to_integer(unsigned(storing_count)));
--        mem_to.we <= '1';
--        if mem_from.rdy = '1' then
--          mem_to.enable <= '0';
--          mem_to.we <= '0';
--          storing_count <= storing_count + 1;
--          stored(to_integer(unsigned(storing_count))) <= '1';
--        else
--          stored(to_integer(unsigned(storing_count))) <= '0';
--        end if;
--      end if;
--        
--    end if; --outer most if
--  end process;
--end architecture behaviour;
    

--
--begin 
--  
--  buffer_filled_nw <= '1' when stored(0) = '0' and stored(1) = '0' and stored(2) = '0' and stored(3) = '0' else
--                      '0';
--  
--  current_state <= FILL_BUFFER when cpu_from.enable = '1' and cpu_from.we = '1' and res = '0' and buffer_filled_nw = '0' else
--                LOAD when cpu_from.enable = '1' and cpu_from.we = '0' and res = '0' else
--                STORE;
--  
--  
--  output : process(current_state, cpu_from, mem_from, res, buffer_filled_nw)
--  begin
--    case current_state is
--      when FILL_BUFFER =>
--        if stored(to_integer(unsigned(filling_count))) = '1' then
--          data_wr_bf(to_integer(unsigned(filling_count))) <= cpu_from.data;
--          addr_wr_bf(to_integer(unsigned(filling_count))) <= cpu_from.adr;
--          stored(to_integer(unsigned(filling_count))) <= '0';
--          filling_count <= filling_count + 1;
--          cpu_to.rdy <= '1';
--        else
--          cpu_to.rdy <= '0';
--        end if;
--        
--      when STORE =>
--        if stored(to_integer(unsigned(storing_count))) = '0' then
--            mem_to.enable <= '1';
--            mem_to.adr <= addr_wr_bf(to_integer(unsigned(storing_count)));
--            mem_to.data <= data_wr_bf(to_integer(unsigned(storing_count)));
--            mem_to.we <= '1';
--            
--            if mem_from.rdy = '1' then
--              mem_to.enable <= '0';
--              mem_to.we <= '0';
--              storing_count <= storing_count + 1;
--              stored(to_integer(unsigned(storing_count))) <= '1';
--            else
--              storing_count <= storing_count;
--              --stored(to_integer(unsigned(storing_count))) <= '0';
--            end if;
--          else
--            mem_to.we <= '0';
--            mem_to.enable <= '0';            
--          end if;
--          
--        when others =>
--          if stored(to_integer(unsigned(storing_count))) = '0' then
--              mem_to.enable <= '1';
--              mem_to.adr <= addr_wr_bf(to_integer(unsigned(storing_count)));
--              mem_to.data <= data_wr_bf(to_integer(unsigned(storing_count)));
--              mem_to.we <= '1';
--              
--              if mem_from.rdy = '1' then
--                mem_to.enable <= '0';
--                mem_to.we <= '0';
--                storing_count <= storing_count + 1;
--                stored(to_integer(unsigned(storing_count))) <= '1';
--              else
--                storing_count <= storing_count;
--                stored(to_integer(unsigned(storing_count))) <= '0';
--              end if;
--            else
--              mem_to.enable <= '0';            
--            end if;
--            
--            if stored(0) = '1' and stored(1) = '1' 
--                  and stored(2) = '1' and stored(3) = '1' then
--                  mem_to <= cpu_from;
--                  if mem_from.rdy = '1' then
--                    cpu_to <= mem_from;
--                  else
--                    cpu_to.rdy <= '0';
--                  end if;
--            else
--              cpu_to.rdy <= '0';
--            end if;  
--            
--          end case;
--            
--  end process;

