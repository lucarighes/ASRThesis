utt2spk = open("data/train/utt2spk", "w")
text = open("data/train/text", "r")

for line in text:
	idUtt = line.split(' ')[0]
	utt = idUtt
	spk = idUtt.split('-')[0]
	utt2spk.write(utt + " " + spk + "\n")

text.close()
utt2spk.close()
	
