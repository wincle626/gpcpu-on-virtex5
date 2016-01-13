library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_misc.all;
use IEEE.numeric_std.all;
use work.types.all;

--use work.memory_arbiter.all;
--use work.IF_unit.all;

library gaisler;
use gaisler.leon3.all;

entity cpu is
  generic (
    CACHE_LINE_ADR  :     natural := 4;
    CACHE_BLOCK_ADR :     natural := 4;
    WRITE_FIFO_ADR  :     natural := 4);
  port (
    clk             : in  std_logic;
    res             : in  std_logic;
    mem_in          : out memory_in;
    mem_out         : in  memory_out;
    irqi            : in  l3_irq_in_type;
    irqo            : out l3_irq_out_type
  );
end cpu;

architecture structure of cpu is
  signal control_signal : control := ('0', '0');
  
  signal cpu_port1_mem_in : memory_in := (x"ffffffff", '0', '0', x"ffffffff");   --for port 1 in cpu
  signal cpu_port1_mem_out : memory_out := (x"ffffffff", '0');
    
  signal cpu_port2_mem_in : memory_in := (x"ffffffff", '0', '0', x"ffffffff");   --for port 2 in cpu
  signal cpu_port2_mem_out : memory_out := (x"ffffffff", '0');
  
  signal branch_deci_to_IF_by_EXE : branch := ('0', x"ffffffff");        --for taking the decision whether to take the branch or not
  
  signal fetched_inst_to_ID_by_IF : instruction;-- := (x"ffffffff", x"ffffffff", '0');

  signal stall_req_by_IF : std_logic := '0';
  signal stall_req_by_MEM : std_logic := '0';
  
  signal from_WB_to_ID : write_back;-- := (x"ffffffff", '0', "11111");
  signal operands_to_EXE_by_ID : operand_type;-- := (x"ffffffff", x"ffffffff", x"ffff");
  signal decoded_instr_to_EXE_by_ID : instruction_decoded :=  ((x"ffffffff", x"ffffffff", '0'), "11111", "11111", "11111", '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', "0000", "0000");
  
  signal load_flag_to_MEM_by_EXE : std_logic := '0';  
  signal store_flag_to_MEM_by_EXE : std_logic := '0';    
  signal data_to_MEM_by_EXE : Tvector;-- := x"ffffffff";
  signal adr_to_MEM_by_EXE : Tadr := x"ffffffff";
  signal idx_d_to_MEM_by_EXE : Tidx := "11111";
  signal valid_flag_for_WB_from_EXE : std_logic := '0';
  
    signal IF_to_cache : memory_in;-- := (x"ffffffff", '0', '0', x"ffffffff");
  signal cache_to_IF : memory_out;-- := (x"ffffffff", '0');
  signal memory_to_cache : memory_out;-- := (x"ffffffff", '0');
  signal cache_to_memory : memory_in;-- := (x"ffffffff", '0', '0', x"ffffffff");
  signal cpu_hazard_out_IF : std_logic;   --for harard detection from load

       
begin
  
  control_signal.res <= res;
  control_signal.stall <= '1' when stall_req_by_IF = '1' or stall_req_by_MEM = '1' else
                          '0';
  
  
   ma : entity work.memory_arbiter -- component instantiation
    port map(
        cpuport1_mem_in => cache_to_memory, -- signal mappings
        cpuport1_mem_out => memory_to_cache,
        
        cpuport2_mem_in => cpu_port2_mem_in,             --expected from mem phase
        cpuport2_mem_out => cpu_port2_mem_out,
        
        ma_to_mem => mem_in,
        mem_to_ma => mem_out,
        
        clk => clk,
        reset => res
        );
		
  cache : entity work.instr_cache
    port map(
        clk => clk,
        res => control_signal.res,
       
        cpu_from => IF_to_cache,
        cpu_to => cache_to_IF,
      
        mem_from => memory_to_cache,
        mem_to => cache_to_memory 
      );
        
  ifunit : entity work.IF_unit -- component instantiation
    port map(
        clk => clk,
        res_and_stall => control_signal,
    	
	      IF_to_mem => IF_to_cache,
        mem_to_IF => cache_to_IF,
        
    
        branch_deci => branch_deci_to_IF_by_EXE,
        stall_req => stall_req_by_IF,                     -- check for future connection ?  
        fetched_inst => fetched_inst_to_ID_by_IF,
        hazard_detect_load => cpu_hazard_out_IF      --for harard detection from load                          
        );
        
  idunit : entity work.ID_unit
    port map (
        clk => clk,
        res_and_stall => control_signal,
        fetched_inst => fetched_inst_to_ID_by_IF,
        WB_to_ID => from_WB_to_ID,
          
        operands_to_EXE => operands_to_EXE_by_ID,
        decoded_instr_to_EXE => decoded_instr_to_EXE_by_ID,
        hazard_detect_load => decoded_instr_to_EXE_by_ID.load,    --for harard detection from load
        hazard_out_IF => cpu_hazard_out_IF,  --for harard detection from load as part of if
        branch_harzard_id => branch_deci_to_IF_by_EXE.branch
        );

 exeUnit : entity work.EXE_unit
    port map(
      clk => clk,
      res_and_stall => control_signal,
      operands_from_ID => operands_to_EXE_by_ID,
      decoded_instr_from_ID => decoded_instr_to_EXE_by_ID,
            
      branch_to_IF => branch_deci_to_IF_by_EXE,
      load_to_MEM => load_flag_to_MEM_by_EXE,
      store_to_MEM => store_flag_to_MEM_by_EXE,
    
      data_to_MEM => data_to_MEM_by_EXE,
      adr_to_MEM => adr_to_MEM_by_EXE,
      idx_d_to_MEM => idx_d_to_MEM_by_EXE,
      data_valid_flag_for_WB => valid_flag_for_WB_from_EXE,
      
      --forwarding
      wb_forwarded_from_EXE.d => data_to_MEM_by_EXE,
      wb_forwarded_from_EXE.d_valid => valid_flag_for_WB_from_EXE,
      wb_forwarded_from_EXE.idx_d => idx_d_to_MEM_by_EXE,
      
      wb_forwarded_from_MEM.d => from_WB_to_ID.d,
      wb_forwarded_from_MEM.d_valid => from_WB_to_ID.d_valid,
      wb_forwarded_from_MEM.idx_d => from_WB_to_ID.idx_d
    );

  memUnit : entity work.MEM_unit
    port map(
      clk => clk,
      res_and_stall => control_signal,
      
      memory_to_MEM => cpu_port2_mem_out,
      MEM_to_memory => cpu_port2_mem_in,
      
      load_inst_flag => load_flag_to_MEM_by_EXE,
      store_inst_flag => store_flag_to_MEM_by_EXE,
      
      adr_from_EXE => adr_to_MEM_by_EXE,
      data_from_EXE => data_to_MEM_by_EXE,
      idx_d_from_EXE => idx_d_to_MEM_by_EXE,
      data_valid_flag_for_WB_from_EXE => valid_flag_for_WB_from_EXE, 
      
      MEM_to_WB => from_WB_to_ID,
      stall_req => stall_req_by_MEM
    );
    
  op_disassembler1 : entity work.opcode_disassembler -- component instantiation  
     port map(
        Opcode => fetched_inst_to_ID_by_IF.ir
             );
             
  op_disassembler2 : entity work.opcode_disassembler -- component instantiation  
     port map(
        Opcode => decoded_instr_to_EXE_by_ID.instr.ir
             );
 
end architecture structure;