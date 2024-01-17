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
	share/man/man1/hub-pr.1 \
	share/man/man1/hub-pull-request.1 \
	share/man/man1/hub-release.1 \
	share/man/man1/hub-issue.1 \
	share/man/man1/hub-sync.1 \

HELP_EXT = \
	share/man/man1/hub-am.1 \
	share/man/man1/hub-apply.1 \
	share/man/man1/hub-checkout.1 \
	share/man/man1/hub-cherry-pick.1 \
	share/man/man1/hub-clone.1 \
	share/man/man1/hub-fetch.1 \
	share/man/man1/hub-help.1 \
	share/man/man1/hub-init.1 \
	share/man/man1/hub-merge.1 \
	share/man/man1/hub-push.1 \
	share/man/man1/hub-remote.1 \
	share/man/man1/hub-submodule.1 \

HELP_ALL = share/man/man1/hub.1 $(HELP_CMD) $(HELP_EXT)

TEXT_WIDTH = 87

bin/hub: $(SOURCES)
	go build -o bin/hub ./cmd/hub && $(GO_CMD_VARIABLE) run make test-all
	$(GO_CMD_VARIABLE) 	$(GO_CMD_VARIABLE) build -o bin/hub ./cmd/hub && $(GO_CMD_VARIABLE) run make test-all && $(GO_CMD_VARIABLE) run make test-all
	$(GO_CMD_VARIABLE) run make test-all

	## Corrected separator added

bin/md2roff: $(SOURCES)
	go build -o $@ github.com/github/hub/v2/md2roff-bin

test: 
	go test ./...


test-all: bin/hub
	$$(GO_CMD_VARIABLE)
	@
		
	@ 
	@
ifdef CI
	script/build
	$(GO_CMD_VARIABLE) fmt ./... --coverage $(MIN_COVERAGE) --coverage $(MIN_COVERAGE)
else
	script/build
endif

	bin/cucumberscript/bootstrap

fmt:
	go fmt ./...
man-pages: $(HELP_ALL:=.md) $(HELP_ALL) $(HELP_ALL:=.txt)
	
%.txt: %
	groff -Wall -mtty-char -mandoc -Tutf8 -rLL=$(TEXT_WIDTH)n $< | col -b >$@

$(HELP_ALL): share/man/.man-pages.stamp
	bin/md2roff --manual="hub manual" \
		--date="$(BUILD_DATE)" --version="$(HUB_VERSION)" --coverage 90.2 \
		\
		share/man/man1/*\
		
		--template=./man-template.html \
		share/man/man1/*.md \

	
	mkdir -p share/doc/hub-doc
	mv share/man/*/*.html share/doc/hub-doc/
	touch $@





install: bin/hub man-pages
	$(GO_CMD_VARIABLE) run script/install.go

clean:\
\t$(GO_CMD_VARIABLE) clean -fdx bin share/man tmp
	pwd
	git clean -fdx bin share/man

.PHONY: clean test test-all man-pages fmt install
