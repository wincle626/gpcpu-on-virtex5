library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.std_logic_unsigned.all;
use work.types.all;

entity instr_cache is
  generic (
    LINE_ADR : natural := 4; --number of bits for the line address
    BLOCK_ADR : natural := 4 --number of bits for the block address inside a line
  );
  
  port (
    clk : in std_logic;
    res : in std_logic;
    
    cpu_from : in memory_in;
    cpu_to : out memory_out;
    
    mem_from : in memory_out;
    mem_to : out memory_in
    );        
end entity instr_cache;

architecture behaviour of instr_cache is
  
	signal inst_cache : Tcache := (others => (others => '0'));	
	signal tag_register : Ttag := (others => (others => '0'));
	signal valid_register : Tvalid := (others => '0');
  signal current_state, next_state : state_type := IDLE;
  signal cache_hit : std_logic;
  signal toggle_signal_for_rdy : std_logic;
  signal counter : std_logic_vector(BLOCK_ADR - 1 downto 0) := "0000";
  
  --debugger
  signal r_line, r_block : std_logic_vector(3 downto 0);
  signal index_in_cache_read, index_in_cache_write : std_logic_vector(7 downto 0);
  --debugger
  
begin
  
  cache_hit <= '1' when (tag_register( to_integer(unsigned(r_line))) = cpu_from.adr(Rtag)) and valid_register( to_integer(unsigned(r_line)) ) = '1' else
               '0';
            
  mem_to.adr <= cpu_from.adr(Rtag) & cpu_from.adr(Rline) & counter & "00";             
  mem_to.enable <= '1' when current_state = ENABLE or (current_state = WAIT_RDY and not (toggle_signal_for_rdy = '1')) else
                   '0';
  mem_to.we <= '0';
  mem_to.data <= x"baadbaad";
                 
  cpu_to.data <= inst_cache(to_integer(unsigned(index_in_cache_read)));
  cpu_to.rdy <= '1' when cache_hit = '1' and current_state = IDLE else
                '0';             
  
  --debugger                
  r_block <= cpu_from.adr(Rblock);
  r_line <= cpu_from.adr(Rline);
  index_in_cache_read <=	std_logic_vector(unsigned(shift_left(resize(unsigned(cpu_from.adr(9 downto 6)),	8),4)) +  unsigned(resize(unsigned(cpu_from.adr(5 downto 2)),8)));
  index_in_cache_write <= std_logic_vector(unsigned(shift_left(resize(unsigned(cpu_from.adr(9 downto 6)), 8),4)) +  unsigned(resize(unsigned(counter),8)));
  --debugger
  
  clked_process : process(clk)
  begin
    if rising_edge (clk) then
      if res = '1' then
        counter <= "0000";
        toggle_signal_for_rdy <= '0';
      else
        toggle_signal_for_rdy <= mem_from.rdy;
        current_state <= next_state;
        if mem_from.rdy = '1' then
          counter <= counter + 1;
          inst_cache( to_integer(unsigned(index_in_cache_write)) ) <= mem_from.data;
          if counter = "1111" then
            tag_register( to_integer(unsigned(cpu_from.adr(Rline))) ) <= cpu_from.adr(Rtag);
            valid_register( to_integer(unsigned(cpu_from.adr(Rline))) ) <= '1';
          end if;
        end if;
      end if;   
    end if;
  end process clked_process;
  
  next_state_decode : process (current_state, cpu_from, mem_from, tag_register, valid_register, toggle_signal_for_rdy, counter,clk)
  begin
    case current_state is
      when IDLE => 
        if tag_register( to_integer(unsigned(cpu_from.adr(Rline)))) = cpu_from.adr(Rtag) and valid_register( to_integer(unsigned(cpu_from.adr(Rline))) ) = '1' then
          next_state <= IDLE;
        else
          next_state <= ENABLE;
        end if;
      when ENABLE =>
        next_state <= WAIT_RDY;
      when others =>
        if counter /= "0000" and mem_from.rdy = '0' and toggle_signal_for_rdy = '1' then
          next_state <= ENABLE;
        elsif counter = "0000" and mem_from.rdy = '0' and toggle_signal_for_rdy = '1' then
          next_state <= IDLE;
        else
          next_state <= WAIT_RDY;
        end if;
    end case;
  end process next_state_decode;
end architecture behaviour; 
