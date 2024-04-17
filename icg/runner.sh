#!/bin/bash

rm -f y.tab.c y.tab.h lex.yy.c a.out

lex archaic_icg.l

yacc -v -d archaic_icg.y --warning=none
gcc y.tab.c --no-warnings


./a.out<input.txt

