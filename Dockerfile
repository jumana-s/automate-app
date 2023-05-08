FROM golang:1.20.0-alpine

COPY src/ /app/

WORKDIR /app

ARG GIN_MODE=debug

# download go modules
RUN go mod download

# build
RUN CGO_ENABLED=0 GOOS=linux go build -o /simple-api-app

EXPOSE 8080

CMD ["/simple-api-app"]