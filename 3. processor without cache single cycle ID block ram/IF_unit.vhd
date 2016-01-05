library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.std_logic_unsigned.all;
use work.types.all;

entity IF_unit is
    port (
        clk : in std_logic;
        res_and_stall : in control;
		    IF_to_mem : out memory_in;
		    mem_to_IF : in memory_out;
		    branch_deci : in branch;
		    stall_req : out std_logic;
		    fetched_inst : out instruction
        );
end entity IF_unit;

architecture behaviour of IF_unit is
  signal pc_to_mem : Tadr := x"fffffffc";
  signal incremented_pc : Tadr := x"00000000";
  signal pc_to_ID : Tadr := x"00000000"; 
  signal fetched_inst_temp : instruction;-- := (x"ffffffff", x"ffffffff", '0');

begin
  
  --pc_to_mem <= branch_deci.target when branch_deci.branch = '1' else
--               incremented_pc when res_and_stall.stall = '1' else
--               pc_to_mem;
  
  IF_to_mem.adr <= branch_deci.target when branch_deci.branch = '1' else
                   --incremented_pc when res_and_stall.stall = '1' else
                   pc_to_mem;
  
  --incremented_pc <= pc_to_mem + 4 when res_and_stall.stall = '1' else
  --                    incremented_pc;
  
  clked_process : process(clk) 
  begin  
    if rising_edge (clk) then
          
      if res_and_stall.res = '1' then
      
        --fetched_inst <= (x"ffffffff", x"ffffffff", '0');
        stall_req <= '0';
     
      elsif res_and_stall.stall = '0' then
        
        pc_to_mem <= pc_to_mem + 4;
        stall_req <= '1';
        pc_to_ID <= pc_to_mem;
        
        IF_to_mem.we <= '0';
        IF_to_mem.data <= x"ffffffff";	
        IF_to_mem.enable <= '1';   
         
        fetched_inst.pc <= fetched_inst_temp.pc;
        fetched_inst.ir <= fetched_inst_temp.ir;
        fetched_inst.valid <= fetched_inst_temp.valid;
      
      elsif mem_to_IF.rdy ='1' then
      	 
      	 stall_req <= '0';
      	 IF_to_mem.enable <= '0';
      	 
        fetched_inst_temp.pc <= pc_to_mem;     
        fetched_inst_temp.ir <= mem_to_IF.data;
        fetched_inst_temp.valid <= '1' ;
         
      end if;
      
      if res_and_stall.stall = '1' and branch_deci.branch = '1' then      
        pc_to_mem <= branch_deci.target;
      end if;
 
    end if;
  end process;
end architecture behaviour;