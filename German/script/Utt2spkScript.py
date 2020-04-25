import glob
import xml.etree.ElementTree as ET
import os

counter = 10000
for filename in glob.glob('audio/train/*.xml'):
	if counter < 75000:
		tree = ET.parse(filename)
		baseTag = tree.getroot()
		speakerID = baseTag.find('speaker_id').text
		sentence = baseTag.find('sentence_id').text
		print(speakerID + "-" + sentence + str(counter + 1) + " " + speakerID)
		print(speakerID + "-" + sentence + str(counter + 2) + " " + speakerID)
		print(speakerID + "-" + sentence + str(counter + 3) + " " + speakerID)
		print(speakerID + "-" + sentence + str(counter + 4) + " " + speakerID)
		print(speakerID + "-" + sentence + str(counter + 5) + " " + speakerID)
		counter = counter + 5
