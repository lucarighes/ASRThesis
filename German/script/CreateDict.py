import glob
import xml.etree.ElementTree as ET
import os

s = set({'<OOV> OOV'})
#for filename in glob.glob('de-pronunciation-lexicon-20080313.xml'):
#	tree = ET.parse(filename)
#	baseTag = tree.getroot()
#	for e in baseTag:
#		word = ""
#		transcript = ""
#		for elem in e:
#			if elem.tag == 'grapheme':
#				word = elem.text
#			else: 
#				transcript = elem.text
#		s.add(word.upper().encode('utf-8') + ' ' + transcript.upper().encode('utf-8'))
with open("cmusphinx-voxforge-de.dic", "r") as f:
	for line in f:
		s.add(line.decode('utf-8').upper().encode('utf-8'))

l = list(s)
l.sort()
for elem in l:
	print elem.rstrip()

