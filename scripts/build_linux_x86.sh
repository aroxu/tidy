mkdir -p build/engine_linux_x86
GOOS=linux GOARCH=386 go build -o build/engine_linux_x86/engine