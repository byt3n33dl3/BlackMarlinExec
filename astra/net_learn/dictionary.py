def name_convert(x):
    file = open('..\test.txt', 'r')
    dict_c = {}
    for i in file.readlines():
        i = str(i).strip()
        name, cl = str(i).split("	")[0], str(i).split("	")[1]
        dict_c[name] = cl
    try:
        return dict_c[x]
    except KeyError as e:
        return "default"
