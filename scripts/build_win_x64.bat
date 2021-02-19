@echo off
set GOOS=windows
set GOARCH=amd64
mkdir build\engine_win_x64
go build -o build\engine_win_x64\engine.exe
