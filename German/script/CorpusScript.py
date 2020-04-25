import glob
import xml.etree.ElementTree as ET
import os

for filename in glob.glob('audio/train/*.xml'):
	tree = ET.parse(filename)
	baseTag = tree.getroot()
	text = baseTag.find('cleaned_sentence').text
	print(text.upper().encode('utf-8'))

for filename in glob.glob('audio/test/*.xml'):
	tree = ET.parse(filename)
	baseTag = tree.getroot()
	text = baseTag.find('cleaned_sentence').text
	print(text.upper().encode('utf-8'))
