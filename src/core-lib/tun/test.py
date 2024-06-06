from brish import z, zp, Brish

NI = True

name="A$ron"
z("echo Hello {name}")

t1=""
def test1():
    assert t1 == "Hello A$ron"
    return True
NI or test1()

alist = ["# Fruits", "1. Orange", "2. Rambutan", "3. Strawberry"]
z("for i in {alist} ; do echo $i ; done")

t2=""
def test2():
    assert t2 == """# Fruits
1. Orange
2. Rambutan
3. Strawberry"""
NI or test2()

if z("test -e ~/"):
    print("HOME exists!")
else:
    print("We're homeless :(")

t3=""
assert t3 == "HOME exists!"

for path in z("command ls ~/tmp/"): # `command` helps bypass potential aliases defined on `ls`
    zp("du -h ~/tmp/{path}") # zp prints the result
