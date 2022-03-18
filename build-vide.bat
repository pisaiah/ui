REM @echo off
v -cc gcc -gc boehm -prod -skip-unused -cflags -static examples/ide
aupx.exe -9 examples/ide/ide.exe
pause