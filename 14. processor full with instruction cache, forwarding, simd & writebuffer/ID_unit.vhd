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
  signal reg_file_0, reg_file_1, reg_file_2, reg_file_3 : RAM := (others => (others => '0')); 
  signal operand_A_from_reg_file : Tdata;
  signal operand_B_from_reg_file : Tdata;
  signal decoded_instr_to_EXE_temp : instruction_decoded;
  signal i_local : Timmediate := x"ffff";
  signal addr_operand_A_from_reg_file : Tidx;
  signal addr_operand_B_from_reg_file : Tidx;
  signal bypass_control_a, bypass_control_b : std_logic;
  signal BRAM_addr_A, BRAM_addr_B : Tidx;
  signal wb_d_id_out : Tvector;
  signal operand_a_temp_reg, operand_b_temp_reg : Tvector;
  
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
  
  --*************************************************simd***********************************************************--------
  decoded_instr_to_EXE_temp.mul <= fetched_inst.valid and active_high(fetched_inst.ir(31 downto 26) = "001000");
  decoded_instr_to_EXE_temp.perm <= fetched_inst.valid and active_high(fetched_inst.ir(31 downto 26) = "001001");
  decoded_instr_to_EXE_temp.rdc8 <= fetched_inst.valid and active_high(fetched_inst.ir(31 downto 26) = "001010");
  decoded_instr_to_EXE_temp.tge <= fetched_inst.valid and active_high(fetched_inst.ir(31 downto 26) = "001100");
  decoded_instr_to_EXE_temp.tse <= fetched_inst.valid and active_high(fetched_inst.ir(31 downto 26) = "001101");
  decoded_instr_to_EXE_temp.mask <= fetched_inst.ir(19 downto 16) when fetched_inst.valid='1' 
                                                                            and fetched_inst.ir(31 downto 27) = "10000" else
                                    fetched_inst.ir(24 downto 21);
  ---------------------------------------------------------------------------------------------------------------------------
          
  
  --****************************operands handling***********************-----------------  
  operands_to_EXE.a <= wb_d_id_out when bypass_control_a = '1' else
                       operand_a_temp_reg;
                       
  operands_to_EXE.b <= wb_d_id_out when bypass_control_b = '1' else
                       operand_b_temp_reg;

  operand_a_temp_reg(0) <= reg_file_0(to_integer(unsigned(addr_operand_A_from_reg_file)));
  operand_a_temp_reg(1) <= reg_file_1(to_integer(unsigned(addr_operand_A_from_reg_file)));
  operand_a_temp_reg(2) <= reg_file_2(to_integer(unsigned(addr_operand_A_from_reg_file)));
  operand_a_temp_reg(3) <= reg_file_3(to_integer(unsigned(addr_operand_A_from_reg_file)));
  
  operand_b_temp_reg(0) <= reg_file_0(to_integer(unsigned(addr_operand_B_from_reg_file)));
  operand_b_temp_reg(1) <= reg_file_1(to_integer(unsigned(addr_operand_B_from_reg_file)));
  operand_b_temp_reg(2) <= reg_file_2(to_integer(unsigned(addr_operand_B_from_reg_file)));
  operand_b_temp_reg(3) <= reg_file_3(to_integer(unsigned(addr_operand_B_from_reg_file)));

  BRAM_addr_A <= fetched_inst.ir(Ridx_d) when decoded_instr_to_EXE_temp.loadi = '1' else
					       fetched_inst.ir(Ridx_a);
							
  BRAM_addr_B <= fetched_inst.ir(Ridx_d) when decoded_instr_to_EXE_temp.store = '1' else
					       fetched_inst.ir(Ridx_b);
  -----------------------------------------------------------------------------------------

  hazard_out_IF <= decoded_instr_to_EXE_temp.load;    --for harard detection from load

  reg_file_process : process(clk)
  begin
    if rising_edge (clk) then     
		
      --writing operation
			if WB_to_ID.d_valid = '1' and res_and_stall.stall = '0' then      
			  reg_file_0(to_integer(unsigned(WB_to_ID.idx_d))) <= WB_to_ID.d(0);
			  reg_file_1(to_integer(unsigned(WB_to_ID.idx_d))) <= WB_to_ID.d(1);
			  reg_file_2(to_integer(unsigned(WB_to_ID.idx_d))) <= WB_to_ID.d(2);
			  reg_file_3(to_integer(unsigned(WB_to_ID.idx_d))) <= WB_to_ID.d(3);
			end if;
			
			if res_and_stall.stall = '0' then 
				addr_operand_A_from_reg_file <= BRAM_addr_A;
				addr_operand_B_from_reg_file <= BRAM_addr_B;
			end if;
    end if;
  end process;
        
  output_process : process(clk)
  begin
    if rising_edge (clk) then 
        if res_and_stall.res = '1' then 
          
          decoded_instr_to_EXE <= ((x"ffffffff", x"ffffffff", '0'), "11111", "11111", "11111", '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', "0000", "0000");
          operands_to_EXE.i <= x"0000";
			     wb_d_id_out <= (others=>(others=>'0'));		
			     bypass_control_b <= '0';
			     bypass_control_a <= '0';
          
        elsif res_and_stall.stall = '0' then
          
            --forwarding decoded instructions & operands on clock
        decoded_instr_to_EXE <= decoded_instr_to_EXE_temp;
        --hazard detection
        if hazard_detect_load = '0' and branch_harzard_id = '0' then
          decoded_instr_to_EXE.instr.valid <= '1';
        else
          --decoded_instr_to_EXE.instr.valid <= '0';
	  decoded_instr_to_EXE <= ((x"ffffffff", x"c8000000", '0'), "11111", "11111", "11111", '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', "0000", "0000");
          
        end if;
				operands_to_EXE.i <= fetched_inst.ir(Rimmediate);
				wb_d_id_out <=  WB_to_ID.d;
				if WB_to_ID.d_valid = '1' and WB_to_ID.idx_d = BRAM_addr_A then
					bypass_control_a <= '1';
				else
					bypass_control_a <= '0';
				end if;
				
				if WB_to_ID.d_valid = '1' and WB_to_ID.idx_d = BRAM_addr_B then
					bypass_control_b <= '1';
				else
					bypass_control_b <= '0';
				end if;
                      
        end if;
    end if;
  end process;
end architecture behaviour;
    
          

