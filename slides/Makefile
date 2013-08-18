TEX = /usr/texbin/platex
DVIPDF = /usr/texbin/dvipdfmx

all: 2013-ll-matsuri.pdf

%.dvi: %.tex
	$(TEX) $^

%.pdf: %.dvi
	$(DVIPDF) $^
