# Golang Application

A simple app with one api call.

## Local setup 

Two ways to run this app locally.

### Use the Dockerfile in the root folder
Will need Docker installed 
1. Be in the root folder
2. Run `docker build -t simple-api-app:latest .`
3. Run `docker run --rm --name simple-api-app -p 8080:8080 simple-api-app:latest`
4. Open http://localhost:8080/msg to see the api call!

### Run with Go
Will need Golang installed (version 1.20)
1.  Be in current folder
2.  Run `go run .`

## Testing

Run `go test -v` to run test files in current folder.