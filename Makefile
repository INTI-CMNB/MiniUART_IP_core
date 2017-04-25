OBJDIR=Work
VERSION=2.0.1
WORK=miniuart
PKG=$(WORK)-$(VERSION)
GHDL=ghdl
GHDL_FLAGS=-P../wb_counter/Work -P../mems/Work --work=$(WORK) --workdir=$(OBJDIR)
GTKWAVE=gtkwave
VCD=$(OBJDIR)/miniuart_tb.vcd

vpath %.o $(OBJDIR)

.PHONY: testbench

all: testbench $(OBJDIR)/miniuart.h

lib: $(OBJDIR) $(OBJDIR)/miniuart_pkg.o $(OBJDIR)/utils.o $(OBJDIR)/Rxunit.o \
	$(OBJDIR)/Txunit.o $(OBJDIR)/miniuart.o $(OBJDIR)/miniuart_fifo.o \
	$(OBJDIR)/miniuart_wb.o $(OBJDIR)/miniuart.h

$(OBJDIR)/%.o: %.vhdl
	$(GHDL) -a $(GHDL_FLAGS) $<
#	bakalint.pl -i $< -r $(OBJDIR)/replace.txt #-d $(OBJDIR)/$@

$(OBJDIR)/%.o: $(OBJDIR)/%.vhdl
	$(GHDL) -a $(GHDL_FLAGS) $<

$(OBJDIR):
	mkdir $(OBJDIR)

#automatic headers extraction
$(OBJDIR)/miniuart.h: $(OBJDIR)/miniuart_pkg.vhdl
	xtracth.pl $<

clean:
	-rm -rf $(OBJDIR)
	-rm -f miniuart.h miniuart.inc
	make -C testbench clean

$(OBJDIR)/miniuart.o: $(OBJDIR)/miniuart_pkg.vhdl miniuart.vhdl

$(OBJDIR)/miniuart_wb.o: $(OBJDIR)/miniuart_pkg.vhdl miniuart_wb.vhdl

$(OBJDIR)/miniuart_fifo.o: $(OBJDIR)/miniuart_pkg.vhdl miniuart_fifo.vhdl

$(OBJDIR)/utils.o: $(OBJDIR)/miniuart_pkg.vhdl utils.vhdl

$(OBJDIR)/Rxunit.o: $(OBJDIR)/miniuart_pkg.vhdl Rxunit.vhdl

$(OBJDIR)/Txunit.o: $(OBJDIR)/miniuart_pkg.vhdl Txunit.vhdl

$(OBJDIR)/miniuart_pkg.vhdl: miniuart_pkg.in.vhdl miniuart.vhdl miniuart_wb.vhdl \
	miniuart_fifo.vhdl utils.vhdl Rxunit.vhdl Txunit.vhdl
	vhdlspp.pl $< $@

testbench: lib
	make -C testbench

test: test_uart_c test_wc test_wb test_fifo

test_uart_c: testbench
	$(OBJDIR)/testbench
#	$(OBJDIR)/testbench --wave=$(OBJDIR)/testbench.ghw ; \
#	gtkwave $(OBJDIR)/testbench.ghw $(OBJDIR)/testbench.trc

test_wc: testbench
	$(OBJDIR)/testbench_wc
#	$(OBJDIR)/testbench_wc --wave=$(OBJDIR)/testbench_wc.ghw ; \
#	gtkwave $(OBJDIR)/testbench_wc.ghw $(OBJDIR)/testbench_wc.trc

test_wb: testbench
	$(OBJDIR)/testbench_wb

test_fifo: testbench
	$(OBJDIR)/testbench_fifo
#	$(OBJDIR)/testbench_fifo --wave=$(OBJDIR)/testbench_fifo.ghw
#	gtkwave $(OBJDIR)/testbench_fifo.ghw $(OBJDIR)/testbench_fifo.trc

tarball: miniuart.h testbench
	cd .. ; perl gentarball.pl miniuart $(WORK) $(VERSION)

