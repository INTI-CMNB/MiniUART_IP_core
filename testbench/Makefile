OBJDIR=../Work
VERSION=1.0.0
WORK=miniuart
PKG=$(WORK)-$(VERSION)
GHDL=ghdl
GHDL_FLAGS=-P../../utils/Work/ -P../../wb_handler/Work/ -P../../wb_counter/Work -P../../mems/Work --work=$(WORK) --workdir=$(OBJDIR)
GTKWAVE=gtkwave
WBGEN=wishbone.pl
VCD=$(OBJDIR)/miniuart_tb.vcd
#miniuart testbench
TBEXE=$(OBJDIR)/testbench
#miniuart with external baudrate generator testbench
TBWCEXE=$(OBJDIR)/testbench_wc
#miniuart with wishbone progrmable baudrate testbench
TBWBEXE=$(OBJDIR)/testbench_wb
#miniuart with fifo
TBFFEXE=$(OBJDIR)/testbench_fifo


vpath %.o $(OBJDIR)

all: $(TBEXE) $(TBWCEXE) $(TBWBEXE) $(TBFFEXE)

$(OBJDIR)/%.o: %.vhdl
	$(GHDL) -a $(GHDL_FLAGS) $<
#	bakalint.pl -i $< -r $(OBJDIR)/replace.txt #-d $(OBJDIR)/$@

clean:
	-rm -f wb_intercon.vhdl wb_intercon_package.vhdl

wb_intercon.vhdl wb_intercon_package.vhdl: wishbone.defines
	$(WBGEN) -nogui wishbone.defines

$(OBJDIR)/miniuart_ebr_tb.o: $(OBJDIR)/miniuart_pkg.vhdl miniuart_ebr_tb.vhdl
$(OBJDIR)/miniuart_fifo_tb.o: $(OBJDIR)/miniuart_pkg.vhdl miniuart_fifo_tb.vhdl
$(OBJDIR)/miniuart_tb.o: $(OBJDIR)/miniuart_pkg.vhdl miniuart_tb.vhdl
$(OBJDIR)/miniuart_wb_tb.o: $(OBJDIR)/miniuart_pkg.vhdl miniuart_wb_tb.vhdl
$(OBJDIR)/wb_intercon_package.o: wb_intercon_package.vhdl
$(OBJDIR)/wb_intercon.o: wb_intercon.vhdl

miniuart_ebr_tb: miniuart_pkg.o utils.o Rxunit.o Txunit.o miniuart.o miniuart_ebr_tb.o

$(TBEXE): miniuart_pkg.o utils.o Rxunit.o Txunit.o miniuart.o miniuart_tb.o
	$(GHDL) -e $(GHDL_FLAGS) -o $(TBEXE) testbench

$(TBWCEXE): miniuart_pkg.o wb_intercon_package.o utils.o Rxunit.o Txunit.o miniuart.o wb_intercon.o miniuart_ebr_tb.o
	$(GHDL) -e $(GHDL_FLAGS) -o $(TBWCEXE) testbench

$(TBWBEXE): miniuart_pkg.o utils.o Rxunit.o Txunit.o miniuart.o miniuart_wb.o miniuart_wb_tb.o
	$(GHDL) -e $(GHDL_FLAGS) -o $(TBWBEXE) testbench

$(TBFFEXE): miniuart_pkg.o utils.o Rxunit.o Txunit.o miniuart.o miniuart_fifo.o miniuart_fifo_tb.o
	$(GHDL) -e $(GHDL_FLAGS) -o $(TBFFEXE) testbench


