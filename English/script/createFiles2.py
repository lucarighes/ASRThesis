import os
from pydub import AudioSegment


path = "./LibriSpeech/test-clean/"

wav = open("./data/test2/wav.scp", "w")
text = open("./data/test2/text", "w")
corpus = open("./data/test2/corpus.txt", "w")

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
                wav.write(filename + " " + "/root/kaldi/egs/English/LibriSpeech/test-clean/" + splitted[0] + '/' + splitted[1] + '/' + filename + ".wav\n")
                #remove the flac file


            file1.close()

wav.close()
text.close()
