data = '/Users/jaypearce9/Downloads/AACT201603_pipe_delimited/clinical_study.txt'

g = open('/Users/jaypearce9/Desktop/Classes/Math_410/reformatData.txt','w+')

curStudy = ''

with open(data) as f:
    for line in f:
    	line = line.replace('\n','')
    	line = line.replace('\t','')
    	#found a new study
    	if line.startswith('NCT'):
    		#print line
    		#print curStudy
    		curStudy += '\n'
    		g.write(curStudy)
    		curStudy = str(line)
    	else:
    		curStudy += str(' '+line)

