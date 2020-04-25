import glob
import xml.etree.ElementTree as ET

#spk2gender file
for filename in glob.glob('audio/train/*.xml'):
	tree = ET.parse(filename)
	baseTag = tree.getroot()
	speaker = baseTag.find('speaker_id').text
	gender = baseTag.find('gender').text
	outgender = ""
	if gender == "female":
		outgender = "f"
	else:
		outgender = "m"
	print(str(speaker) + " " + outgender)

