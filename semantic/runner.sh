#!/bin/bash

rm -f y.tab.c y.tab.h lex.yy.c a.out

lex archaic_semantic.l

yacc -v -d archaic_semantic.y --warning=none
gcc y.tab.c --no-warnings


./a.out<input.txt

