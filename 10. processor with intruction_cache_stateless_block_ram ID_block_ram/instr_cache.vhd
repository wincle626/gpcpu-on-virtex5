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
  
  cache_hit <= '1' when (tag_register( to_integer(unsigned(cpu_from.adr(Rline)))) = cpu_from.adr(Rtag)) and valid_register( to_integer(unsigned(cpu_from.adr(Rline))) ) = '1' else
               '0';
  cpu_to.rdy <= cache_hit;

                
  cpu_to.data <= inst_cache(to_integer(unsigned(index_in_cache_read)));
 
 
    mem_to.adr <= cpu_from.adr(Rtag) & cpu_from.adr(Rline) & counter & "00";             
  
  mem_to.we <= '0';
  mem_to.data <= x"baadbaad";
  --debugger                

  index_in_cache_write <= cpu_from.adr(Rline) & counter;
  
  --debugger
  
  clked_process : process(clk)
  begin
    if rising_edge (clk) then
      if res = '1' then
        counter <= "0000";
        toggle_signal_for_rdy <= '0';
      else
		 if cache_hit = '0' and toggle_signal_for_rdy = '0' then
			mem_to.enable <= '1';
			toggle_signal_for_rdy <= '1';
		elsif (mem_from.rdy = '1') then
			inst_cache( to_integer(unsigned(index_in_cache_write)) ) <= mem_from.data;
			counter <= counter + 1;
			mem_to.enable <= '0';
			toggle_signal_for_rdy <= '0';
			
			 if counter = "1111" then
				tag_register( to_integer(unsigned(cpu_from.adr(Rline))) ) <= cpu_from.adr(Rtag);
				valid_register( to_integer(unsigned(cpu_from.adr(Rline))) ) <= '1';
			 end if;
		 end if;
      end if;
   end if;
			if falling_edge(clk) then
				index_in_cache_read <=	cpu_from.adr(Rline) & cpu_from.adr(Rblock);
			end if;
 
  end process clked_process;
  
end architecture behaviour; 
