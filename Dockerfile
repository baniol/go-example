FROM golang:1.9 
RUN mkdir /go/src/app 
ADD . /go/src/app/ 
WORKDIR /go/src/app 
RUN make build 
EXPOSE 3000
CMD ["/go/src/app/go-example"]