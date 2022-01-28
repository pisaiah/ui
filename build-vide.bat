@echo off
v -cc gcc -gc boehm -prod -skip-unused -cflags -static examples/ide
upx.exe -9 examples/ide/ide.exe
pause