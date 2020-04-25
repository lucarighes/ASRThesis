import glob
import xml.etree.ElementTree as ET
import os

counter = 10000
l = ["_Yamaha.wav", "_Kinect-Beam.wav", "_Kinect-RAW.wav", "_Realtek.wav", "_Samson.wav"]

for filename in glob.glob('audio/train/*.xml'):
		if counter < 75000:
			tree = ET.parse(filename)
			baseTag = tree.getroot()
			speakerID = baseTag.find('speaker_id').text
			sentence = baseTag.find('sentence_id').text
			noExtName = os.path.splitext("/root/kaldi/egs/Deutsch/" + filename)[0]
			for i in range(1,6):
				print(speakerID + "-" + sentence + str(counter + i) + " " + noExtName + l[i-1])
			counter = counter + 5
