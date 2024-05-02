#!/bin/bash

rm -f y.tab.c y.tab.h lex.yy.c a.out

lex archaic_opt.l

yacc -v -d archaic_opt.y --warning=none
gcc y.tab.c --no-warnings


./a.out<quicksort.txt
python3 opt.py
