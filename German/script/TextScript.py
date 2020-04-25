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
		text = baseTag.find('cleaned_sentence').text
		print(speakerID + "-" + sentence + str(counter + 1) + " " + text.upper().encode('utf-8'))
		print(speakerID + "-" + sentence + str(counter + 2) + " " + text.upper().encode('utf-8'))
		print(speakerID + "-" + sentence + str(counter + 3) + " " + text.upper().encode('utf-8'))
		print(speakerID + "-" + sentence + str(counter + 4) + " " + text.upper().encode('utf-8'))
		print(speakerID + "-" + sentence + str(counter + 5) + " " + text.upper().encode('utf-8'))
		counter = counter + 5
