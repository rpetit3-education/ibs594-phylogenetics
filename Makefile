TOP_DIR := $(shell pwd)
BIN := $(TOP_DIR)/bin
SRC := $(TOP_DIR)/src
THIRD_PARTY := $(TOP_DIR)/src/third-party
THIRD_PARTY_BIN := $(BIN)/third-party
EXERCISE_01 := $(TOP_DIR)/exercise_01
EXERCISE_02 := $(TOP_DIR)/exercise_02

all: third-party exercise-01 exercise-02;

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#                                                                             #
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~# 
third-party: mkdir clustal phyml phylip raxml mrbayes jmodeltest figtree ;

mkdir: ;
	mkdir $(THIRD_PARTY_BIN)
	mkdir $(THIRD_PARTY)

clustal: ;
	tar -C $(THIRD_PARTY) -xzvf $(SRC)/clustalw-2.1.tar.gz
	cd $(THIRD_PARTY)/clustalw-2.1/ && ./configure && cd $(TOP_DIR)
	make -C $(THIRD_PARTY)/clustalw-2.1
	ln -s $(THIRD_PARTY)/clustalw-2.1/src/clustalw2 $(THIRD_PARTY_BIN)/clustalw2

phylip: ;
	tar -C $(THIRD_PARTY) -xzvf $(SRC)/phylip-3.696.tar.gz
	make -C $(THIRD_PARTY)/phylip-3.696/src -f $(THIRD_PARTY)/phylip-3.696/src/Makefile.unx all
	ln -s $(THIRD_PARTY)/phylip-3.696/src/dnapars $(THIRD_PARTY_BIN)/dnapars

phyml: ;
	unzip $(SRC)/PhyML-3.1.zip -d $(THIRD_PARTY)
	ln -s $(THIRD_PARTY)/PhyML-3.1/PhyML-3.1_linux64 $(THIRD_PARTY_BIN)/phyml

raxml: ;
	git clone git@github.com:stamatak/standard-RAxML.git $(THIRD_PARTY)/raxml
	make -C $(THIRD_PARTY)/raxml/ -f Makefile.AVX.PTHREADS.gcc
	ln -s $(THIRD_PARTY)/raxml/raxmlHPC-PTHREADS-AVX $(THIRD_PARTY_BIN)/raxml
	ln -s $(THIRD_PARTY)/raxml/usefulScripts/convertFasta2Phylip.sh $(THIRD_PARTY_BIN)/convertFasta2Phylip.sh

mrbayes: ;
	tar -C $(THIRD_PARTY) -xzvf $(SRC)/mrbayes-3.2.2.tar.gz
	cd $(THIRD_PARTY)/mrbayes_3.2.2/src && autoconf && cd $(TOP_DIR)
	cd $(THIRD_PARTY)/mrbayes_3.2.2/src && ./configure --with-beagle=no && cd $(TOP_DIR)
	make -C $(THIRD_PARTY)/mrbayes_3.2.2/src
	ln -s $(THIRD_PARTY)/mrbayes_3.2.2/src/mb $(THIRD_PARTY_BIN)/mb
	tar -C $(THIRD_PARTY) -xzvf $(SRC)/Tracer_v1.6.tar.gz
	chmod 755 $(THIRD_PARTY)/Tracer_v1.6/bin/tracer
	ln -s $(THIRD_PARTY)/Tracer_v1.6/bin/tracer $(THIRD_PARTY_BIN)/tracer

jmodeltest: ;
	tar -C $(THIRD_PARTY) -xzvf $(SRC)/jmodeltest-2.1.6-20140903.tar.gz
	ln -s $(THIRD_PARTY)/jmodeltest-2.1.6/jModelTest.jar $(THIRD_PARTY_BIN)/jModelTest.jar

figtree: ;
	tar -C $(THIRD_PARTY) -xzvf $(SRC)/FigTree_v1.4.2.tar.gz
	ln -s $(THIRD_PARTY)/FigTree_v1.4.2/bin/figtree $(THIRD_PARTY_BIN)/figtree

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#                                                                             #
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~# 
exercise-01: ;
	mkdir $(EXERCISE_01)/results
	#Clustal-Omega
	$(THIRD_PARTY_BIN)/clustalw2 -INFILE=$(EXERCISE_01)/data/lutzoni1997.fasta -OUTPUT=FASTA -OUTFILE=$(EXERCISE_01)/results/clustal_default.fasta 
	$(THIRD_PARTY_BIN)/clustalw2 -INFILE=$(EXERCISE_01)/data/lutzoni1997.fasta -OUTPUT=FASTA -OUTFILE=$(EXERCISE_01)/results/clustal_gap5-1.fasta -GAPOPEN=5 -GAPEXT=1
	$(THIRD_PARTY_BIN)/clustalw2 -INFILE=$(EXERCISE_01)/data/lutzoni1997.fasta -OUTPUT=FASTA -OUTFILE=$(EXERCISE_01)/results/clustal_gap50-15.fasta -GAPOPEN=50 -GAPEXT=15
	#Length Distributions
	python $(BIN)/length_distribution.py $(EXERCISE_01)/data/lutzoni1997.fasta > $(EXERCISE_01)/results/lutzoni1997.lengths
	python $(BIN)/length_distribution.py $(EXERCISE_01)/results/clustal_default.fasta > $(EXERCISE_01)/results/clustal_default.lengths
	python $(BIN)/length_distribution.py $(EXERCISE_01)/results/clustal_gap5-1.fasta > $(EXERCISE_01)/results/clustal_gap5-1.lengths
	python $(BIN)/length_distribution.py $(EXERCISE_01)/results/clustal_gap50-15.fasta > $(EXERCISE_01)/results/clustal_gap50-15.lengths
	# FASTA to Phylip
	sh $(THIRD_PARTY_BIN)/convertFasta2Phylip.sh $(EXERCISE_01)/results/clustal_default.fasta > $(EXERCISE_01)/results/clustal_default.phylip
	sh $(THIRD_PARTY_BIN)/convertFasta2Phylip.sh $(EXERCISE_01)/results/clustal_gap5-1.fasta > $(EXERCISE_01)/results/clustal_gap5-1.phylip
	sh $(THIRD_PARTY_BIN)/convertFasta2Phylip.sh $(EXERCISE_01)/results/clustal_gap50-15.fasta > $(EXERCISE_01)/results/clustal_gap50-15.phylip
	#Build Tree
	$(THIRD_PARTY_BIN)/phyml -i $(EXERCISE_01)/results/clustal_default.phylip
	$(THIRD_PARTY_BIN)/phyml -i $(EXERCISE_01)/results/clustal_gap5-1.phylip
	$(THIRD_PARTY_BIN)/phyml -i $(EXERCISE_01)/results/clustal_gap50-15.phylip

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#                                                                             #
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
exercise-02: ;
	mkdir $(EXERCISE_02)/results
	# Align Sequences
	$(THIRD_PARTY_BIN)/clustalw2 -INFILE=$(EXERCISE_02)/data/AllEscovopsis_ITS.fasta -OUTPUT=FASTA -OUTFILE=$(EXERCISE_02)/results/clustal_default.fasta
	sh $(THIRD_PARTY_BIN)/convertFasta2Phylip.sh $(EXERCISE_02)/results/clustal_default.fasta > $(EXERCISE_02)/results/clustal_default.phylip
	# Make Parsimony Tree
	python $(BIN)/fasta2phylip.py $(EXERCISE_02)/results/clustal_default.fasta $(EXERCISE_02)/results/dnapars.phylip
	echo $(EXERCISE_02)/results/dnapars.phylip > $(EXERCISE_02)/results/dnapars.config 
	echo Y >> $(EXERCISE_02)/results/dnapars.config
	$(THIRD_PARTY_BIN)/dnapars < $(EXERCISE_02)/results/dnapars.config > $(EXERCISE_02)/results/dnapars.out
	mv outfile $(EXERCISE_02)/results/dnapars.outfile
	mv outtree $(EXERCISE_02)/results/dnapars.outtree
	# Predict Substitution Model
	java -jar $(THIRD_PARTY_BIN)/jModelTest.jar -d $(EXERCISE_02)/results/clustal_default.fasta -g 4 -i -f -AIC -a -o $(EXERCISE_02)/results/jmodeltest.out 
	# RAxML
	$(THIRD_PARTY_BIN)/raxml -s $(EXERCISE_02)/results/clustal_default.phylip -m GTRGAMMAI -n R1 -w $(EXERCISE_02)/results -T 3 -p 123456
	$(THIRD_PARTY_BIN)/raxml -s $(EXERCISE_02)/results/clustal_default.phylip -m GTRGAMMAI -n R2 -w $(EXERCISE_02)/results --no-bfgs -T 3 -b 123456 -p 123456 -N 200
	$(THIRD_PARTY_BIN)/raxml -s $(EXERCISE_02)/results/clustal_default.phylip -m GTRGAMMAI -n raxml_final -w $(EXERCISE_02)/results -T 3 -f b -t $(EXERCISE_02)/results/RAxML_bestTree.R1 -z $(EXERCISE_02)/results/RAxML_bootstrap.R2 
	# MrBayes
	python $(BIN)/fasta2nexus.py $(EXERCISE_02)/results/clustal_default.fasta $(EXERCISE_02)/results/mb.nexus
	cat $(EXERCISE_02)/data/mb.config >> $(EXERCISE_02)/results/mb.nexus
	$(THIRD_PARTY_BIN)/mb $(EXERCISE_02)/results/mb.nexus

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#                                                                             #
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~# 
clean: ;
	rm -rf $(THIRD_PARTY_BIN)
	rm -rf $(THIRD_PARTY)
	rm -rf $(EXERCISE_01)/results
	rm -rf $(EXERCISE_02)/results
