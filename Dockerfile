FROM golang:1.9 
RUN mkdir /go/src/app 
ADD . /go/src/app/ 
WORKDIR /go/src/app 
RUN make build 
EXPOSE 3000
CMD ["/go/src/app/go-example"]


FROM golang:1.10 AS base

RUN mkdir -p /go/src/github.com/baniol/go-example 
ADD . /go/src/github.com/baniol/go-example/
WORKDIR /go/src/github.com/baniol/go-example

RUN make buildgo

FROM alpine

RUN mkdir /app
WORKDIR /app
COPY --from=base /go/src/github.com/baniol/go-example/main /app/


CMD ["/app/main"]