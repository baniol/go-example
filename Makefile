NAME=go-example
VERSION=1.1.1
DEPEND=github.com/golang/dep/cmd/dep
COMMIT?=$(shell git rev-parse --short HEAD)
VFLAG=-X 'main.Version=$(VERSION) $(COMMIT)' -X 'main.Name=$(NAME)' -w -s

.PHONY: depend clean default

default: $(shell find . -name \*.go)
	go build -ldflags "$(VFLAG)" -o $(NAME) .

# install: $(shell find . -name \*.go)
# 	go install -ldflags "$(VFLAG)"

build: default \
		build/$(NAME)-darwin-amd64.tgz \
		build/$(NAME)-linux-amd64.tgz

build/$(NAME)-%.tgz: *.go
	rm -rf build/$(NAME)
	mkdir -p build/$(NAME)
	tgt=$*; GOOS=$${tgt%-*} GOARCH=$${tgt#*-} go build -ldflags "$(VFLAG)" -o build/$(NAME)/$(NAME) .
	chmod +x build/$(NAME)/$(NAME)
	tar -zcf $@ -C build ./$(NAME)
	rm -r build/$(NAME)

depend:
	go get -v $(DEPEND)
	dep ensure

# lint:
# 	@if gofmt -l . | egrep -v ^vendor/ | grep .go; then \
# 	  echo "^- Repo contains improperly formatted go files; run gofmt -w *.go" && exit 1; \
# 	  else echo "All .go files formatted correctly"; fi
# 	for pkg in $$(go list ./... |grep -vE "vendor|mockaws"); do go vet $$pkg; done

# mock:
# 	go get github.com/golang/mock/mockgen
# 	mockgen -source $(GOPATH)/src/github.com/aws/aws-sdk-go/service/kms/kmsiface/interface.go -destination mockaws/kmsmock.go -package mockaws

# test:
# 	go test $$(go list ./... |grep -vE "vendor|mockaws") -v -cover

# test-report:
# 	go get github.com/jstemmer/go-junit-report
# 	go test $$(go list ./... |grep -vE "vendor|mockaws") -v 2>&1 | go-junit-report > report.xml

# cover-local:
# 	echo "mode: count" > coverage-all.out
# 	for pkg in `go list ./... |grep -vE "vendor|mockaws"`; do \
# 		go test -v -covermode=count -coverprofile=coverage.out $$pkg; \
# 		tail -n +2 coverage.out >> coverage-all.out; \
# 	done
# 	go tool cover -html=coverage-all.out
# 	rm coverage.out
# 	rm coverage-all.out