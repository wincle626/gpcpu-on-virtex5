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
	signal stored : stored_reg; -- := (others => '1');
	signal data_wr_bf : wbf; --:= (others => (others => '0'));
	signal addr_wr_bf : wbf; -- := (others => (others => '0'));
	signal valid_wr_bf : std_logic := '0';
	signal filling_count, filling_count_follower, storing_count : std_logic_vector(1 downto 0) := "00";
	type state_type is (EMPTY, FULL, PARTIAL);
  signal current_state, next_state : state_type := EMPTY;
  signal buffer_filled_nw : std_logic := '0';
  
  --neu design
  signal empty_buffer, full_buffer, load_comm, store_comm, take_load, valid_buff : std_logic := '0';
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
 
 --********************************writing to memory from buffer**********************
	mem_to.enable <= '1' when stored(to_integer(unsigned(storing_count))) = '0' or take_load = '1' else
					'0';
	mem_to.we <= '1' when stored(to_integer(unsigned(storing_count))) = '0' and take_load = '0' else
				'0';
	mem_to.adr <= cpu_from.adr when take_load = '1' else
				addr_wr_bf(to_integer(unsigned(storing_count)));
	mem_to.data <= data_wr_bf(to_integer(unsigned(storing_count)));
  
	cpu_to.rdy <= '0' when (load_comm = '1' and mem_from.rdy = '0') or (load_comm = '1' and mem_from.rdy = '1' and empty_buffer = '0') 
							or (store_comm = '1' and full_buffer = '1') else
					'1';
                        
state_process : process (clk, res)
begin
	if res = '1' then
		data_wr_bf <= (others => (others => '0'));
		addr_wr_bf <= (others => (others => '0'));
		stored <= (others => '1');
		valid_buff <= '0';
	elsif rising_edge (clk) then
		if mem_from.rdy /= '1' then
			if store_comm = '1' and full_buffer = '0' and stored(to_integer(unsigned(filling_count))) = '1' then
				if addr_wr_bf(to_integer(unsigned(filling_count_follower))) /= cpu_from.adr 
								and stored(to_integer(unsigned(filling_count_follower))) <= '1' then
					data_wr_bf(to_integer(unsigned(filling_count))) <= cpu_from.data;
					addr_wr_bf(to_integer(unsigned(filling_count))) <= cpu_from.adr;
					stored(to_integer(unsigned(filling_count))) <= '0';
					filling_count <= filling_count + 1;
					take_load <= '0';
					filling_count_follower <= filling_count;
					valid_buff <= '1';
				else
					filling_count <= filling_count;
				end if;
			elsif store_comm = '1' and full_buffer = '1' then
				take_load <= '0';
			elsif load_comm = '1' then
				if empty_buffer /= '1' then
					take_load <= '0';
				else
					take_load <= '1';
				end if;
			else
				take_load <= '0';
			end if;
			
			--may be move away
			--if empty_buffer = '1' then
				--storing_count <= filling_count;
			--	filling_count <= "00";
				--filling_count_follower <= "00";
			--end if;
			 if stored(to_integer(unsigned(storing_count))) = '1' and valid_buff = '1' then
				 storing_count <= storing_count + 1;
			 else
				 storing_count <= storing_count;	
			 end if;
			--may be move away
			
		elsif mem_from.rdy = '1' then
			storing_count <= storing_count + 1;
			stored(to_integer(unsigned(storing_count))) <= '1';
			if load_comm = '1' and empty_buffer = '1' then
				storing_count <= "00";
				filling_count <= "00";
				filling_count_follower	<= "00";
				stored <= (others => '1');
				take_load <= '0';
				data_wr_bf <= (others => (others => '0'));
				addr_wr_bf <= (others => (others => '0'));
				valid_buff <= '0';
			end if;
		end if;
	end if;
end process;
 end architecture behaviour; 
 
 
 
 
 
 
 
 
 
 
 