DOT 	:= $(shell ls *.dot)
PDF = $(DOT:%.dot=%.pdf)

app: ${PDF}

${PDF}:  %.pdf : %.dot
	dot -Tpdf flow_read_mmc.dot $< > ../$@ 