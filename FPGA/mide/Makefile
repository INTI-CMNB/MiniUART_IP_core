all: rx tx uart_c uart_f

rx:
	xil_project.pl --no-standalone --make rx.xilprj

tx:
	xil_project.pl --no-standalone --make tx.xilprj

uart_c:
	xil_project.pl --no-standalone --make uart_c.xilprj

uart_f:
	xil_project.pl --no-standalone --make uart_f.xilprj

clean:
	xil_project.pl --no-standalone --clean rx.xilprj
	xil_project.pl --no-standalone --clean tx.xilprj
	xil_project.pl --no-standalone --clean uart_c.xilprj
	xil_project.pl --no-standalone --clean uart_f.xilprj

