path = '../data/train/text'

with open(path) as file:
	line = file.readline()
	while line:
		s = line.split()
		res = s[0]
		for elem in range(1,len(s)):
			res += " " + s[elem].decode('utf-8').upper().encode('utf-8')
		print(res)
		line = file.readline()
