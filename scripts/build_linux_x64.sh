mkdir -p build/engine_linux_x64
GOOS=linux GOARCH=amd64 go build -o build/engine_linux_x64/engine