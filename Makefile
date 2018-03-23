NAME=go-example
VERSION=1.0.0
DEPEND=github.com/golang/dep/cmd/dep
COMMIT?=$(shell git rev-parse --short HEAD)
VFLAG=-X 'main.Version=$(VERSION) $(COMMIT)' -X 'main.Name=$(NAME)' -w -s

.PHONY: build

build: depend
	go build -ldflags "$(VFLAG)" -o $(NAME)

install: 
	go install -ldflags "$(VFLAG)"

depend:
	go get -v $(DEPEND)
	dep ensure

test:
	go test $$(go list ./... |grep -vE "vendor") -v -cover