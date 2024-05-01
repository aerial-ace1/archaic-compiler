f = open("opt.txt", "r")
lines = []
for line in f:
    lines.append(line.strip())
f.close()

for i in range(len(lines)):
    # Simplify algebraic expressions
    if ('+ 0' in lines[i]):
        lines[i] = lines[i].replace('+ 0', '')
    if ('- 0' in lines[i]):
        lines[i] = lines[i].replace('- 0', '')
    if ('* 1' in lines[i]):
        lines[i] = lines[i].replace('* 1', '')
    if ('/ 1' in lines[i]):
        lines[i] = lines[i].replace('/ 1', '')
    if ('+ 0.0' in lines[i]):
        lines[i] = lines[i].replace('+ 0.0', '')
    if ('- 0.0' in lines[i]):
        lines[i] = lines[i].replace('- 0.0', '')
    if ('* 1.0' in lines[i]):
        lines[i] = lines[i].replace('* 1.0', '')
    if ('/ 1.0' in lines[i]):
        lines[i] = lines[i].replace('/ 1.0', '')
    if ('0 +' in lines[i]):
        lines[i] = lines[i].replace('0 +', '')
    if ('0.0 +' in lines[i]):
        lines[i] = lines[i].replace('0.0 +', '')
    if ('1 *' in lines[i]):
        lines[i] = lines[i].replace('1 *', '')
    if ('1.0 *' in lines[i]):
        lines[i] = lines[i].replace('1.0 *', '')
    if ('0 -' in lines[i]):
        lines[i] = lines[i].replace('0 -', '-')
    if ('0.0 -' in lines[i]):
        lines[i] = lines[i].replace('0.0 -', '-')

    # Strength Reduction
    if ('* 2' in lines[i] and '2.' not in lines[i]) or ('* 2.0' in lines[i]):
        split = lines[i].split(' ')
        lines[i] = ' '.join([split[0], split[1], split[2], '+', split[2]])
    if ('2.0 *' in lines[i] or '2 *' in lines[i]):
        split = lines[i].split(' ')
        lines[i] = ' '.join([split[0], split[1], split[4], '+', split[4]])
    
# Constant folding
for i in range(len(lines)):
    if ('=' in lines[i] and lines[i].count('=') == 1):
        lhs, rhs = lines[i].split('=')
        try:
            result = eval(rhs)
            lines[i] = lhs + '= ' + str(result)
        except:
            pass

# Constant Propagation
variables = {}
temp_to_remove = []
for i in range(len(lines)):
    if ('=' in lines[i] and lines[i].count('=') == 1):
        lhs, rhs = lines[i].split('=')
        try:
            if (isinstance(eval(rhs), (int, float)) and 't' in lhs):
                variables[lhs.strip()] = rhs.strip()
                temp_to_remove.append(i)
        except:
            exp = rhs.split(' ')
            for j in range(len(exp)):
                if exp[j] in variables:
                    exp[j] = variables[exp[j]]
            lines[i] = lhs + '=' + ' '.join(exp)

# Constant folding after constant propagation
for i in range(len(lines)):
    if ('=' in lines[i] and lines[i].count('=') == 1):
        lhs, rhs = lines[i].split('=')
        try:
            result = eval(rhs)
            lines[i] = lhs + '= ' + str(result)
        except:
            pass

# Constant propagation after constant folding
for i in range(len(lines)):
    if ('=' in lines[i] and lines[i].count('=') == 1):
        lhs, rhs = lines[i].split('=')
        try:
            if (isinstance(eval(rhs), (int, float)) and 't' in lhs):
                variables[lhs.strip()] = rhs.strip()
                temp_to_remove.append(i)
        except:
            exp = rhs.split(' ')
            for j in range(len(exp)):
                if exp[j] in variables:
                    exp[j] = variables[exp[j]]
            lines[i] = lhs + '=' + ' '.join(exp)

for i in temp_to_remove:
    lines[i] = ''

# Write the optimized code to a new file
f = open("optimized.txt", "w")
print ("\nOPTIMIZED INTERMEDIATE CODE GENERATION:")
for line in lines:
    f.write(line + "\n")
    print (line)
f.close()