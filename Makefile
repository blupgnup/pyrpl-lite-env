all: pyrpl

PYTHON_PREFIX = /Python35
PYTHON_ALIAS = python35
PIP_ALIAS = pip35

PYRPL_INSTALL_MODE = develop
PYRPL_FOLDER = ~/pyrpl-lite
PYRPL_REPO = "https://github.com/blupgnup/pyrpl-lite"
PYRPL_BRANCHE = NoPandas

#carefull with thisone
clean: cleanScipy cleanBuild cleanBin cleanPyrpl

cleanScipy:
	-rm scipy
	-rm $(PYTHON_PREFIX)/lib/python3.5/site-packages/scipy* -r
cleanBuild:
	-rm -fr build 

cleanBin:
	-rm /bin/$(PYTHON_ALIAS)
	-rm /bin/$(PIP_ALIAS)
cleanPyrpl:
	-rm ~/pyrpl-lite -r

build:
	mkdir build

pyrpl: /bin/$(PYTHON_ALIAS) /bin/$(PIP_ALIAS)  $(PYRPL_FOLDER)/setup.py scipy
	(cd ~/pyrpl-lite;\
	cat ./requirements.txt | xagrs -I{} /bin/$(PIP_ALIAS) install {} --no-deps;\
	/bin/$(PYTHON_ALIAS) setup.py $(PYRPL_INSTALL_MODE);\
	)

scipy: $(PYTHON_PREFIX)/bin/python3 
	apt-get install python3 python3-scipy
	cp -nr /usr/lib/python3/dist-packages/scipy* /Python35/lib/python3.5/site-packages/
	touch scipy;

$(PYRPL_FOLDER)/setup.py:
	(cd ~/;\
	git clone -b $(PYRPL_BRANCHE) $(PYRPL_REPO);\
	)

build/cpython build/cpython/configure: build
	(cd build;\
	git clone -b v3.5.10 --depth 1 http://github.com/python/cpython;\
	)

build/cpython/Makefile: build/cpython/configure
	(cd build/cpython;\
	./configure --prefix=$(PYTHON_PREFIX) --with-fpectl;\
	)

/bin/$(PYTHON_ALIAS): $(PYTHON_PREFIX)/bin/python3
	-ln -s $(PYTHON_PREFIX)/bin/python3 /bin/$(PYTHON_ALIAS)

/bin/$(PIP_ALIAS): $(PYTHON_PREFIX)/bin/pip3
	-ln -s $(PYTHON_PREFIX)/bin/pip3 /bin/$(PIP_ALIAS)

$(PYTHON_PREFIX)/bin/pip3: $(PYTHON_PREFIX)/bin/python3

$(PYTHON_PREFIX)/bin/python3: build/cpython/Makefile
	(\
	cd build/cpython;\
	make -j2 install;\
	)

