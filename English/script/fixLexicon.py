lexicon = open("data/local/dict/lexicon.txt", "r")
newLexicon = open("data/local/dict/newlexicon.txt", "w")
for line in lexicon:
    newLexicon.write(line.replace("\t", " "))

lexicon.close()
newLexicon.close()
    
