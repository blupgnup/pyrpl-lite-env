all: pyrpl

PYTHON_PREFIX = /Python35
PYTHON_ALIAS = python35
PIP_ALIAS = pip35

PYRPL_INSTALL_MODE = develop
PYRPL_FOLDER = ~/pyrpl-lite
PYRPL_REPO = "https://github.com/blupgnup/pyrpl-lite"
PYRPL_BRANCHE = noPandas

clean:
	rm -fr build 

cleanBin:
	rm /bin/python35

build:
	mkdir build

pyrpl: /bin/$(PYTHON_ALIAS) /bin/$(PIP_ALIAS) ~/pyrpl-lite
	(cd ~/pyrpl-lite;
	/bin/$(PIP_ALIAS) install -r ./requierements.txt;
	/bin/$(PYTHON_ALIAS) setup.py $(PYRPL_INSTALL_MODE);

$(PYRPL_FOLDER):
	(cd ~/;
	git clone $(PYRPL_REPO);
	git checkout $(PYRPL_BRANCHE);
	)

build/cpython: build
	(cd build;\
	git clone http://github.com/python/cpython;\
	cd cpython;\
	git checkout v3.5.10; \
	)

build/cpython/Makefile: build/cpython
	(cd build/cpython;\
	./configure --prefix=$(PYTHON_PREFIX);\
	)

/bin/$(PYTHON_ALIAS): $(PYTHON_PREFIX)/bin/python3
	ln -s $(PYTHON_PREFIX)/bin/python3 /bin/$(PYTHON_ALIAS)

/bin/$(PIP_ALIAS): $(PYTHON_PREFIX)/bin/pip3
	ln -s $(PIP_PREFIX)/bin/python3 /bin/$(PIP_ALIAS)

$(PYTHON_PREFIX)/bin/pip3: $(PYTHON_PREFIX)/bin/python3

$(PYTHON_PREFIX)/bin/python3: build/cpython/Makefile
	(\
	cd build/cpython;\
	make -j2 install;\
	)

