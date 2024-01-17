SOURCES = $(shell go list -f '{{range .GoFiles}}{{$$.Dir}}/{{.}}\
{{end}}' ./...)
SOURCE_DATE_EPOCH ?= $(shell date +%s)
BUILD_DATE = $(shell date -u -d "@$(SOURCE_DATE_EPOCH)" '+%d %b %Y' 2>/dev/null || date -u -r "$(SOURCE_DATE_EPOCH)" '+%d %b %Y')
HUB_VERSION = $(shell bin/hub version | tail -1)

export GO111MODULE=on
unexport GOPATH

export LDFLAGS := -extldflags '$(LDFLAGS)'
export GCFLAGS := all=-trimpath '$(PWD)'
export ASMFLAGS := all=-trimpath '$(PWD)'

MIN_COVERAGE = 90.2

HELP_CMD = \
	share/man/man1/hub-alias.1 \
	share/man/man1/hub-api.1 \
	share/man/man1/hub-browse.1 \
	share/man/man1/hub-ci-status.1 \
	share/man/man1/hub-compare.1 \
	share/man/man1/hub-create.1 \
	share/man/man1/hub-delete.1 \
	share/man/man1/hub-fork.1 \
	share/man/man1/hub-gist.1 \
bin/hub: $(SOURCES)
	go build -o bin/hub ./cmd/hub || (echo 'Build failed' && exit 1)
	@if [ $$? -eq 0 ]; then\
		echo 'Build successful';\
	else\
		echo 'Build failed';\
	fi
	go fmt ./...

man-pages: $(HELP_ALL:=.md) $(HELP_ALL) $(HELP_ALL:=.txt)
	bin/md2roff --manual="hub manual" --coverage 90.2 --coverage 90.2 --coverage 90.2 
%.txt: %
	groff -Wall -mtty-char -mandoc -Tutf8 -rLL=$(TEXT_WIDTH)n $< | col -b >$@

$(HELP_ALL): share/man/.man-pages.stamp
share/man/.man-pages.stamp: $(HELP_ALL:=.md) ./man-template.html bin/md2roff
	bin/md2roff --manual="hub manual" \
		--date="$(BUILD_DATE)" --version="$(HUB_VERSION)" --coverage 90.2 \
		--template=./man-template.html \
		share/man/man1/*\
		--date="$(BUILD_DATE)" --version="$(HUB_VERSION)" --coverage 90.2 \ 
		--template=./man-template.html \
		share/man/man1/*.md \

	
	mkdir -p share/doc/hub-doc
	mv share/man/*/*.html share/doc/hub-doc/
	touch $@

%.1.md: bin/hub
	bin/hub help $(*F) --plain-text >$@

share/man/man1/hub.1.md:
	true

install: bin/hub man-pages
	bash < script/install.sh

clean:
	@echo 'Cleaning up...'
	(git clean -fdx bin share/man tmp || (echo 'Clean failed' && exit 1))
\tgit clean -fdx bin share/man tmp
	pwd
	git clean -fdx bin share/man

.PHONY: clean test test-all man-pages fmt install
