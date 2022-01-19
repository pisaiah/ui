@echo off
echo v -cc gcc -gc boehm examples
v -cc gcc -gc boehm -prod -cflags -static examples/ide
pause