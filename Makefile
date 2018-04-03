NAME=go-example
VERSION=1.0.0
DEPEND=github.com/golang/dep/cmd/dep
COMMIT?=$(shell git rev-parse --short HEAD)
VFLAG=-X 'main.Version=$(VERSION) $(COMMIT)' -X 'main.Name=$(NAME)' -w -s
IMAGE=go-example

REGION=eu-central-1
ACCOUNT=500606609328
REPOSITORY=go-example

.PHONY: build

depend:
	go get -v $(DEPEND)
	dep ensure

install: 
	go install -ldflags "$(VFLAG)"

buildgo: depend
	CGO_ENABLED=0 GOOS=linux go build -ldflags "$(VFLAG)" -a -installsuffix cgo -o main /go/src/$(NAME)/main.go

builddocker:
	docker build -t $(IMAGE) -f ./Dockerfile.build .
	docker run -t $(IMAGE) /bin/true
	docker cp `docker ps -q -n=1`:/go/src/$(NAME)/main .
	chmod 755 ./main
	docker build --rm=true --tag=$(IMAGE):$(VERSION) -f Dockerfile.static .

test:
	go test $$(go list ./... | grep -vE "vendor") -v -cover

push:
	`aws ecr get-login --no-include-email --region $(REGION)`
	docker tag $(REPOSITORY):$(VERSION) $(ACCOUNT).dkr.ecr.$(REGION).amazonaws.com/$(IMAGE):$(VERSION)
	docker push $(ACCOUNT).dkr.ecr.$(REGION).amazonaws.com/$(IMAGE):$(VERSION)