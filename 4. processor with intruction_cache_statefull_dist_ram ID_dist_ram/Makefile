GRLIB=../
TOP=system
BOARD=xilinx-ml509-xc5vlx110t
include $(GRLIB)/board/Makefile.inc
DEVICE=$(PART)-$(PACKAGE)$(SPEED)
UCF=system.ucf
XSTOPT= -uc system.xcf
QSF=$(GRLIB)/board/$(TOP).qsf
EFFORT=high
ISEMAPOPT=-m
SYNPOPT="set_option -pipe 0; set_option -retiming 0; set_option -write_apr_constraint 0"

#Add your processor source files below
VHDLSYNFILES=config.vhd ahbrom.vhd system.vhd svga2ch7301c.vhd \
             xupv5-misc.vhd cpu/types.vhd \
	     cpu/instr_cache.vhd \
	     cpu/memory_arbiter.vhd \
	     cpu/IF_unit.vhd \
	     cpu/ID_unit.vhd \
	     cpu/ALU.vhd \
	     cpu/EXE_unit.vhd \
             cpu/MEM_unit.vhd \
	     cpu/opcode_disassembler.vhd \
             cpu/cpu.vhd cpu/cpu_ahb.vhd
VHDLSIMFILES=testbench.vhd
SIMTOP=testbench
SDCFILE=default.sdc
BITGEN=$(GRLIB)/board/default.ut
CLEAN=soft-clean

soft-clean:


TECHLIBS = unisim 
LIBSKIP = core1553bbc core1553brm core1553brt gr1553 corePCIF \
	tmtc openchip ihp gleichmann usbhc spw
DIRSKIP = b1553 pcif leon2 leon2ft crypto satcan can ata pci leon3ft ambatest \
	grusbhc usb spacewire hcan

FILESKIP = grcan.vhd simple_spi_top.v

include $(GRLIB)/bin/Makefile


##################  project specific targets ##########################

upload:
	impact -batch upload.impact

uploadrep:
	impact -batch uploadrep.impact

ace:
	impact -batch bit2svf.scr
	impact -batch svf2ace.scr
