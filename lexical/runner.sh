#! /bin/sh

lex -o archaic.yy.cpp archaic.l
g++ archaic.yy.cpp -o archaic.out
./archaic.out

