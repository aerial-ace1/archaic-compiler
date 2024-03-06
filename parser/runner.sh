#!/bin/bash

lex -o archaic_parser.yy.c archaic_parser.l

yacc -v -d archaic_parser.y --warning=none
gcc y.tab.c -o archaic_parser.out


./archaic_parser.out<input.txt

