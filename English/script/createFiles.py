import os
from pydub import AudioSegment


path = "./data/LibriSpeech/train-clean-100/"

wav = open("./data/train2/wav.scp", "w")
text = open("./data/train2/text", "w")
corpus = open("./data/train2/corpus.txt", "w")

for root, dirs, files in os.walk(path):
    for name in files:
        if name.endswith(("trans.txt")):
            retrieve = name
            splitted = retrieve.replace('.', '-').split('-')

            file1 = open(path + splitted[0] + '/' + splitted[1] + '/' + name, "r")
            for line in file1:
                #converting
                filename = line.split(' ')[0]
                if os.path.exists(path + splitted[0] + '/' + splitted[1] + '/' + filename + ".flac"):
                    song = AudioSegment.from_file(path + splitted[0] + '/' + splitted[1] + '/' + filename + ".flac", format="flac")
                    song.export(path + splitted[0] + '/' + splitted[1] + '/' + filename + ".wav",format = "wav")
                    os.remove(path + splitted[0] + '/' + splitted[1] + '/' + filename + ".flac")

                #create text file
                corpus.write(' '.join(line.split(' ')[1:]))
                text.write(line)
                wav.write(filename + " " + "/root/kaldi/egs/English/data/LibriSpeech/train-clean-100/" + splitted[0] + '/' + splitted[1] + '/' + filename + ".wav\n")
                #remove the flac file
                

            file1.close()

wav.close()
text.close()
