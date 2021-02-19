mkdir -p build/engine_win_x64
GOOS=windows GOARCH=amd64 go build -o build/engine_win_x64/engine.exe