mkdir -p build/engine_win_x86
GOOS=windows GOARCH=386 go build -o build/engine_win_x86/engine.exe