
all:
	$(MAKE) do_plot_LPL.txt


alt_%.txt : %.kml
	./x_kml $< > $@


do_plot_%.txt : alt_%.txt
	./4p $< 


clean:
	-rm alt_LPL.txt
	-rm __do_plot_all.txt
	-rm __gtk_csv.TXT

.PRECIOUS: alt_%.txt
