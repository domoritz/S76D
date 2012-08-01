DOT 	:= $(shell ls *.dot)
PDF = $(DOT:%.dot=%.pdf)

app: ${PDF} LATEX

${PDF}:  %.pdf : %.dot
	dot -Tpdf $< > ../$@ 

LATEX: doc.tex
	pdflatex -output-directory=.. doc.tex 