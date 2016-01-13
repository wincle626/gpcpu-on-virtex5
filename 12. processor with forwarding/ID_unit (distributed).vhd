library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.std_logic_unsigned.all;
use work.types.all;

entity ID_unit is
    port (
        clk : in std_logic;
        res_and_stall : in control;
        fetched_inst : in instruction;
        WB_to_ID : in write_back;
        
        operands_to_EXE : out operand_type;
        decoded_instr_to_EXE : out instruction_decoded;
        hazard_detect_load : in std_logic;    --for harard detection from load
        hazard_out_IF : out std_logic;   --for harard detection from load as part of if
        branch_harzard_id : in std_logic
        );
end entity ID_unit;

architecture behaviour of ID_unit is
  type RAM is array(Rregs) of Tdata;
  signal reg_file : RAM;-- := (others => (others => '0')); 
  signal operand_A_from_reg_file : Tdata;
  signal operand_B_from_reg_file : Tdata;
  signal decoded_instr_to_EXE_temp : instruction_decoded;
  signal i_local : Timmediate := x"ffff";
    signal addr_operand_A_from_reg_file : Tidx;
  signal addr_operand_B_from_reg_file : Tidx;
  signal bypass_control_a, bypass_control_b : std_logic;
  signal BRAM_addr_A, BRAM_addr_B : Tidx;
  signal operands_to_EXE_temp : operand_type;
  signal wb_d_id_out : Tdata;
  signal operand_a_temp_reg, operand_b_temp_reg : Tdata;
  
begin
  
  decoded_instr_to_EXE_temp.instr <= fetched_inst;  
  decoded_instr_to_EXE_temp.loadi <= fetched_inst.valid and active_high(fetched_inst.ir(31 downto 27) = "10000");         
  
  decoded_instr_to_EXE_temp.idx_a <= fetched_inst.ir(Ridx_d) when decoded_instr_to_EXE_temp.loadi = '1' else
                                     fetched_inst.ir(Ridx_a);
                                  
  decoded_instr_to_EXE_temp.idx_b <= fetched_inst.ir(Ridx_d) when decoded_instr_to_EXE_temp.store = '1' else
                                     fetched_inst.ir(Ridx_b);
  
  decoded_instr_to_EXE_temp.idx_d <= fetched_inst.ir(Ridx_d);
                                  
  decoded_instr_to_EXE_temp.load <= fetched_inst.valid and active_high(fetched_inst.ir(31 downto 26) = "010000");
  decoded_instr_to_EXE_temp.store <= fetched_inst.valid and active_high(fetched_inst.ir(31 downto 26) = "010001");
  decoded_instr_to_EXE_temp.alu <= fetched_inst.valid and active_high(fetched_inst.ir(31 downto 30) = "00");
  decoded_instr_to_EXE_temp.jmp <= fetched_inst.valid and ((active_high(fetched_inst.ir(31 downto 26) = "110000")) or (active_high(fetched_inst.ir(31 downto 26) = "110100")));
  decoded_instr_to_EXE_temp.jz <= fetched_inst.valid and active_high(fetched_inst.ir(31 downto 26) = "110101"); 
  decoded_instr_to_EXE_temp.jnz <= fetched_inst.valid and active_high(fetched_inst.ir(31 downto 26) = "110110");
  decoded_instr_to_EXE_temp.call <= fetched_inst.valid and ((active_high(fetched_inst.ir(31 downto 26) = "110011")) or (active_high(fetched_inst.ir(31 downto 26) = "110111")));
  decoded_instr_to_EXE_temp.relative <= fetched_inst.valid and active_high(fetched_inst.ir(31 downto 28) = "1101");
  decoded_instr_to_EXE_temp.alu_op <= fetched_inst.ir(29 downto 26);
          
  --i_local <= fetched_inst.ir(Rimmediate);
  
  operands_to_EXE_temp.a <= WB_to_ID.d when WB_to_ID.d_valid = '1' and WB_to_ID.idx_d = addr_operand_A_from_reg_file else
                       reg_file(to_integer(unsigned(addr_operand_A_from_reg_file)));
                       
  operands_to_EXE_temp.b <= WB_to_ID.d when WB_to_ID.d_valid = '1' and WB_to_ID.idx_d = addr_operand_B_from_reg_file else
                       reg_file(to_integer(unsigned(addr_operand_B_from_reg_file)));

hazard_out_IF <= decoded_instr_to_EXE_temp.load;    --for harard detection from load
                       
  operands_to_EXE_temp.i <= fetched_inst.ir(Rimmediate);
  
  
  addr_operand_A_from_reg_file <= fetched_inst.ir(Ridx_d) when decoded_instr_to_EXE_temp.loadi = '1' else
                                  fetched_inst.ir(Ridx_a);
                                  
  addr_operand_B_from_reg_file <= fetched_inst.ir(Ridx_d) when decoded_instr_to_EXE_temp.store ='1' else
                                  fetched_inst.ir(Ridx_b);
							  
 						  
  
  reg_file_process : process(clk)
  begin
    if rising_edge (clk) then
      
      --writing operation
      if WB_to_ID.d_valid = '1' and res_and_stall.stall = '0' then     
        reg_file(to_integer(unsigned(WB_to_ID.idx_d))) <= WB_to_ID.d;
      end if;
    end if;
  end process;
        
  output_process : process(clk)
  begin
    if rising_edge (clk) then 
        if res_and_stall.res = '1' then 
          
          decoded_instr_to_EXE <= ((x"ffffffff", x"ffffffff", '0'), "11111", "11111", "11111", '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', "0000");
          operands_to_EXE <= (x"ffffffff", x"ffffffff", x"ffff");
          
        elsif res_and_stall.stall = '0' then
           
            --forwarding decoded instructions & operands on clock
            decoded_instr_to_EXE <= decoded_instr_to_EXE_temp;
        if hazard_detect_load = '0' and branch_harzard_id = '0' then
          decoded_instr_to_EXE.instr.valid <= '1';
        else
          decoded_instr_to_EXE.instr.valid <= '0';
        end if;
            operands_to_EXE <= operands_to_EXE_temp; 
	
                      
        end if;
    end if;
  end process;
end architecture behaviour;
    
          

