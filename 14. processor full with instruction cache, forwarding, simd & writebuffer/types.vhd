library ieee;
use ieee.numeric_bit.all;
use ieee.math_real.uniform;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

package types is
  subtype Rregs is natural range 31 downto 0;
  subtype Radr is natural range 31 downto 0;
  subtype Tadr is std_logic_vector(Radr);
  subtype Rdata is natural range 31 downto 0;
  subtype Tdata is std_logic_vector(Rdata);
  subtype Rimmediate is natural range 15 downto 0;
  subtype Timmediate is std_logic_vector(Rimmediate);
  
  subtype Ridx_a is natural range 20 downto 16;
  subtype Ridx_b is natural range 15 downto 11;
  subtype Ridx_d is natural range 25 downto 21;
  subtype Tidx is std_logic_vector(4 downto 0);
  
  ----------------------cache-------------------------
  subtype Rcache is natural range 255 downto 0;
  type Tcache is array(Rcache) of Tdata;
  subtype Rtag_array_size is natural range 15 downto 0;
  subtype Rtag_array_cell_size is std_logic_vector(21 downto 0);
  type Ttag is array(Rtag_array_size) of Rtag_array_cell_size;
  type Tvalid is array(Rtag_array_size) of std_logic;
 	subtype Rtag is natural range 31 downto 10;  --for accessing tag
	subtype Rline is natural range 9 downto 6;  --for accessing lines
  subtype Rblock is natural range 5 downto 2;  --for accessing blocks
  
  type state_type is (IDLE, ENABLE, WAIT_RDY);
  ---------------------------------------------------
  
  --------------SIMD--------------------
  subtype Rvector is natural range 3 downto 0;
  type Tvector is array(Rvector) of Tdata;
  constant init_vector: Tvector := (others=>(others=>'0'));
  ----------------------------------------

  type control is record
    res    : std_logic;
    stall  : std_logic;
  end record control;
  type branch is record
    branch : std_logic;
    target : Tadr;
  end record branch;
  type write_back is record
    d     : Tvector;
    d_valid:std_logic;
    idx_d : Tidx;
  end record write_back;
  type operand_type is record
    a     : Tvector;
    b     : Tvector;
    i     : Timmediate;
  end record operand_type;
  type instruction is record
    pc : Tadr;
    ir  : Tdata;
    valid  : std_logic;
  end record instruction;
  type instruction_decoded is record
    instr : instruction;
    idx_a, idx_b, idx_d : Tidx;
    load,loadi,store,alu, mul,perm,rdc8,tge,tse : std_logic;
    jmp,jz,jnz,call,relative,rfe : std_logic;
    alu_op : std_logic_vector(3 downto 0);
    mask:std_logic_vector(3 downto 0) ;
  end record instruction_decoded;
  procedure nop(signal instr : out instruction_decoded);
  type memory_in is record
    adr: Tadr;
    we : std_logic;
    enable : std_logic;
    data : Tdata;
  end record memory_in;
  type memory_out is record
    data: Tdata;
    rdy: std_logic;
  end record memory_out;
  type sul_bool is array(boolean) of std_ulogic;
  constant active_high: sul_bool := (
      FALSE => '0' ,
      TRUE  => '1' ); 
      
 constant memory_out_0 : memory_out := (data => (others => '0'), rdy => '0');  
 constant memory_in_0 : memory_in := (data => (others => '0'), enable => '0', we => '0', adr => (others => '0')); 
end package types;

package body types is
  procedure nop(signal instr : out instruction_decoded) is
  begin
    instr.instr.valid <= '0';
    instr.load <= '0';
    instr.loadi <= '0'; 
    instr.store <= '0';
    instr.alu <= '0';
    instr.jmp <= '0';
    instr.jz <= '0';
    instr.jnz <= '0';
    instr.relative <= '0';
    instr.call <= '0';
    instr.rfe <= '0';
  end procedure nop;  
end package body types;
