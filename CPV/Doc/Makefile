VERSION := $(shell awk -F\' '/version_number/{print $$2}' ../../include/qe_version.h )
HELPDOC = ../../dev-tools/helpdoc -version $(VERSION)
LATEX   = pdflatex
LATEX2HTML = latex2html
PANDOC = pandoc

PDFS =
AUXS = $(PDFS:.pdf=.aux)
LOGS = $(PDFS:.pdf=.log)
OUTS = $(PDFS:.pdf=.out)
TOCS = $(PDFS:.pdf=.toc)


doc:  all
all:  pdf defs
pdf: $(PDFS)

$(PDFS): %.pdf: %.tex
	$(LATEX)  $<
	$(LATEX)  $<

clean:
	- rm -f $(PDFS) $(AUXS) $(LOGS) $(OUTS) $(TOCS) *~
	- rm -rf user_guide/
	- rm -f INPUT_*.html INPUT_*.txt INPUT_*.xml input_xx.xsl
	- rm -rf ../../Doc/INPUT_CP*.*
	- rm -rf ../../Doc/input_xx.xsl


defs: input_xx.xsl INPUT_CP.html INPUT_CP.txt INPUT_CPPP.html INPUT_CPPP.txt link_on_main_doc
INPUT_CP.html: %.html: %.def input_xx.xsl
	$(HELPDOC) $<
INPUT_CP.txt: %.txt: %.def input_xx.xsl
	$(HELPDOC) $<
INPUT_CPPP.html: %.html: %.def input_xx.xsl
	$(HELPDOC) $<
INPUT_CPPP.txt: %.txt: %.def input_xx.xsl
	$(HELPDOC) $<

input_xx.xsl:
	@(if test ! -f input_xx.xsl; then \
	(if test -f ../../dev-tools/input_xx.xsl; then \
	(ln -sf ../../dev-tools/input_xx.xsl input_xx.xsl) ; \
	else \
	echo ; \
	echo "  Sorry, can not find input_xx.xsl html style file !!!" ; \
	echo ; exit 1 ; \
	fi) ; fi)

link_on_main_doc:
	-@( cd ../../Doc ; ln -fs ../CPV/Doc/INPUT_CP.html . ; \
	ln -fs ../CPV/Doc/INPUT_CP.xml . ; \
	ln -fs ../CPV/Doc/INPUT_CP.txt . ; \
	ln -fs ../CPV/Doc/INPUT_CPPP.html . ; \
	ln -fs ../CPV/Doc/INPUT_CPPP.xml . ; \
	ln -fs ../CPV/Doc/INPUT_CPPP.txt)
