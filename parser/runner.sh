#!/bin/bash

lex archaic_parser.l

yacc -v -d archaic_parser.y 
gcc y.tab.c


./a.out<input.txt

