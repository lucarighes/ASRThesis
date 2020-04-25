#!/bin/sh
import os

ref = dict()
phones = dict()

with open("../data/local/dict/lexicon.txt") as f:
    for line in f:
        line = line.strip()
        columns = line.split(" ", 1)
        word = columns[0]
        pron = columns[1]
        try:
            ref[word].append(pron)
        except:
            ref[word] = list()
            ref[word].append(pron)

print ref

lex = open("../data/local/dict/lexicon.txt", "wb")

with open("../data/train/words.txt") as f:
    for line in f:
	while line and not line[-1].isalpha():
    		line = line[:-1]
        line = line.strip()
        if line in ref.keys():
            for pron in ref[line]:
                lex.write(line + " " + pron+"\n")
        else:
            print "Word not in lexicon:" + line


