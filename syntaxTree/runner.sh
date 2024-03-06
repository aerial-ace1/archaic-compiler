#!/bin/bash

lex -o archaic_tree.yy.c archaic_tree.l

yacc -v -d archaic_tree.y --warning=none
gcc y.tab.c -o archaic_tree.out

./archaic_tree.out<input.txt

