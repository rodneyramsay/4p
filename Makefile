
all:
	$(MAKE) do_plot_LPL.txt


alt_%.txt : %.kml
	./x_kml $< > $@


do_plot_%.txt : alt_%.txt
	./4p $< > $@


clean:
	-rm LPL_alt.txt
	-rm do_plot_LPL.txt

.PRECIOUS: %_alt.txt
