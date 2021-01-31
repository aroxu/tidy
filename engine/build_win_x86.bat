@echo off
set GOOS=windows
set GOARCH=386
mkdir build\engine_win_x86
go build -o build\engine_win_x86\engine.exe
