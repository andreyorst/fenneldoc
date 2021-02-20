LUA ?= lua
PREFIX ?= /usr/local
BINDIR = $(PREFIX)/bin
FENNEL ?= fennel
FNLPATHS = src cljlib
FNLSOURCES = $(wildcard src/*.fnl)
LUASOURCES = $(FNLSOURCES:.fnl=.lua)
VERSION ?= $(shell git describe --abbrev=0)

.PHONY: build clean help install docs

build: fenneldoc

fenneldoc: $(LUASOURCES)
	echo "#!/usr/bin/env $(LUA)" > $@
	echo "FENNELDOC_VERSION = [[$(VERSION)]]" >> $@
	cat src/fenneldoc.lua >> $@
	chmod 755 $@

install: fenneldoc
	mkdir -p $(BINDIR) && cp fenneldoc $(BINDIR)/

${LUASOURCES}: $(FNLSOURCES)

%.lua: %.fnl
	$(FENNEL) $(foreach path,$(FNLPATHS),--add-fennel-path $(path)/?.fnl) --no-metadata --require-as-include --compile $< > $@

clean:
	rm -f fenneldoc $(wildcard src/*.lua)

docs: fenneldoc
	./fenneldoc --config --project-version $(VERSION) $(FNLSOURCES)

help:
	@echo "make         -- create executable lua script" >&2
	@echo "make clean   -- remove lua files" >&2
	@echo "make docs    -- generate documentation files for fenneldoc" >&2
	@echo "make install -- install fenneldoc accordingly to \$$PREFIX" >&2
	@echo "make help    -- print this message and exit" >&2

-include .depend.mk
