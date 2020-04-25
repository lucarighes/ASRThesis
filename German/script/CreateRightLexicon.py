if __name__ == "__main__":
	myfile = open("data/local/dict/lexicon.txt","r")
	lexicon = open("newlexicon.txt", "a")
	nonsilence = open("newsilence.txt", "a")
	phones = set()

	for line in myfile:
		space_split = line.split(" ")
		lexicon.write(space_split[0] + " ")
		if len(space_split) > 1:
			word_phones = space_split[1].split("-")
			for p in word_phones:
				p = p.rstrip()
				phones.add(p)
				lexicon.write(p + " ")
			lexicon.write("\n")
	
	sorted_set = sorted(phones)
	for s in sorted_set:
		nonsilence.write(s + "\n")
	
	myfile.close()
	lexicon.close()
	nonsilence.close()
