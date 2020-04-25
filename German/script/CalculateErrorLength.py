processNumber = 4
d = {}
with open("data/test/text", "r") as f:
	for line in f:
		line = line.split()
		d[line[0]] = len(line) -1

out = {}
check = {}
result = {}
for i in range(1,processNumber+1):
	check[i] = {}
	out[i] = 0
	result[i] = {}
	result[i]['avg'] = 0
	with open("exp/tri3a/decode/log/decode."+ str(i) + ".log", "r") as f:
		for line in f:
			line = line.split()
			if isinstance(line[0], str) and len(line[0]) == 46:
				out[i] += 1
				temp = d.get(line[0])
				result[i]['avg'] += temp
				if temp != None:
					check[i][line[0]] = int(temp) - len(line) -1
for k in check:
	result[k].update({'-5' : 0, '-3' : 0,  '0' : 0, '3' : 0, '5' : 0})
	for elem in check[k]:
		num = check[k][elem]
		if num >= -5 and num < -3:
			result[k]['-5'] += 1
		elif num >= -3 and num < 0:
			result[k]['-3'] += 1
		elif num == 0:
			result[k]['0'] += 1
		elif num > 0 and num <= 3:
			result[k]['3'] += 1
		elif num > 3 and num <= 5:
			result[k]['5'] += 1
print("------------------------------REPORT------------------------------")
print("file name\tavg length\t5 4\t3 2 1\t0\t-1-2-3\t-4-5")
for i in range(1,processNumber+1):
	print("decode."+ str(i) + ".log\t" + str(result[i]['avg'] / out[i]) +  "\t\t" + str(result[i]['-5']) + "\t" + str(result[i]['-3']) + "\t" + str(result[i]['0']) + "\t" + str(result[i]['3']) + "\t" + str(result[i]['5']))
print("------------------------------------------------------------------")

