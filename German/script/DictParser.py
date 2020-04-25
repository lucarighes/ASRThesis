l = []
with open("mydict.dic", "r") as f:
	for line in f:
		line = line.split(';')
		print(line[0].decode('utf-8').upper().encode('utf-8') + ' ' + line[1].decode('utf-8').replace('-',' ').upper().encode('utf-8').rstrip())

