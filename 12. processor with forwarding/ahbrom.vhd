library IEEE;
use IEEE.std_logic_1164.all;
library grlib;
use grlib.amba.all;
use grlib.stdlib.all;
use grlib.devices.all;

-- sourcefiles:
--  ahbrom_mine.asm

entity ahbrom is
  generic (
    hindex  : integer := 0;
    haddr   : integer := 0;
    hmask   : integer := 16#fff#;
    pipe    : integer := 0;
    tech    : integer := 0;
    kbytes  : integer := 1);
  port (
    rst     : in  std_ulogic;
    clk     : in  std_ulogic;
    ahbsi   : in  ahb_slv_in_type;
    ahbso   : out ahb_slv_out_type
  );
end;
architecture rtl of ahbrom is
constant abits : integer := 15;
constant bytes : integer := 32768;
constant hconfig : ahb_config_type := (
  0 => ahb_device_reg ( VENDOR_GAISLER, GAISLER_AHBROM, 0, 0, 0),
  4 => ahb_membar(haddr, '1', '1', hmask), others => zero32);
signal romdata : std_logic_vector(31 downto 0);
signal addr : std_logic_vector(abits-1 downto 2);
signal hsel, hready : std_ulogic;
begin
  ahbso.hresp   <= "00"; 
  ahbso.hsplit  <= (others => '0'); 
  ahbso.hirq    <= (others => '0');
  ahbso.hcache  <= '1';
  ahbso.hconfig <= hconfig;
  ahbso.hindex  <= hindex;
  reg : process (clk)
  begin
    if rising_edge(clk) then 
      addr <= ahbsi.haddr(abits-1 downto 2);
    end if;
  end process;
  p0 : if pipe = 0 generate
    ahbso.hrdata  <= romdata;
    ahbso.hready  <= '1';
  end generate;
  p1 : if pipe = 1 generate
    reg2 : process (clk)
    begin
      if rising_edge(clk) then
        hsel <= ahbsi.hsel(hindex) and ahbsi.htrans(1);
        hready <= ahbsi.hready;
        ahbso.hready <=  (not rst) or (hsel and hready) or
          (ahbsi.hsel(hindex) and not ahbsi.htrans(1) and ahbsi.hready);
        ahbso.hrdata  <= romdata;
      end if;
    end process;
  end generate;
  comb : process (addr)
  begin
    case conv_integer(addr) is
		    when 16#00000# => romdata <= "00000100000000000000000000000000"; --SUB $0, $0, $0
		    when 16#00001# => romdata <= "10000111101000000000000000000000"; --LDIL $29, 0
		    when 16#00002# => romdata <= "10000011101000001111111111100000"; --LDIH $29, 65504
		    when 16#00003# => romdata <= "00111111100000000000000000000001"; --ADDI $28, $0, 1
		    when 16#00004# => romdata <= "00111111011000000000000010000000"; --ADDI $27, $0, 128
		    when 16#00005# => romdata <= "00111111010000000000000000000000"; --ADDI $26, $0, 0
		    when 16#00006# => romdata <= "00111111001000000000000000000000"; --ADDI $25, $0, 0
		    when 16#00007# => romdata <= "00111100001000000000000000110110"; --ADDI $1, $0, 54
		    when 16#00008# => romdata <= "01000100001111010000001000001100"; --ST.W $1, 524($29)
		    when 16#00009# => romdata <= "01000100000111010000001000000100"; --ST.W $0, 516($29)
		    when 16#0000A# => romdata <= "01000111100111010000001000001000"; --ST.W $28, 520($29)
		    when 16#0000B# => romdata <= "11011111111000000000000000001000"; --BL $31, 8
		    when 16#0000C# => romdata <= "11011000000000010000000000000011"; --BNZ 3, $1
		    when 16#0000D# => romdata <= "11011111111000000000000000000110"; --BL $31, 6
		    when 16#0000E# => romdata <= "11000000000000010000000000000000"; --JMP $1
		    when 16#0000F# => romdata <= "00111100011000010000000000000000"; --ADDI $3, $1, 0
		    when 16#00010# => romdata <= "11011111111000000000000000000011"; --BL $31, 3
		    when 16#00011# => romdata <= "01000100001000110000000000000000"; --ST.W $1, 0($3)
		    when 16#00012# => romdata <= "11010000000000001111111111111001"; --BRA -7
		    when 16#00013# => romdata <= "11011111110000000000000000001011"; --BL $30, 11
		    when 16#00014# => romdata <= "00101100010000011111111111111000"; --SARI $2, $1, -8
		    when 16#00015# => romdata <= "11011111110000000000000000001001"; --BL $30, 9
		    when 16#00016# => romdata <= "00001100001000010001000000000000"; --OR $1, $1, $2
		    when 16#00017# => romdata <= "00101100010000011111111111111000"; --SARI $2, $1, -8
		    when 16#00018# => romdata <= "11011111110000000000000000000110"; --BL $30, 6
		    when 16#00019# => romdata <= "00001100001000010001000000000000"; --OR $1, $1, $2
		    when 16#0001A# => romdata <= "00101100010000011111111111111000"; --SARI $2, $1, -8
		    when 16#0001B# => romdata <= "11011111110000000000000000000011"; --BL $30, 3
		    when 16#0001C# => romdata <= "00001100001000010001000000000000"; --OR $1, $1, $2
		    when 16#0001D# => romdata <= "11000000000111110000000000000000"; --JMP $31
		    when 16#0001E# => romdata <= "11011000000110010000000000000111"; --BNZ 7, $25
		    when 16#0001F# => romdata <= "10000111001000000000000000000000"; --LDIL $25, 0
		    when 16#00020# => romdata <= "10000011001000000000000000000100"; --LDIH $25, 4
		    when 16#00021# => romdata <= "00101111011110110000000000000001"; --SARI $27, $27, 1
		    when 16#00022# => romdata <= "11011000000110110000000000000010"; --BNZ 2, $27
		    when 16#00023# => romdata <= "00111111011000000000000010000000"; --ADDI $27, $0, 128
		    when 16#00024# => romdata <= "01000111011111010000000000000000"; --ST.W $27, 0($29)
		    when 16#00025# => romdata <= "00111111001110011111111111111111"; --ADDI $25, $25, -1
		    when 16#00026# => romdata <= "01000000001111010000001000000100"; --LD.W $1, 516($29)
		    when 16#00027# => romdata <= "00001000001000011110000000000000"; --AND $1, $1, $28
		    when 16#00028# => romdata <= "11010100000000011111111111110110"; --BZ -10, $1
		    when 16#00029# => romdata <= "01000000001111010000001000000000"; --LD.W $1, 512($29)
		    when 16#0002A# => romdata <= "11000000000111100000000000000000"; --JMP $30
     when others => romdata <= (others => '-');
  end case;
end process;
-- pragma translate_off
bootmsg : report_version 
generic map ("ahbrom" & tost(hindex) &
": 32-bit AHB ROM Module,  " & tost(bytes/4) & " words, " & tost(abits-2) & " address bits" );
-- pragma translate_on
end;




---- File: ahbrom_mine.asm
--.org 0x000000
--
--	sub $0, $0, $0
--	ldi $29, 0xFFE00000
--	addi $28, $0, 1
--	addi $27, $0, 0x80
--	addi $26, $0, 0
--	addi $25, $0, 0
--	addi $1, $0, 54
--	st.w $1, 0x20C($29)
--	st.w $0, 0x204($29)
--	st.w $28, 0x208($29)
--
--Loop:
--	bl $31, Get_word ;get cmd
--	bnz Next, $1
--	bl $31, Get_word ;get address
--	jmp $1
--Next:		
--	addi $3, $1, 0
--	bl $31, Get_word ;get data
--	st.w $1, 0($3)
--	bra Loop
--
--Get_word:
--	bl $30, Get_byte
--	sari $2, $1, -8
--	bl $30, Get_byte
--	or $1, $1, $2
--	sari $2, $1, -8
--	bl $30, Get_byte
--	or $1, $1, $2
--	sari $2, $1, -8
--	bl $30, Get_byte
--	or $1, $1, $2
--	jmp $31
--
--Get_byte:		
--	bnz UART_check, $25
--	ldi $25, 0x00040000 ; delay
--	sari $27, $27, 1
--	bnz LED_shift, $27
--	addi $27, $0, 0x80
--LED_shift:
--	st.w $27, 0($29) ; store led
--UART_check:	
--	addi $25, $25, -1
--	ld.w $1, 0x204($29)
--	and $1, $1, $28
--	bz Get_Byte, $1
--	ld.w $1, 0x200($29)
--	jmp $30
--
