library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_misc.all;
use IEEE.numeric_std.all;
use IEEE.std_logic_unsigned.all;
library grlib;
use grlib.amba.all;
use grlib.stdlib.all;
library gaisler;
use gaisler.leon3.all;
library techmap;
use techmap.gencomp.all;
library work;
use work.types.all;

entity cpu_ahb is
  generic (
    hindex1         :     integer                  := 0;
    hindex2         :     integer                  := 1;
    fabtech         :     integer range 0 to NTECH := DEFFABTECH;
    memtech         :     integer range 0 to NTECH := DEFMEMTECH;
    coreid          :     integer                  := 0;
    numcores        :     integer                  := 1;
    CACHE_LINE_ADR  :     natural                  := 4;
    CACHE_BLOCK_ADR :     natural                  := 4;
    WRITE_FIFO_ADR  :     natural                  := 4
    );
  port (
    clk             : in  std_logic;
    resn            : in  std_logic;
    ahbi            : in  ahb_mst_in_type;
    ahbo1           : out ahb_mst_out_type;
    ahbo2           : out ahb_mst_out_type;
    apbsi           : in  apb_slv_in_type;
    apbso           : in  apb_slv_out_type;
    irqi            : in  l3_irq_in_type;
    irqo            : out l3_irq_out_type
    );
end cpu_ahb;

architecture beh of cpu_ahb is
  signal res     : std_logic;
  signal mem_in  : memory_in;
  signal mem_out : memory_out;

  type Tstate is (IDLE,WAITING,ADDR,DATA,TAIL);
  signal state : Tstate;

  component cpu
    generic (
      CACHE_LINE_ADR  :     natural;
      CACHE_BLOCK_ADR :     natural;
      WRITE_FIFO_ADR  :     natural);
    port (
      clk             : in  std_logic;
      res             : in  std_logic;
      mem_in          : out memory_in;
      mem_out         : in  memory_out;
      irqi            : in  l3_irq_in_type;
      irqo            : out l3_irq_out_type);
  end component;
begin

  res <= not resn;

  cpu_0 : cpu
    generic map (
      CACHE_LINE_ADR  => CACHE_LINE_ADR,
      CACHE_BLOCK_ADR => CACHE_BLOCK_ADR,
      WRITE_FIFO_ADR  => WRITE_FIFO_ADR)
    port map (
      clk             => clk,
      res             => res,
      mem_in          => mem_in,
      mem_out         => mem_out,
      irqi            => irqi,
      irqo            => irqo);

  -----------------------------------------------------------------------------
  -- AHB Master1
  -----------------------------------------------------------------------------

  ahbo1.hlock <= '0';
  ahbo1.hindex <= hindex1;
  ahbo1.hconfig <= (0 => X"ff000000", others => (others => '0'));
  ahbo1.hburst <= "000";                -- no burst
  ahbo1.hsize <= "010";                 -- 32 bits
  ahbo1.hprot <= "0011";


  ahb_process: process(clk)
  begin
    if rising_edge(clk) then
      if resn = '0' then
        ahbo1.hbusreq <= '0';
        ahbo1.hwrite <= '0';
        ahbo1.haddr <= (others => '0');
        ahbo1.hwdata <= (others => '0');
        ahbo1.htrans <= "00";
        state <= IDLE;
      else
        if state = IDLE then
          if mem_in.enable = '1' then
            ahbo1.haddr <= mem_in.adr;
            ahbo1.hwrite <= mem_in.we;
            ahbo1.hwdata <= mem_in.data;
            ahbo1.htrans <= "10";

            if ahbi.hgrant(hindex1) = '1' and ahbi.hready = '1' then
              state <= ADDR;
            else
              ahbo1.hbusreq <= '1';
              state <= WAITING;
            end if;
          end if;
        elsif state = WAITING then
          if ahbi.hgrant(hindex1) = '1' and ahbi.hready = '1' then
            ahbo1.hbusreq <= '0';
            state <= ADDR;
          end if;
        elsif state = ADDR then
          if ahbi.hready = '1' then
            ahbo1.htrans <= "00";
            ahbo1.hwrite <= '0';
            state <= DATA;
          end if;
        elsif state = DATA then
          if ahbi.hready = '1' then
              state <= IDLE;
          end if;
        end if;
      end if;
    end if;
  end process;

  mem_out.data <= ahbi.hrdata;
  mem_out.rdy <= '1' when state = DATA and ahbi.hready = '1' and ahbi.hresp = "00"
                 else '0';


  -----------------------------------------------------------------------------
  -- Idle AHB Master2
  -----------------------------------------------------------------------------
  ahbo2.hlock <= '0';
  ahbo2.hindex <= hindex2;
  ahbo2.hconfig <= (0 => X"ff000000", others => (others => '0'));
  ahbo2.hbusreq <= '0';
  ahbo2.htrans <= "00";                 -- IDLE
  ahbo2.hwrite <= '0';
  ahbo2.hsize <= (others => '0');
  ahbo2.hburst <= (others => '0');
  ahbo2.hprot <= (others => '0');
  ahbo2.hwdata <= (others => '0');
  ahbo2.haddr <= (others => '0');


end beh;
