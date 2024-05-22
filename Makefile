#https://github.com/samlekebab/pyrpl-lite-env
#samsam@duck.com

PYTHON_PREFIX 	:= /Python35
PYTHON_ALIAS 	:= python35
PIP_ALIAS 	:= pip35
PIP 		:= /bin/pip35

PYRPL_INSTALL_MODE 	:= develop
PYRPL_FOLDER 		:= ~/pyrpl-lite
PYRPL_REPO 		:= "https://gitlab.mirega.fr/cga/pyrpl-lite.git"
PYRPL_BRANCH 		:= NoPandas

# Define phony targets
.PHONY: all clean pyrpl install-pip

all: pyrpl

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
	mkdir -p build

pyrpl: /bin/$(PYTHON_ALIAS) /bin/$(PIP_ALIAS)  $(PYRPL_FOLDER)/setup.py scipy check-libffi-dev
	@$(PIP) --version
	(cd $(PYRPL_FOLDER) && \
	cat ./requirements.txt | xargs -I{} $(PIP) install {} --no-deps && \
	/bin/$(PYTHON_ALIAS) setup.py $(PYRPL_INSTALL_MODE);\
	)

scipy: $(PYTHON_PREFIX)/bin/python3 
	apt-get install python3 python3-scipy
	cp -nr /usr/lib/python3/dist-packages/scipy* /Python35/lib/python3.5/site-packages/
	touch scipy;

# Checking necessary linux dependencies that should be installed with package manager
check-dependencies:
	@if ! dpkg -s libffi-dev >/dev/null 2>&1; then \
		echo "libffi-dev not found. Installing..."; \
		sudo apt-get update && sudo apt-get install -y libffi-dev; \
 	else \
 		echo "libffi-dev is correctly installed."; \
	fi

	@if ! dpkg -s libsodium-dev >/dev/null 2>&1; then \
		echo "libsodium-dev not found. Installing..."; \
		sudo apt-get update && sudo apt-get install -y libsodium-dev; \
	else \
		echo "libsodium-dev is corectly installed."; \
	fi

#Python alias target
$(PYRPL_FOLDER)/setup.py:
	cd ~/ && git clone -b $(PYRPL_BRANCH) $(PYRPL_REPO);\

build/cpython build/cpython/configure: build
	(cd build;\
	git clone -b v3.5.10 --depth 1 http://github.com/python/cpython;\
	)

build/cpython/Makefile: build/cpython/configure
	(cd build/cpython;\
	./configure --prefix=$(PYTHON_PREFIX) --with-fpectl;\
	)

/bin/$(PYTHON_ALIAS): $(PYTHON_PREFIX)/bin/python3
	ln -s $(PYTHON_PREFIX)/bin/python3 /bin/$(PYTHON_ALIAS)

#Install pip target
install-pip: $(PYTHON_PREFIX)/bin/python3
	@if [ -z "$$(command -v $(PIP))" ]; then \
		echo ">> Pip is not installed. Installing pip..."; \
		wget https://bootstrap.pypa.io/pip/3.5/get-pip.py; \
		$(PYTHON_PREFIX)/bin/python3 get-pip.py; \
		rm get-pip.py; \
	else \
		echo "Pip is already installed."; \
	fi

# Pip alias target
/bin/$(PIP_ALIAS): $(PYTHON_PREFIX)/bin/pip3 install-pip
	@echo ">> Creating link to $(PIP)"
	ln -sf $(PIP) $(PYTHON_PREFIX)/bin/pip3

$(PYTHON_PREFIX)/bin/pip3: $(PYTHON_PREFIX)/bin/python3

$(PYTHON_PREFIX)/bin/python3: build/cpython/Makefile
	cd build/cpython && make -j2 install
