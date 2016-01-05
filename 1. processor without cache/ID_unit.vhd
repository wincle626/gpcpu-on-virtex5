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
        decoded_instr_to_EXE : out instruction_decoded
        );
end entity ID_unit;

architecture behaviour of ID_unit is
  type RAM is array(Rregs) of Tdata;
  signal reg_file : RAM; 
  signal operand_A_from_reg_file : Tdata;
  signal operand_B_from_reg_file : Tdata;
  signal decoded_instr_to_EXE_temp : instruction_decoded := ((x"ffffffff", x"ffffffff", '0'), "11111", "11111", "11111", '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', "0000");
  signal i_local : Timmediate := x"ffff";
  
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
  --decoded_instr_to_EXE_temp.rfe <= fetched_inst.valid and active_high(fetched_inst.ir(31 downto 26)="111111");
  decoded_instr_to_EXE_temp.alu_op <= fetched_inst.ir(29 downto 26);
          
  i_local <= fetched_inst.ir(Rimmediate);
  
  reg_file_process : process(clk)
  begin
    if rising_edge (clk) then
      --reading operations
      if decoded_instr_to_EXE_temp.loadi = '1' then
        operand_A_from_reg_file <=  reg_file(to_integer(unsigned(fetched_inst.ir(Ridx_d))));
      else
        operand_A_from_reg_file <=  reg_file(to_integer(unsigned(fetched_inst.ir(Ridx_a))));
      end if;
      if decoded_instr_to_EXE_temp.store ='1' then
        operand_B_from_reg_file <= reg_file(to_integer(unsigned(fetched_inst.ir(Ridx_d))));
      else
        operand_B_from_reg_file <= reg_file(to_integer(unsigned(fetched_inst.ir(Ridx_b))));
      end if;
      
      --writing operation
      if WB_to_ID.d_valid = '1' then     
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
          
          if fetched_inst.valid <= '1' then   
            --forwarding decoded instructions & operands on clock
            decoded_instr_to_EXE <= decoded_instr_to_EXE_temp;
            operands_to_EXE.i <= i_local;
            
            if WB_to_ID.d_valid = '1' and WB_to_ID.idx_d = decoded_instr_to_EXE_temp.idx_a then
              operands_to_EXE.a <= WB_to_ID.d;
            else
              operands_to_EXE.a <= operand_A_from_reg_file;
            end if;
            
            if WB_to_ID.d_valid = '1' and WB_to_ID.idx_d = decoded_instr_to_EXE_temp.idx_b then
              operands_to_EXE.b <=  WB_to_ID.d;
            else
              operands_to_EXE.b <= operand_B_from_reg_file;
            end if; 
            
          end if;  
                      
        end if;
    end if;
  end process;
end architecture behaviour;

            --if decoded_instr_to_EXE_temp.alu_op = "1111" then
--              decoded_instr_to_EXE.alu_op <= "0000";
--            elsif decoded_instr_to_EXE_temp.alu_op = "1011" and to_integer(signed(i_local)) >= 0 then
--              decoded_instr_to_EXE.alu_op <= "0111";
--            elsif decoded_instr_to_EXE_temp.alu_op = "1011" and to_integer(signed(i_local)) < 0 then
--              decoded_instr_to_EXE.alu_op <= "0110";
--            elsif decoded_instr_to_EXE_temp.alu_op = "0110" and to_integer(signed(operand_B_from_reg_file)) < 0 then
--              decoded_instr_to_EXE.alu_op <= "0111";
--            elsif decoded_instr_to_EXE_temp.alu_op = "0111" and to_integer(signed(operand_B_from_reg_file)) < 0 then
--              decoded_instr_to_EXE.alu_op <= "0110";
--            else
--              decoded_instr_to_EXE.alu_op <= decoded_instr_to_EXE_temp.alu_op;
--            end if;
            
              
            --elsif decoded_instr_to_EXE_temp.alu = '1' and decoded_instr_to_EXE_temp.alu_op = "1111" then
--              operands_to_EXE.b <= std_logic_vector( resize(signed(i_local), operands_to_EXE.b'length) );
--            elsif decoded_instr_to_EXE_temp.alu = '1' and decoded_instr_to_EXE_temp.alu_op = "1011" and to_integer(signed(i_local)) >= 0 then
--              operands_to_EXE.b <= std_logic_vector( resize(signed(i_local), operands_to_EXE.b'length) );
--            elsif decoded_instr_to_EXE_temp.alu = '1' and decoded_instr_to_EXE_temp.alu_op = "1011" and to_integer(signed(i_local)) < 0 then
--              operands_to_EXE.b <= std_logic_vector( resize(signed((not i_local) + 1), operands_to_EXE.b'length) );
--            elsif decoded_instr_to_EXE_temp.alu = '1' and decoded_instr_to_EXE_temp.alu_op = "0110" and to_integer(signed(operand_B_from_reg_file)) < 0 then
--              operands_to_EXE.b <= std_logic_vector( signed((not operand_B_from_reg_file) + 1) );
--            elsif decoded_instr_to_EXE_temp.alu = '1' and decoded_instr_to_EXE_temp.alu_op = "0111" and to_integer(signed(operand_B_from_reg_file)) < 0 then
--              operands_to_EXE.b <= std_logic_vector( signed((not operand_B_from_reg_file) + 1) );

  
            --if decoded_instr_to_EXE_temp.alu = '1' then
--              if decoded_instr_to_EXE_temp.alu_op = "1111" then
--                operands_to_EXE.b <= std_logic_vector( resize(signed(i_local), operands_to_EXE.b'length) );
--              elsif decoded_instr_to_EXE_temp.alu_op = "1011" and to_integer(signed(i_local)) >= 0 then
--                operands_to_EXE.b <= std_logic_vector( resize(signed(i_local), operands_to_EXE.b'length) );
--              elsif decoded_instr_to_EXE_temp.alu_op = "1011" and to_integer(signed(i_local)) < 0 then
--                operands_to_EXE.b <= std_logic_vector( resize(signed((not i_local) + 1), operands_to_EXE.b'length) );
--              elsif decoded_instr_to_EXE_temp.alu_op = "0110" and to_integer(signed(operand_B_from_reg_file)) < 0 then
--                operands_to_EXE.b <= std_logic_vector( signed((not operand_B_from_reg_file.d) + 1 );
--              elsif decoded_instr_to_EXE_temp.alu_op = "0111" and to_integer(signed(operand_B_from_reg_file)) < 0 then
--                operands_to_EXE.b <= std_logic_vector( signed((not operand_B_from_reg_file.d) + 1 );
--              end if;
--            end if;
            


            
            --if decoded_instr_to_EXE_temp.alu = '1' then  
--              operands_to_EXE.a <=  reg_file(to_integer(unsigned(fetched_inst.ir(Ridx_a))));
--              if fetched_inst.ir(29 downto 26) = "1111" then
--                operands_to_EXE.b <= std_logic_vector( resize(signed(i_local), operands_to_EXE.b'length) );
--                decoded_instr_to_EXE.alu_op <= "0000";
--              elsif fetched_inst.ir(29 downto 26) = "1011" then
--                operands_to_EXE.b <= std_logic_vector( resize(signed(i_local), operands_to_EXE.b'length) );
--                decoded_instr_to_EXE.alu_op <= "0111";
--              else
--                operands_to_EXE.b <= reg_file(to_integer(unsigned(fetched_inst.ir(Ridx_b))));
--              end if;   
--            elsif decoded_instr_to_EXE_temp.store ='1' then    
--              operands_to_EXE.a <=  reg_file(to_integer(unsigned(fetched_inst.ir(Ridx_a))));
--              operands_to_EXE.b <= reg_file(to_integer(unsigned(fetched_inst.ir(Ridx_d)))); 
--            elsif decoded_instr_to_EXE_temp.loadi = '1' then
--              operands_to_EXE.a <=  reg_file(to_integer(unsigned(fetched_inst.ir(Ridx_d))));
--              operands_to_EXE.b <= reg_file(to_integer(unsigned(fetched_inst.ir(Ridx_b))));
--            else 
--              operands_to_EXE.a <=  reg_file(to_integer(unsigned(fetched_inst.ir(Ridx_a))));
--              operands_to_EXE.b <= reg_file(to_integer(unsigned(fetched_inst.ir(Ridx_b))));
--            end if;     
--            
--            if WB_to_ID.d_valid = '1' then     
--              reg_file(to_integer(unsigned(WB_to_ID.idx_d))) <= WB_to_ID.d;
--              if(WB_to_ID.idx_d = decoded_instr_to_EXE_temp.idx_a) then
--                operands_to_EXE.a <=  WB_to_ID.d;
--              end if;
--              if(WB_to_ID.idx_d = decoded_instr_to_EXE_temp.idx_b) and (decoded_instr_to_EXE_temp.alu_op /= "1111" and decoded_instr_to_EXE_temp.alu_op /= "1011") then
--                operands_to_EXE.b <=  WB_to_ID.d;
--              end if;     
--            end if;
    
          

