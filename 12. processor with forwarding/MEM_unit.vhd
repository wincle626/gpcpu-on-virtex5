library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.std_logic_unsigned.all;
use work.types.all;

entity MEM_unit is
    port (
      clk : in std_logic;
      res_and_stall : in control;
      
      memory_to_MEM : in memory_out;
      MEM_to_memory : out memory_in;
      
      load_inst_flag : in std_logic;
      store_inst_flag : in std_logic;
      
      adr_from_EXE : in Tadr;
      data_from_EXE : in Tadr;
      idx_d_from_EXE : in Tidx;
      data_valid_flag_for_WB_from_EXE : in std_logic;
      
      MEM_to_WB : out write_back;
      stall_req : out std_logic
    );
end entity MEM_unit;

architecture behaviour of MEM_unit is
  signal data_from_memory : Tdata;
  signal memory_access_go_flag : std_logic;
  
begin
  
  MEM_to_memory.adr <= adr_from_EXE when load_inst_flag = '1' or store_inst_flag = '1' else
                       x"ffffffff";
  
  MEM_to_memory.we <= '1' when store_inst_flag = '1' and memory_access_go_flag = '1' else --toggle logic wrt memory.dry
                      '0';
                       
  MEM_to_memory.enable <= '1' when (load_inst_flag = '1' or store_inst_flag = '1') and memory_access_go_flag = '1' else
                          '0';
                       
  MEM_to_memory.data <= data_from_EXE when store_inst_flag = '1' else
                        x"ffffffff";
                       
  stall_req <= '1' when (load_inst_flag = '1' or store_inst_flag = '1') and memory_access_go_flag = '1' else
               '0';
                      
  clked_process : process(clk)
  begin
    if rising_edge (clk) then 
      if res_and_stall.res = '1' then
          
        --MEM_to_memory <= (x"ffffffff", '0', '0', x"ffffffff"); 
        MEM_to_WB <= (x"ffffffff", '0', "11111");
        memory_access_go_flag <= '1';
        --stall_req <= '0';
          
      elsif res_and_stall.stall = '0' then
        
        memory_access_go_flag <= '1';
        
        if load_inst_flag = '0' and store_inst_flag = '0' then
          if data_valid_flag_for_WB_from_EXE = '1' then
            MEM_to_WB.d <= data_from_EXE;
            MEM_to_WB.idx_d <= idx_d_from_EXE;
            MEM_to_WB.d_valid <= data_valid_flag_for_WB_from_EXE;
          end if;
        elsif load_inst_flag = '1' then
          MEM_to_WB.d <= data_from_memory;
          MEM_to_WB.idx_d <= idx_d_from_EXE;
          MEM_to_WB.d_valid <= '1';
        end if;
      
      elsif memory_to_MEM.rdy = '1' then --in stall logic
        
        data_from_memory <= memory_to_MEM.data;
        memory_access_go_flag <= '0';
      
      end if;
    end if;
  end process;
end architecture behaviour;