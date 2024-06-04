#!/usr/bin/env python2
# -*- coding: UTF-8 -*-

# this is an "amalgamated" version of pyexpander 1.10.2, containing
# the 2 library files and the main command line frontend.
# the sources have been taken from https://files.pythonhosted.org/packages/fb/1f/6497aa7140e44d0f95ab110c95e74d971292d65712a3d2356ffc432a3df0/pyexpander-1.10.2.tar.gz
# pyexpander 1.10.2 has been chosen over the more recent 2.0 release
# as python 2.7 support has been dropped in the latter.

# due to how imports work, the variables INPUT_DEFAULT_ENCODING
# and SYS_DEFAULT_ENCODING had to be declared global both in
# filescope and the function in the if __main__ block using them.

# IMPORTANT! the default token character $ has been modified to ~ as my
# intention is to use this on html files that use jquery javascript
# that makes extensive use of $(...) itself.

# (C) 2012-2020 Goetz Pfeiffer <Goetz.Pfeiffer@helmholtz-berlin.de>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.

# you can find the full license text at:
# https://www.gnu.org/licenses/gpl-3.0.txt

# --------------------- start of imported sources ------------------

# imported from pyexpander 1.10.2 python2/pyexpander/parser.py

"""implement the parser for pyexpander.
"""
import bisect
import re

__version__= "1.10.2" #VERSION#

# pylint: disable= invalid-name

# we use '\n' as line separator and rely on python's built in line end
# conversion to '\n' on all platforms.
# You may howver, use change_linesep() to change the line separator.

LINESEP= "\n"
LINESEP_LEN= len(LINESEP)

def change_linesep(sep):
    """change line separator, this is here just for tests.
    """
    # pylint: disable= global-statement
    global LINESEP, LINESEP_LEN
    LINESEP= sep
    LINESEP_LEN= len(sep)

class IndexedString(object):
    """a string together with row column information.

    Here is an example:

    >>> txt='''01234
    ... 67
    ... 9abcd'''
    >>> l=IndexedString(txt)
    >>> l.rowcol(0)
    (1, 1)
    >>> l.rowcol(1)
    (1, 2)
    >>> l.rowcol(4)
    (1, 5)
    >>> l.rowcol(5)
    (1, 6)
    >>> l.rowcol(6)
    (2, 1)
    >>> l.rowcol(7)
    (2, 2)
    >>> l.rowcol(8)
    (2, 3)
    >>> l.rowcol(9)
    (3, 1)
    >>> l.rowcol(13)
    (3, 5)
    >>> l.rowcol(14)
    (3, 6)
    >>> l.rowcol(16)
    (3, 8)
    """
    # pylint: disable= too-few-public-methods
    def __init__(self, st):
        self._st=st
        self._lines=None
        self._positions=None
    def _list(self):
        """calculate and remember positions where lines begin."""
        l= len(self._st)
        pos=0
        self._lines=[1]
        self._positions=[0]
        lineno=1
        while True:
            # look for the standard lineseparator in the string:
            p= self._st.find(LINESEP, pos)
            if p<0:
                # not found
                break
            pos= p+LINESEP_LEN
            if pos>=l:
                break
            lineno+=1
            self._lines.append(lineno)
            self._positions.append(pos)
    def rowcol(self,pos):
        """calculate (row,column) from a string position."""
        if self._lines is None:
            self._list()
        idx= bisect.bisect_right(self._positions, pos)-1
        off= self._positions[idx]
        return(self._lines[idx], pos-off+1)
    def st(self):
        """return the raw string."""
        return self._st
    def __str__(self):
        return "IndexedString(...)"
    def __repr__(self):
        # Note: if repr(some object) gets too long since
        # repr(IndexedString(..)) basically prints the whole input file
        # you may in-comment the following line in order to make
        # the output shorter:
        #return "IndexedString(...)"
        return "IndexedString(%s)" % repr(self._st)

class ParseException(Exception):
    """used for Exceptions in this module."""
    def __init__(self, value, pos=None, rowcol=None):
        super(ParseException, self).__init__(value, pos, rowcol)
        self.value = value
        self.pos= pos
        self.rowcol= rowcol
    def __str__(self):
        if self.rowcol is not None:
            return "%s line %d, col %d" % \
                   (self.value,self.rowcol[0],self.rowcol[1])
        elif self.pos is not None:
            return "%s position: %d" % (self.value,self.pos)
        return "%s" % self.value

rx_pyIdent= re.compile(r'([A-Za-z_][\w\.]*)$')

rx_csv=re.compile(r'\s*,\s*')

def scanPyIdentList(st):
    """scan a list of python identifiers.

    Here are some examples:

    >>> scanPyIdentList("a,b")
    ['a', 'b']
    >>> scanPyIdentList("a,b.d, c")
    ['a', 'b.d', 'c']
    >>> scanPyIdentList("a,b.d, c&")
    Traceback (most recent call last):
        ...
    ParseException: list of python identifiers expected
    """
    lst= re.split(rx_csv, st)
    for elm in lst:
        m= rx_pyIdent.match(elm)
        if m is None:
            raise ParseException("list of python identifiers expected")
    return lst

rx_py_in= re.compile(r'^\s*(.*?)\s*\b(in)\b\s*(.*?)\s*$')
def scanPyIn(st):
    """scan a python "in" statement.

    Here are some examples:

    >>> scanPyIn(" (a,b) in k.items() ")
    ('(a,b)', 'in', 'k.items()')
    """
    m= rx_py_in.match(st)
    if m is None:
        raise ParseException("python \"in\" expression expected")
    return m.groups()

rx_bracketed= re.compile(r'\{[A-Za-z_]\w*\}')

def parseBracketed(idxst,pos):
    """parse an identifier in curly brackets.

    Here are some examples:

    >>> def test(st,pos):
    ...     idxst= IndexedString(st)
    ...     (a,b)= parseBracketed(idxst,pos)
    ...     print st[a:b]
    ...
    >>> test(r'{abc}',0)
    {abc}
    >>> test(r'{ab8c}',0)
    {ab8c}
    >>> test(r'{c}',0)
    {c}
    >>> test(r'{}',0)
    Traceback (most recent call last):
        ...
    ParseException: command enclosed in curly brackets at line 1, col 1
    >>> test(r'{abc',0)
    Traceback (most recent call last):
        ...
    ParseException: command enclosed in curly brackets at line 1, col 1
    >>> test(r'x{ab8c}',1)
    {ab8c}
    """
    if not isinstance(idxst, IndexedString):
        raise TypeError, "idxst par wrong: %s" % repr(idxst)
    st= idxst.st()
    m= rx_bracketed.match(st,pos)
    if m is None:
        raise ParseException("command enclosed in curly brackets at",
                             rowcol= idxst.rowcol(pos))
    return(pos,m.end())


# from python 2 documentation:
# stringprefix    ::=  "r" | "u" | "ur" | "R" | "U" | "UR" | "Ur" | "uR"
#                      | "b" | "B" | "br" | "Br" | "bR" | "BR"

rx_StringLiteralStart= re.compile(r'''(br|bR|Br|BR|ur|uR|Ur|UR|b|B|r|R|u|U|)("""|''' + \
                                  """'''""" + \
                                  r'''|'|")''')
def parseStringLiteral(idxst,pos):
    r"""parse a python string literal.

    returns 2 numbers, the index where the string starts and
    the index of the first character *after* the string

    Here are some examples:

    >>> def test(st,pos):
    ...     idxst= IndexedString(st)
    ...     (a,b)= parseStringLiteral(idxst,pos)
    ...     print st[a:b]
    ...

    >>> test(r'''"abc"''',0)
    "abc"

    >>> test("'''ab'c'd'''",0)
    '''ab'c'd'''
    >>> test("'''ab'cd''''",0)
    '''ab'cd'''

    >>> test(r'''U"abc"''',0)
    U"abc"
    >>> test(r'''xU"abc"''',1)
    U"abc"
    >>> test(r'''xUr"abc"''',1)
    Ur"abc"

    >>> test(r'''xUr"ab\\"c"''',1)
    Ur"ab\\"

    >>> test(r'''xUr"ab\"c"''',1)
    Ur"ab\"c"
    >>> test(r'''xUr"ab\"c"''',0)
    Traceback (most recent call last):
        ...
    ParseException: start of string expected at line 1, col 1
    >>> test(r'''"ab''',0)
    Traceback (most recent call last):
        ...
    ParseException: end of string not found at line 1, col 1
    >>> test(r"'''ab'",0)
    Traceback (most recent call last):
        ...
    ParseException: end of string not found at line 1, col 1
    >>> test(r'''"ab\"''',0)
    Traceback (most recent call last):
        ...
    ParseException: end of string not found at line 1, col 1
    """
    if not isinstance(idxst, IndexedString):
        raise TypeError, "idxst par wrong: %s" % repr(idxst)
    st= idxst.st()
    m= rx_StringLiteralStart.match(st,pos)
    if m is None:
        raise ParseException("start of string expected at",
                             rowcol= idxst.rowcol(pos))
    prefix= m.group(1)
    starter= m.group(2) # """ or ''' or " or '
    #is_unicode= False
    #is_raw= False
    #if -1!=prefix.find("r"):
    #    is_raw= True
    #elif -1!=prefix.find("R"):
    #    is_raw= True
    #if -1!=prefix.find("u"):
    #    is_unicode= True
    #elif -1!=prefix.find("U"):
    #    is_unicode= True
    startpos= pos+len(prefix)+len(starter)
    while True:
        idx= st.find(starter, startpos)
        # if startpos>len(st), idx is also -1
        if idx==-1:
            raise ParseException("end of string not found at",
                                 rowcol= idxst.rowcol(pos))
        if st[idx-1]=="\\":
            # maybe escaped quote char
            try:
                if st[idx-2]!="\\":
                    # only then it is an escaped quote char
                    startpos= idx+1
                    continue
            except IndexError, _:
                raise ParseException("end of string not found at",
                                     rowcol= idxst.rowcol(pos))
        break
    if len(starter)==1:
        # simple single quoted string
        return(pos,idx+1)
    return(pos,idx+3)

def parseComment(idxst,pos):
    r"""parse a python comment.

    Here are some examples:

    >>> import os
    >>> def test(st,pos,sep=None):
    ...     if sep:
    ...         change_linesep(sep)
    ...     idxst= IndexedString(st)
    ...     (a,b)= parseComment(idxst,pos)
    ...     print repr(st[a:b])
    ...     change_linesep(os.linesep)
    ...
    >>> test("#abc",0)
    '#abc'
    >>> test("#abc\nef",0,"\n")
    '#abc\n'
    >>> test("#abc\r\nef",0,"\r\n")
    '#abc\r\n'
    >>> test("xy#abc",2)
    '#abc'
    >>> test("xy#abc\nef",2,"\n")
    '#abc\n'
    >>> test("xy#abc\nef",3)
    Traceback (most recent call last):
        ...
    ParseException: start of comment not found at line 1, col 4
    """
    if not isinstance(idxst, IndexedString):
        raise TypeError, "idxst par wrong: %s" % repr(idxst)
    st= idxst.st()
    if st[pos]!="#":
        raise ParseException("start of comment not found at",
                             rowcol= idxst.rowcol(pos))
    idx_lf= st.find(LINESEP,pos+1)
    if idx_lf==-1:
        return(pos, len(st))
    return(pos,idx_lf+LINESEP_LEN)

rx_CodePart= re.compile(r'''((?:UR|Ur|uR|ur|r|u|R|U|)(?:"""|''' + """'''""" + \
                        r'''|'|")|#|\(|\))''')
def parseCode(idxst,pos):
    r"""parse python code, it MUST start with a '('.

    Here are some examples:

    >>> def test(st,pos):
    ...     idxst= IndexedString(st)
    ...     (a,b)= parseCode(idxst,pos)
    ...     print st[a:b]
    ...
    >>> test(r'(a+b)',0)
    (a+b)
    >>> test(r'(a+(b*c))',0)
    (a+(b*c))
    >>> test(r'(a+(b*c)+")")',0)
    (a+(b*c)+")")
    >>> test(r"(a+(b*c)+''')''')",0)
    (a+(b*c)+''')''')
    >>> test(r"(a+(b*c)+''')'''+# comment )\n)",0)
    Traceback (most recent call last):
        ...
    ParseException: end of bracket expression not found at line 1, col 1
    >>>
    >>> test("(a+(b*c)+''')'''+# comment )\n)",0)
    (a+(b*c)+''')'''+# comment )
    )
    """
    if not isinstance(idxst, IndexedString):
        raise TypeError, "idxst par wrong: %s" % repr(idxst)
    st= idxst.st()
    if st[pos]!="(":
        raise ParseException("start of bracket expression not found at",
                             rowcol= idxst.rowcol(pos))
    startpos= pos+1
    while True:
        m= rx_CodePart.search(st, startpos)
        if m is None:
            raise ParseException("end of bracket expression not found at",
                                 rowcol= idxst.rowcol(pos))
        matched= m.group(1)
        if matched=="#":
            # a comment
            (_,b)= parseComment(idxst, m.start())
            startpos= b
            continue
        if matched=="(":
            # an inner bracket
            (_,b)= parseCode(idxst, m.start())
            startpos= b
            continue
        if matched==")":
            return(pos,m.start()+1)
        # from here it must be a string literal
        (_,b)= parseStringLiteral(idxst, m.start())
        startpos= b
        continue

class ParsedItem(object):
    """base class of parsed items."""
    def __init__(self, idxst, start, end):
        if not isinstance(idxst, IndexedString):
            raise TypeError, "idxst par wrong: %s" % repr(idxst)
        self._idxst= idxst
        self._start= start
        self._end= end
    def string(self):
        """return the string that represents the ParsedItem."""
        return self._idxst.st()[self._start:self._end+1]
    def start(self):
        """return the start of the ParsedItem in the source string."""
        return self._start
    def end(self):
        """return the end of the ParsedItem in the source string."""
        return self._end
    def rowcol(self, pos= None):
        """calculate (row,column) from a string position."""
        if pos is None:
            pos= self.start()
        return self._idxst.rowcol(pos)
    def positions(self):
        """return start and end of ParsedItem in the source string."""
        return "(%d, %d)" % (self._start, self._end)
    def __str__(self):
        return "('%s', %s, %s)" % (self.__class__.__name__, \
               self.positions(), repr(self.string()))
    def __repr__(self):
        return "%s(%s, %s, %s)" % (self.__class__.__name__, \
                repr(self._idxst), repr(self._start), repr(self._end))

class ParsedLiteral(ParsedItem):
    """class of a parsed literal.

    A literal is a substring in the input that shouldn't be modified by
    pyexpander.
    """
    def __init__(self, idxst, start, end):
        ParsedItem.__init__(self, idxst, start, end)

class ParsedComment(ParsedItem):
    """class of a parsed comment.

    A comment in pyexpander starts with '~#'.
    """
    def __init__(self, idxst, start, end):
        ParsedItem.__init__(self, idxst, start, end)

class ParsedVar(ParsedItem):
    """class of a parsed variable.

    A variable in pyexpander has the form "~(identifier)".
    """
    def __init__(self, idxst, start, end):
        ParsedItem.__init__(self, idxst, start, end)

class ParsedEval(ParsedItem):
    """class of an pyexpander expression.

    A pyexpander expression has the form "~(expression)" e.g. "~(a+1)". This is
    different from ParsedVar where the string within the brackets is a simple
    identifier.
    """
    def __init__(self, idxst, start, end):
        ParsedItem.__init__(self, idxst, start, end)

class ParsedPureCommand(ParsedItem):
    """class of a pyexpander command without arguments.

    A pure command has the form "~name". Such a command has no arguments which
    would be enclosed in round brackets immediately following the name.
    """
    def __init__(self, idxst, start, end):
        ParsedItem.__init__(self, idxst, start, end)

class ParsedCommand(ParsedItem):
    """class of a pyexpander command with arguments.

    A command has the form "~name(argument1, argument2, ...)".
    """
    def __init__(self, idxst, start, end, ident):
        ParsedItem.__init__(self, idxst, start, end)
        self.ident= ident
    def args(self):
        """return the arguments of the command."""
        return self.string()
    def __str__(self):
        return "('%s', %s, %s, %s)" % (self.__class__.__name__, \
               self.positions(), repr(self.string()), \
               repr(self.ident))
    def __repr__(self):
        return "%s(%s, %s, %s, %s)" % (self.__class__.__name__, \
                repr(self._idxst), repr(self._start), repr(self._end), \
                repr(self.ident))


rx_DollarFollows= re.compile(r'([A-Za-z_]\w*|\(|\{|#)')

def parseDollar(idxst, pos):
    r"""parse things that follow a dollar.

    Here are some examples:

    >>> def test(st,pos):
    ...   idxst= IndexedString(st)
    ...   (p,elm)= parseDollar(idxst,pos)
    ...   print "Parsed: %s" % elm
    ...   print "rest of string:%s" % st[p:]
    ...
    >>> test("~abc",0)
    Parsed: ('ParsedPureCommand', (1, 3), 'abc')
    rest of string:
    >>> test("~abc%&/",0)
    Parsed: ('ParsedPureCommand', (1, 3), 'abc')
    rest of string:%&/
    >>> test("~abc(2*3)",0)
    Parsed: ('ParsedCommand', (5, 7), '2*3', 'abc')
    rest of string:
    >>> test(" ~abc(2*sin(x))",1)
    Parsed: ('ParsedCommand', (6, 13), '2*sin(x)', 'abc')
    rest of string:
    >>> test(" ~abc(2*sin(x))bn",1)
    Parsed: ('ParsedCommand', (6, 13), '2*sin(x)', 'abc')
    rest of string:bn
    >>> test(" ~# a comment\nnew line",1)
    Parsed: ('ParsedComment', (3, 13), ' a comment\n')
    rest of string:new line
    >>> test("~(abc)",0)
    Parsed: ('ParsedVar', (2, 4), 'abc')
    rest of string:
    >>> test("~(abc*2)",0)
    Parsed: ('ParsedEval', (2, 6), 'abc*2')
    rest of string:
    >>> test(" ~(2*x(y))abc",1)
    Parsed: ('ParsedEval', (3, 8), '2*x(y)')
    rest of string:abc
    """
    if not isinstance(idxst, IndexedString):
        raise TypeError, "idxst par wrong: %s" % repr(idxst)
    st= idxst.st()
    if st[pos]!="~":
        raise ParseException("'~' expected at",
                             rowcol= idxst.rowcol(pos))
    m= rx_DollarFollows.match(st, pos+1)
    if m is None:
        raise ParseException("unexpected characters after '~' at",
                             rowcol= idxst.rowcol(pos))
    matched= m.group(1)
    # pylint: disable= redefined-variable-type
    if matched=="#":
        # an expander comment
        (a, b)= parseComment(idxst, pos+1)
        elm= ParsedComment(idxst, a+1, b-1)
        return (b, elm)
    if matched=="(":
        (a, b)= parseCode(idxst, pos+1)
        m_ident= rx_pyIdent.match(st, a+1, b-1)
        if m_ident is not None:
            elm= ParsedVar(idxst, a+1, b-2)
        else:
            elm= ParsedEval(idxst, a+1, b-2)
        return (b, elm)
    if matched=="{":
        # a purecommand enclosed in "{}" brackets
        (a, b)= parseBracketed(idxst, pos+1)
        elm= ParsedPureCommand(idxst, a+1, b-2)
        return (b, elm)
    # from here: a purecommand or a command
    try:
        nextchar= st[m.end()]
    except IndexError, _:
        nextchar= None
    if nextchar=="(":
        (a, b)= parseCode(idxst, m.end())
        elm= ParsedCommand(idxst, a+1, b-2, matched)
        return (b, elm)
    elm= ParsedPureCommand(idxst, pos+1, m.end()-1)
    return (m.end(), elm)

def parseBackslash(idxst, pos):
    r"""parses a backslash.

    >>> import os
    >>> def test(st,pos,sep=None):
    ...     if sep:
    ...         change_linesep(sep)
    ...     idxst= IndexedString(st)
    ...     (p,elm)= parseBackslash(idxst,pos)
    ...     print "Parsed: %s" % elm
    ...     print "rest of string:%s" % repr(st[p:])
    ...     change_linesep(os.linesep)
    ...
    >>> test(r"\abc",0)
    Parsed: ('ParsedLiteral', (0, 0), '\\')
    rest of string:'abc'
    >>> test("\\",0)
    Parsed: ('ParsedLiteral', (0, 0), '\\')
    rest of string:''
    >>> test("\\\rab",0,"\r")
    Parsed: None
    rest of string:'ab'
    >>> test("\\\rab",0,"\n")
    Parsed: ('ParsedLiteral', (0, 0), '\\')
    rest of string:'\rab'
    >>> test("\\\rab",0,"\r\n")
    Parsed: ('ParsedLiteral', (0, 0), '\\')
    rest of string:'\rab'
    >>> test("\\\nab",0,"\r")
    Parsed: ('ParsedLiteral', (0, 0), '\\')
    rest of string:'\nab'
    >>> test("\\\nab",0,"\n")
    Parsed: None
    rest of string:'ab'
    >>> test("\\\nab",0,"\r\n")
    Parsed: ('ParsedLiteral', (0, 0), '\\')
    rest of string:'\nab'
    >>> test("\\\r\nab",0,"\r")
    Parsed: None
    rest of string:'\nab'
    >>> test("\\\r\nab",0,"\n")
    Parsed: ('ParsedLiteral', (0, 0), '\\')
    rest of string:'\r\nab'
    >>> test("\\\r\nab",0,"\r\n")
    Parsed: None
    rest of string:'ab'
    """
    # pylint: disable= too-many-return-statements
    # backslash found
    if not isinstance(idxst, IndexedString):
        raise TypeError, "idxst par wrong: %s" % repr(idxst)
    st= idxst.st()
    if st[pos]!="\\":
        raise ParseException("backslash expected at",
                             rowcol= idxst.rowcol(pos))
    l_= len(st)
    if pos+1>=l_:
        # no more characters
        elm= ParsedLiteral(idxst, pos, pos)
        return (pos+1, elm)
    else:
        # at least one more character
        nextchar= st[pos+1]
        if nextchar=="\\":
            elm= ParsedLiteral(idxst, pos, pos)
            return (pos+2, elm)
        if nextchar=="~":
            elm= ParsedLiteral(idxst, pos+1, pos+1)
            return (pos+2, elm)
        if pos+LINESEP_LEN>=l_:
            # not enough characters for LINESEP
            elm= ParsedLiteral(idxst, pos, pos)
            return (pos+1, elm)
        else:
            for i in xrange(LINESEP_LEN):
                if st[pos+1+i]!=LINESEP[i]:
                    # no line separator follows
                    elm= ParsedLiteral(idxst, pos, pos)
                    return (pos+1, elm)
            return(pos+LINESEP_LEN+1, None)

# WARNING: depending on which character is used to replace the original
# dollar "$" token, the character may or may not be escaped here!
rx_top= re.compile(r'(\~|\\)')
def parseAll(idxst, pos):
    r"""parse everything.

    >>> def test(st,pos):
    ...     idxst= IndexedString(st)
    ...     pprint(parseAll(idxst,pos))
    ...

    >>> test("abc",0)
    ('ParsedLiteral', (0, 2), 'abc')
    >>> test("abc~xyz",0)
    ('ParsedLiteral', (0, 2), 'abc')
    ('ParsedPureCommand', (4, 6), 'xyz')
    >>> test("abc~{xyz}efg",0)
    ('ParsedLiteral', (0, 2), 'abc')
    ('ParsedPureCommand', (5, 7), 'xyz')
    ('ParsedLiteral', (9, 11), 'efg')
    >>> test("abc~xyz(2*4)",0)
    ('ParsedLiteral', (0, 2), 'abc')
    ('ParsedCommand', (8, 10), '2*4', 'xyz')
    >>> test("abc~(2*4)ab",0)
    ('ParsedLiteral', (0, 2), 'abc')
    ('ParsedEval', (5, 7), '2*4')
    ('ParsedLiteral', (9, 10), 'ab')
    >>> test("abc\\~(2*4)ab",0)
    ('ParsedLiteral', (0, 2), 'abc')
    ('ParsedLiteral', (4, 4), '~')
    ('ParsedLiteral', (5, 11), '(2*4)ab')
    >>> test("ab~func(1+2)\\\nnew line",0)
    ('ParsedLiteral', (0, 1), 'ab')
    ('ParsedCommand', (8, 10), '1+2', 'func')
    ('ParsedLiteral', (14, 21), 'new line')
    >>> test("ab~func(1+2)\nnew line",0)
    ('ParsedLiteral', (0, 1), 'ab')
    ('ParsedCommand', (8, 10), '1+2', 'func')
    ('ParsedLiteral', (12, 20), '\nnew line')
    >>> test("ab~(xyz)(56)",0)
    ('ParsedLiteral', (0, 1), 'ab')
    ('ParsedVar', (4, 6), 'xyz')
    ('ParsedLiteral', (8, 11), '(56)')

    >>> test(r'''
    ... Some text with a macro: ~(xy)
    ... an escaped dollar: \~(xy)
    ... a macro within letters: abc~{xy}def
    ... a pyexpander command structure:
    ... ~if(a=1)
    ... here
    ... ~else
    ... there
    ... ~endif
    ... now a continued\
    ... line
    ... from here:~# the rest is a comment
    ... now an escaped continued\\
    ... line
    ... ''',0)
    ('ParsedLiteral', (0, 24), '\nSome text with a macro: ')
    ('ParsedVar', (27, 28), 'xy')
    ('ParsedLiteral', (30, 49), '\nan escaped dollar: ')
    ('ParsedLiteral', (51, 51), '~')
    ('ParsedLiteral', (52, 83), '(xy)\na macro within letters: abc')
    ('ParsedPureCommand', (86, 87), 'xy')
    ('ParsedLiteral', (89, 124), 'def\na pyexpander command structure:\n')
    ('ParsedCommand', (129, 131), 'a=1', 'if')
    ('ParsedLiteral', (133, 138), '\nhere\n')
    ('ParsedPureCommand', (140, 143), 'else')
    ('ParsedLiteral', (144, 150), '\nthere\n')
    ('ParsedPureCommand', (152, 156), 'endif')
    ('ParsedLiteral', (157, 172), '\nnow a continued')
    ('ParsedLiteral', (175, 189), 'line\nfrom here:')
    ('ParsedComment', (192, 214), ' the rest is a comment\n')
    ('ParsedLiteral', (215, 238), 'now an escaped continued')
    ('ParsedLiteral', (239, 239), '\\')
    ('ParsedLiteral', (241, 246), '\nline\n')
    """
    if not isinstance(idxst, IndexedString):
        raise TypeError, "idxst par wrong: %s" % repr(idxst)
    st= idxst.st()
    parselist=[]
    l= len(st)
    while True:
        if pos>=l:
            return parselist
        m= rx_top.search(st, pos)
        if m is None:
            parselist.append(ParsedLiteral(idxst, pos, len(st)-1))
            return parselist
        if m.start()>pos:
            parselist.append(ParsedLiteral(idxst, pos, m.start()-1))
        if m.group(1)=="\\":
            (p, elm)= parseBackslash(idxst, m.start())
            if elm is not None:
                parselist.append(elm)
            pos= p
            continue
        # from here it must be a dollar sign
        (pos, elm)= parseDollar(idxst, m.start())
        parselist.append(elm)
        continue

def pprint(parselist):
    """pretty print a parselist."""
    for elm in parselist:
        print str(elm)

def _parser_test():
    """perform the doctest tests."""
    import doctest
    print "testing..."
    doctest.testmod()
    print "done"

# imported from pyexpander 1.10.2 python2/pyexpander/lib.py

"""The main pyexpander library.
"""

# pylint: disable=too-many-lines

import os
import os.path
import inspect

import sys
import locale
import codecs
import keyword

# pylint: disable=wrong-import-position
# pylint: disable=invalid-name

# ---------------------------------------------
# constants
# ---------------------------------------------

PY_KEYWORDS= set(keyword.kwlist)

# length of line separator
LINESEP_LEN= len(os.linesep)

global SYS_DEFAULT_ENCODING, INPUT_DEFAULT_ENCODING
SYS_DEFAULT_ENCODING= locale.getpreferredencoding()

# INPUT_DEFAULT_ENCODING may be changed by expander.py:
INPUT_DEFAULT_ENCODING= SYS_DEFAULT_ENCODING

INTERNAL_ENCODING= "utf-8"

PURE_CMD_KEYWORDS= set([ \
                        "else",
                        "endif",
                        "endfor",
                        "endwhile",
                        "endmacro",
                        "begin",
                        "end",
                       ])

CMD_KEYWORDS=      set([ \
                        "py",
                        "include",
                        "include_begin",
                        "template",
                        "subst",
                        "pattern",
                        "default",
                        "if",
                        "elif",
                        "for",
                        "for_begin",
                        "while",
                        "while_begin",
                        "macro",
                        "nonlocal",
                        "extend",
                        "extend_expr",
                       ])

KEYWORDS= PURE_CMD_KEYWORDS | CMD_KEYWORDS | PY_KEYWORDS

# ---------------------------------------------
# dump utilities
# ---------------------------------------------

def _set2str(val):
    """convert an iterable to the repr string of a set."""
    elms= sorted(list(val))
    return "set(%s)" % repr(elms)

def _pr_set(val):
    """print an iterable as the repr string of a set."""
    print _set2str(val)

def find_file(filename, include_paths):
    """find a file in a list of include paths.

    include_paths MUST CONTAIN "" in order to search the
    local directory.
    """
    if include_paths is None:
        return None
    for path in include_paths:
        p= os.path.join(path, filename)
        if os.path.exists(p):
            if os.access(p, os.R_OK):
                return p
            print "warning: file \"%s\" found but it is not readable" % \
                  p
    return None

# ---------------------------------------------
# helper functions
# ---------------------------------------------

def keyword_check(identifiers):
    """indentifiers must not be identical to keywords.

    This function may raise an exception.
    """
    s= set(identifiers).intersection(KEYWORDS)
    if s:
        lst= ", ".join(["'%s'" % e for e in sorted(s)])
        raise ValueError, "keywords %s cannot be used as identifiers" % lst

_valid_encodings= set()

def test_encoding(encoding):
    """test if an encoding is known.

    raises (by encode() method) a LookupError exception in case of an error.
    """
    if encoding in _valid_encodings:
        return 
    "a".encode(encoding) # may raise LookupError
    _valid_encodings.add(encoding)

def one_or_two_strings(arg):
    """arg must be a single string or a tuple of two strings."""
    if isinstance(arg, str):
        return (arg, None)
    if not isinstance(arg, tuple):
        raise TypeError("one or two strings expected")
    if len(arg)>2:
        raise TypeError("too many arguments (only 2 allowed)")
    if not isinstance(arg[0], str):
        raise TypeError("1st argument must be a string")
    if not isinstance(arg[1], str):
        raise TypeError("2nd argument must be a string")
    return arg

# ---------------------------------------------
# parse a string or a file
# ---------------------------------------------

def parseString(st):
    """parse a string."""
    return parseAll(IndexedString(st), 0)

def parseFile(filename, encoding, no_stdin_warning):
    """parse a file."""
    if filename is None:
        if not no_stdin_warning:
            sys.stderr.write("(reading from stdin)\n")
        try:
            st= sys.stdin.read()
        except KeyboardInterrupt:
            sys.exit(" interrupted\n")
    else:
        exc= None
        try:
            with open(filename, "rU") as f:
                if encoding==INTERNAL_ENCODING:
                    st= f.read()
                else:
                    st= (f.read()).decode(encoding).encode(INTERNAL_ENCODING)
        except (IOError, UnicodeDecodeError) as e:
            exc= e
        if exc is not None:
            # we cannot re-raise UnicodeDecodeError since it needs 5
            # undocumented argiments and we just want an error message here
            # that includes the filename:
            raise IOError("File %s: %s" % (repr(filename), str(exc)))
    return parseString(st)

# ---------------------------------------------
# Result text class
# ---------------------------------------------

class ResultText(object):
    """basically a list of strings with a current column property.
    """
    def __init__(self):
        """initialize the object."""
        self._list= []
        self._column= -1
    @staticmethod
    def current_column(st):
        r"""find current column if the string is printed.

        Note: With a string ending with '\n' this returns 1.

        Here are some examples: >>> current_column("")
        -1
        >>> ResultText.current_column("ab")
        -1
        >>> ResultText.current_column("\nab")
        3
        >>> ResultText.current_column("\nab\n")
        1
        >>> ResultText.current_column("\nab\na")
        2
        """
        idx= st.rfind(os.linesep)
        if idx<0: # not found
            return -1 # unknown column
        return len(st)-idx
    def append(self, text):
        """append some text."""
        c= self.__class__.current_column(text)
        if c<0:
            if self._column>0:
                self._column+= len(text)
        else:
            self._column= c
        self._list.append(text)
    def list_(self):
        """return internal list."""
        return self._list
    def column(self):
        """return current column."""
        return self._column

# ---------------------------------------------
# process parse-list
# ---------------------------------------------

class Block(object):
    """class that represents a block in the expander language.

    Each block has a parent-pointer, which may be None. Blocks are used to
    represent syntactical blocks in the expander language. They manage the
    global variable dictionary and some more properties that are needed during
    execution of the program.
    """
    # pylint: disable=too-many-instance-attributes
    def posmsg(self, msg=None, pos=None):
        """return a message together with a position.

        This method is mainly used for error messages. We usually want to print
        filename and the line and column number together with a message. This
        method returns the given message string <msg> together with this
        additional information.
        """
        parts=[]
        if msg is not None:
            parts.append(msg)
        if self.filename is not None:
            parts.append("file \"%s\"" % self.filename)
        try:
            # posmsg is often called with pos==None. So we usually have to
            # determine the position ourselves. Usually posmsg is called when
            # an error occurs when processing self.parse_list[self.lst_pos]. So
            # if we call method rowcol(None) with this element (a ParsedItem
            # object) the *start* of the ParsedItem is calculated to a row and
            # a column and returned.
            p_elm= self.parse_list[self.lst_pos]
            parts.append("line %d, col %d" % p_elm.rowcol(pos))
            return " ".join(parts)
        except IndexError, _:
            return " ".join(parts)
    def _append(self, lst, name, val=None):
        """append a line with property information to a list.

        This method is used to create an object dump in method _strlist.
        """
        def elm2str(e):
            """convert an item to a "repr" like string."""
            if isinstance(e,set):
                return _set2str(e)
            return str(e)
        if val is not None:
            lst.append("    %-20s: %s" % (name,val))
        else:
            lst.append("    %-20s= %s" % (name,elm2str(getattr(self,name))))
    def _strlist(self):
        """utility for __str__.

        This function can be used by descendent classes in order to implement
        the __str__ method in a simple way.

        Tested by the testcode in __str__.
        """
        lst= []
        self._append(lst, "has parent",self.previous is not None)
        self._append(lst, "filename")
        self._append(lst, "template")
        self._append(lst, "template_path")
        self._append(lst, "template_encoding")
        self._append(lst, "has template_parselist_cache", \
                          self.template_parselist_cache is not None)
        self._append(lst, "exported_syms")
        self._append(lst, "direct_vars")
        self._append(lst, "direct_funcs")
        self._append(lst, "macros", repr(sorted(self.macros.keys())))
        self._append(lst, "new_scope")
        self._append(lst, "skip")
        self._append(lst, "safe_mode")
        self._append(lst, "indent")
        self._append(lst, "new_parse_list")
        self._append(lst, "lst_pos")
        self._append(lst, "start_pos")
        if self.lst_pos>=0 and self.lst_pos<len(self.parse_list):
            self._append(lst, "current parse elm",
                         self.parse_list[self.lst_pos])
        return lst
    def __init__(self,
                 previous= None,
                 new_scope= False,
                 filename= None,
                 parse_list=None,
                 external_definitions=None):
        """The Block constructor.

        Properties of a Block:
            parse_list    -- the list with parse objects
            lst_pos       -- the position in the parse_list
            start_pos     -- the start position of the block in the parse_list
            previous      -- the previous block
            new_scope     -- True if the block is also a new scope with
                             respect to global variables.
            indent        -- current automatic indent level, the default is 0
            skip          -- if True, skip a block in the text when the code
                             is interpreted
            safe_mode     -- if True, allow only "safe" commands that have no
                             side effects. ~() may only contain variable names,
                             py() is disabled and all commands enabled with
                             ~extend() are disabled. 
            globals_      -- a dictionary with the current global variables of
                             the interpreter.
            exported_syms -- a list of symbols (names in globals_) that are
                             copied to the globals_ dictionary of the parent
                             block when the pop() method is called.
            filename      -- name of the interpreted file, may be None
            template      -- name of the file that "~subst" would include,
                             usually None
            template_path -- complete path of template
                             usually None
            template_encoding
                          -- encoding of the template file
                             usually None
            template_parselist_cache --
                             parselist of the template, usually None.
                             This is a kind of optimization

        Here is an example:

        >>> b= Block(parse_list=[])
        >>> print b
        Block{
            has parent          : False
            filename            = None
            template            = None
            template_path       = None
            template_encoding   = None
            has template_parselist_cache: False
            exported_syms       = []
            direct_vars         = set([])
            direct_funcs        = set([])
            macros              : []
            new_scope           = False
            skip                = False
            safe_mode           = False
            indent              = 0
            new_parse_list      = True
            lst_pos             = -1
            start_pos           = 0
        }
        >>> b= Block(b,True,parse_list=[])
        >>> b.print_block_list()
        Block{
            has parent          : False
            filename            = None
            template            = None
            template_path       = None
            template_encoding   = None
            has template_parselist_cache: False
            exported_syms       = []
            direct_vars         = set([])
            direct_funcs        = set([])
            macros              : []
            new_scope           = False
            skip                = False
            safe_mode           = False
            indent              = 0
            new_parse_list      = True
            lst_pos             = -1
            start_pos           = 0
        }
        Block{
            has parent          : True
            filename            = None
            template            = None
            template_path       = None
            template_encoding   = None
            has template_parselist_cache: False
            exported_syms       = []
            direct_vars         = set([])
            direct_funcs        = set([])
            macros              : []
            new_scope           = True
            skip                = False
            safe_mode           = False
            indent              = 0
            new_parse_list      = True
            lst_pos             = -1
            start_pos           = 0
        }
        """
        # pylint: disable=too-many-arguments, too-many-branches
        # pylint: disable=too-many-statements
        if (filename is None) or (filename==""):
            self.filename= None
        else:
            self.filename= filename
        self.previous= previous
        if previous is None:
            self.new_scope= False
            self.skip= False
            self.safe_mode= False
            self.indent= 0
            self.globals_= dict()
            self.direct_vars=set()
            self.direct_funcs=set()
            self.macros= dict()
            self.exported_syms=[]
            if parse_list is None:
                raise AssertionError, "without previous, parse_list "+\
                                      "is mandatory"
            self.new_parse_list= True
            self.template= None
            self.template_path= None
            self.template_encoding= None
            self.template_parselist_cache= None
            self.parse_list= parse_list
            self.lst_pos= -1
            self.start_pos= 0
        else:
            if not isinstance(previous,Block):
                raise AssertionError, "previous is not a block: %s" % \
                                      str(previous)
            if self.filename is None:
                self.filename= previous.filename
            if parse_list is None:
                self.new_parse_list= False
                self.parse_list= previous.parse_list
                self.lst_pos= previous.lst_pos
                if previous.lst_pos<0:
                    self.start_pos= 0
                else:
                    self.start_pos= previous.lst_pos
            else:
                self.new_parse_list= True
                self.parse_list= parse_list
                self.lst_pos= -1
                self.start_pos= 0
            self.template= previous.template
            self.template_path= previous.template_path
            self.template_encoding= previous.template_encoding
            self.template_parselist_cache= previous.template_parselist_cache
            self.new_scope= new_scope
            self.skip= previous.skip
            self.safe_mode= previous.safe_mode
            self.indent= previous.indent
            if new_scope:
                self.globals_= dict(previous.globals_)
                self.direct_vars= set(previous.direct_vars)
                self.direct_funcs= set(previous.direct_funcs)
                self.macros= dict(previous.macros)
                self.exported_syms=[]
            else:
                self.globals_= previous.globals_
                self.direct_vars= previous.direct_vars
                self.direct_funcs= previous.direct_funcs
                self.macros= previous.macros
                self.exported_syms= previous.exported_syms
        if external_definitions is not None:
            for (k,v) in external_definitions.items():
                self.globals_[k]= v
    def parse_loop(self):
        """loop across the items in the Block.

        returns False if there is nothing more to parse in the current block.
        """
        self.lst_pos+= 1
        return self.lst_pos < len(self.parse_list)
    def parse_elm(self):
        """get the current parse element."""
        return self.parse_list[self.lst_pos]
    def eval_(self, st):
        """perform eval with the globals_ dictionary of the block.

        Here is an example:

        >>> b= Block(parse_list=[])
        >>> b.exec_("a=2")
        >>> b.eval_("3*a")
        6
        """
        try:
            # pylint: disable=eval-used
            return eval(st, self.globals_)
        except SyntaxError, e:
            raise SyntaxError, "%s at %s" % (str(e), self.posmsg())
        except NameError, e:
            raise NameError, "%s at %s" % (str(e), self.posmsg())
        except IndexError, e:
            raise IndexError, "%s at %s" % (str(e), self.posmsg())
        except TypeError, e:
            raise TypeError, "%s at %s" % (str(e), self.posmsg())
        except Exception, e:
            sys.stderr.write("error at %s:\n" % self.posmsg())
            raise
    def str_eval(self, st):
        """perform eval with the globals_ dictionary of the block.

        Here is an example:

        >>> b= Block(parse_list=[])
        >>> b.exec_("a=2")
        >>> b.str_eval("3*a")
        '6'
        """
        val= self.eval_(st)
        try:
            return str(val)
        except Exception, _:
            sys.stderr.write("error at %s:\n" % self.posmsg())
            raise
    def exec_(self, st):
        """perform exec with the globals_ dictionary of the block.

        Here is an example:

        >>> b= Block(parse_list=[])
        >>> b.exec_("a=1")
        >>> b["a"]
        1
        >>> b= Block(b,True)
        >>> b["a"]
        1
        >>> b.exec_("a=2")
        >>> b["a"]
        2
        >>> b.previous["a"]
        1
        """
        try:
            # pylint: disable=exec-used
            exec st in self.globals_
        except SyntaxError, e:
            raise SyntaxError, "%s at %s" % (str(e), self.posmsg())
        except NameError, e:
            raise NameError, "%s at %s" % (str(e), self.posmsg())
        except IndexError, e:
            raise IndexError, "%s at %s" % (str(e), self.posmsg())
        except TypeError, e:
            raise TypeError, "%s at %s" % (str(e), self.posmsg())
        except Exception, e:
            sys.stderr.write("error at %s:\n" % self.posmsg())
            raise
    def __getitem__(self, name):
        """looks up a value in the globals_ dictionary of the block.

        Here is an example:

        >>> b= Block(parse_list=[])
        >>> b.globals_["a"]= 5
        >>> b["a"]
        5

        Here we show how symbols with dots '.' are treated. We misuse
        os.path to create a variable os.path.myvar and store a
        reference to the module "os" in the Block "globals_"
        dictionary:

        >>> import os.path
        >>> os.path.myvar=100
        >>> b.globals_["os"]= os
        >>> b["os.path.myvar"]
        100
        """
        try:
            # pylint: disable=eval-used
            return eval(name, self.globals_)
        except NameError, e:
            raise NameError, "%s at %s" % (str(e),self.posmsg())
    def __setitem__(self, name, val):
        """sets a value in the globals_ dictionary of the block.

        Here is an example:

        >>> b= Block(parse_list=[])
        >>> b["a"]= 5
        >>> b.globals_["a"]
        5

        Here we show how symbols with dots '.' are treated. We misuse os.path
        to create a variable os.path.myvar and store a reference to the module
        "os" in the Block "globals_" dictionary:

        >>> import os.path
        >>> b["os"]= os
        >>> b["os.path.myvar"]= 200
        >>> os.path.myvar
        200
        >>> b["os.path.myvar"]
        200
        """
        self.globals_["__pyexpander_buffer"]= val
        try:
            # pylint: disable=exec-used
            exec "%s= __pyexpander_buffer" % name in self.globals_
        except AttributeError, e:
            raise AttributeError, "%s at %s" % (str(e),self.posmsg())
    def __delitem__(self, name):
        """deletes a value in the globals_ dictionary of the block.

        Here is an example:

        >>> import pprint
        >>> b= Block(parse_list=[])
        >>> b.globals_.keys()
        []
        >>> b["a"]= 5
        >>> b.globals_.keys()
        ['__pyexpander_buffer', '__builtins__', 'a']
        >>> b["a"]
        5
        >>> del b["a"]
        >>> b.globals_.keys()
        ['__pyexpander_buffer', '__builtins__']
        >>> b["a"]
        Traceback (most recent call last):
            ...
        NameError: name 'a' is not defined at unknown position
        >>> del b["c"]
        Traceback (most recent call last):
            ...
        NameError: name 'c' is not defined at unknown position

        Here we show how symbols with dots '.' are treated. We misuse os.path
        to create a variable os.path.myvar and store a reference to the module
        "os" in the Block "globals_" dictionary:

        >>> import os.path
        >>> b= Block(parse_list=[])
        >>> os.path.myvar=200
        >>> b["os"]= os
        >>> b["os.path.myvar"]
        200
        >>> del b["os.path.myvar"]
        >>> b["os.path.myvar"]
        Traceback (most recent call last):
            ...
        AttributeError: 'module' object has no attribute 'myvar'
        >>> os.path.myvar
        Traceback (most recent call last):
            ...
        AttributeError: 'module' object has no attribute 'myvar'
        """
        try:
            # pylint: disable=exec-used
            exec "del %s" % name in self.globals_
        except NameError, e:
            raise NameError, "%s at %s" % (str(e),self.posmsg())
    def __len__(self):
        """returns the number of items in the block.

        Here is an example:

        >>> b= Block(parse_list=[])
        >>> b.globals_.keys()
        []
        >>> b["a"]= 5
        >>> b["b"]= 6
        >>> b.globals_.keys()
        ['__pyexpander_buffer', '__builtins__', 'b', 'a']
        >>> len(b)
        4
        """
        return len(self.globals_)
    def setdefault(self, name, val):
        """return a value from globals, set to a default if it's not defined.

        Here are some examples:

        >>> b= Block(parse_list=[])
        >>> b["a"]
        Traceback (most recent call last):
            ...
        NameError: name 'a' is not defined at unknown position
        >>> b.setdefault("a",10)
        10
        >>> b["a"]
        10
        >>> b["a"]=11
        >>> b.setdefault("a",10)
        11
        """
        try:
            return self.__getitem__(name)
        except NameError, _:
            self.__setitem__(name,val)
        return val

    def set_substfile(self, filename, encoding, tp):
        """set substitution filename.

        Used for the "~subst", "~template" and "~pattern" commands.
        """
        if not isinstance(filename, str):
            raise ParseException( \
                    self.posmsg("filename must be a string at",
                                pos=tp.start()))
        if filename == self.template:
            return
        self.template_parselist_cache= None
        self.template_path= None
        self.template= filename
        self.template_encoding= encoding
    def substfile_parselist(self, include_paths):
        """return the parselist for a given file.

        This method manages a cache of that assigns filenames to parselists.
        This can speed things up if a file is included several times.
        """
        if self.template_parselist_cache is not None:
            return (self.template_path,self.template_parselist_cache)
        if self.template is None:
            raise ValueError, \
                  self.posmsg("substitition file name missing at")
        self.template_path= find_file(self.template, include_paths)
        if self.template_path is None:
            raise ValueError, \
                  self.posmsg("file \"%s\" not found in" % \
                               self.template)
        self.template_parselist_cache= parseFile(self.template_path,
                                                 self.template_encoding,
                                                 False)
        return (self.template_path,self.template_parselist_cache)
    def export_symbols(self, lst):
        """appends items to the export_symbols list.

        This list is used by the pop() method in order to copy values from the
        current globals_ dictionary to the globals_ dictionary of the previous
        block.

        Here is an example:

        >>> b= Block(parse_list=[])
        >>> b.export_symbols(["a","b"])
        >>> b.exported_syms
        ['a', 'b']
        >>> b.export_symbols(["d","e"])
        >>> b.exported_syms
        ['a', 'b', 'd', 'e']
        """
        self.exported_syms.extend(lst)
    def extend(self, lst):
        """adds items to the list of expander functions or variables.

        Here is an example:

        >>> a=1
        >>> b=2
        >>> def t(x):
        ...   return x+1
        ...
        >>> block= Block(parse_list=[],external_definitions=globals())
        >>> block.extend(["a","b","t"])
        >>> _pr_set(block.direct_vars)
        set(['a', 'b'])
        >>> _pr_set(block.direct_funcs)
        set(['t'])
        """
        for elm in lst:
            obj= self.globals_[elm]
            if inspect.isbuiltin(obj):
                self.direct_funcs.add(elm)
                continue
            if inspect.isfunction(obj):
                self.direct_funcs.add(elm)
                continue
            # assume elm to be a variable:
            self.direct_vars.add(elm)
    def set_safemode(self, value):
        """sets the safe_mode."""
        self.safe_mode= value
    def set_indent(self, value):
        """sets the indent."""
        self.indent= value
    def get_indent(self):
        """gets the indent."""
        return self.indent
    def format_text(self, text, indent_start):
        """currently does indent one or more lines."""
        if text=="":
            return text
        if self.indent<=0:
            return text
        ind= " "*self.indent
        cut= False
        if text.endswith(os.linesep):
            cut= True
        text= text.replace(os.linesep, os.linesep+ind)
        if cut:
            text= text[0:-self.indent]
        if not indent_start:
            return text
        return ind+text
    def add_macro(self, name, macro_block):
        """add a new macro block.
        """
        if not isinstance(macro_block, MacBlock):
            raise AssertionError("wrong type: %s has type %s" % \
                                 (name, type(macro_block)))
        self.macros[name]= macro_block

    def pop(self):
        """removes the current block and returns the previous one.

        Here is an example:

        >>> b= Block(parse_list=[])
        >>> b["a"]=1
        >>> b["b"]=2
        >>> b= Block(b,True)
        >>> b["a"]=10
        >>> b["b"]=20
        >>> b.export_symbols(["a"])
        >>> b= b.pop()
        >>> b["a"]
        10
        >>> b["b"]
        2
        """
        if self.previous is None:
            raise AssertionError,\
                  self.posmsg("block underflow (assertion) at")
        if self.new_scope:
            old= self.previous.globals_
            for elm in self.exported_syms:
                old[elm]= self.globals_[elm]
        # set the lst_pos in the parent Block:
        if not self.new_parse_list:
            self.previous.lst_pos= self.lst_pos
        return self.previous
    def __str__(self):
        """returns a string representation of the block.

        Here is an example:

        >>> b= Block(parse_list=[])
        >>> print b
        Block{
            has parent          : False
            filename            = None
            template            = None
            template_path       = None
            template_encoding   = None
            has template_parselist_cache: False
            exported_syms       = []
            direct_vars         = set([])
            direct_funcs        = set([])
            macros              : []
            new_scope           = False
            skip                = False
            safe_mode           = False
            indent              = 0
            new_parse_list      = True
            lst_pos             = -1
            start_pos           = 0
        }
        >>> b= Block(b,True)
        >>> print b
        Block{
            has parent          : True
            filename            = None
            template            = None
            template_path       = None
            template_encoding   = None
            has template_parselist_cache: False
            exported_syms       = []
            direct_vars         = set([])
            direct_funcs        = set([])
            macros              : []
            new_scope           = True
            skip                = False
            safe_mode           = False
            indent              = 0
            new_parse_list      = False
            lst_pos             = -1
            start_pos           = 0
        }
        """
        lst=["%s{" % "Block"]
        lst.extend(self._strlist())
        lst.append("}")
        return "\n".join(lst)
    def get_block_list(self):
        """returns all blocks of the list.

        The list is returned with the oldest block first.
        """
        lst=[]
        block= self
        while block is not None:
            lst.append(block)
            block= block.previous
        lst.reverse()
        return lst
    def str_block_list(self):
        """returns a string representation of all blocks in the list.

        The list is returned with the oldest block first.
        """
        return [str(elm) for elm in self.get_block_list()]
    def print_block_list(self):
        """print all blocks in the list.

        The list is returned with the oldest block first.

        Here is an example:

        >>> b= Block(parse_list=[])
        >>> print b
        Block{
            has parent          : False
            filename            = None
            template            = None
            template_path       = None
            template_encoding   = None
            has template_parselist_cache: False
            exported_syms       = []
            direct_vars         = set([])
            direct_funcs        = set([])
            macros              : []
            new_scope           = False
            skip                = False
            safe_mode           = False
            indent              = 0
            new_parse_list      = True
            lst_pos             = -1
            start_pos           = 0
        }
        >>> b= Block(b,True)
        >>> print b
        Block{
            has parent          : True
            filename            = None
            template            = None
            template_path       = None
            template_encoding   = None
            has template_parselist_cache: False
            exported_syms       = []
            direct_vars         = set([])
            direct_funcs        = set([])
            macros              : []
            new_scope           = True
            skip                = False
            safe_mode           = False
            indent              = 0
            new_parse_list      = False
            lst_pos             = -1
            start_pos           = 0
        }
        >>> b.print_block_list()
        Block{
            has parent          : False
            filename            = None
            template            = None
            template_path       = None
            template_encoding   = None
            has template_parselist_cache: False
            exported_syms       = []
            direct_vars         = set([])
            direct_funcs        = set([])
            macros              : []
            new_scope           = False
            skip                = False
            safe_mode           = False
            indent              = 0
            new_parse_list      = True
            lst_pos             = -1
            start_pos           = 0
        }
        Block{
            has parent          : True
            filename            = None
            template            = None
            template_path       = None
            template_encoding   = None
            has template_parselist_cache: False
            exported_syms       = []
            direct_vars         = set([])
            direct_funcs        = set([])
            macros              : []
            new_scope           = True
            skip                = False
            safe_mode           = False
            indent              = 0
            new_parse_list      = False
            lst_pos             = -1
            start_pos           = 0
        }
        """
        print "\n".join(self.str_block_list())

class IncludeBlock(Block):
    """implements a ~include(filename) block.

    This block is simply a variable scope, so it is derived from Block where
    the constructor is called with new_scope=True.
    """
    def __init__(self,
                 previous= None,
                 new_scope= False,
                 filename= None,
                 encoding= SYS_DEFAULT_ENCODING,
                 include_paths=None):
        # pylint: disable=too-many-arguments
        path= find_file(filename, include_paths)
        if path is None:
            parse_list= []
        else:
            parse_list= parseFile(path, encoding, False)
        Block.__init__(self, previous, new_scope,
                       path,
                       parse_list)
        if path is None:
            raise ValueError, \
                  self.posmsg("file \"%s\" not found in" % filename)
    def __str__(self):
        lst=["%s{" % "IncludeBlock"]
        lst.extend(self._strlist())
        lst.append("}")
        return "\n".join(lst)

class SubstBlock(Block):
    """implements a ~subst(parameters) block.

    This block is simply a variable scope, so it is derived from Block where
    the constructor is called with new_scope=True.
    """
    def __init__(self,
                 previous= None,
                 filename= None,
                 include_paths=None,
                 external_definitions=None):
        (path,parse_list)= previous.substfile_parselist(include_paths)
        Block.__init__(self, previous, True, # always new scope
                       path,
                       parse_list,
                       external_definitions)
        if path is None:
            raise ValueError, \
                  self.posmsg("file \"%s\" not found in" % filename)
    def __str__(self):
        lst=["%s{" % "SubstBlock"]
        lst.extend(self._strlist())
        lst.append("}")
        return "\n".join(lst)

class PatternBlock(Block):
    """implements a ~pattern(parameters) block.

    This block is simply a variable scope, so it is derived from Block where
    the constructor is called with new_scope=True.
    """
    def _strlist(self):
        lst= Block._strlist(self)
        self._append(lst, "heading")
        self._append(lst, "lines")
        self._append(lst, "curr_line")
        return lst
    def __init__(self,
                 previous= None,
                 filename= None,
                 include_paths=None,
                 heading=None,
                 lines=None):
        # pylint: disable=too-many-arguments
        (path,parse_list)= previous.substfile_parselist(include_paths)
        Block.__init__(self, previous, False, # no new scope
                       path, parse_list)
        if path is None:
            raise ValueError, \
                  self.posmsg("file \"%s\" not found in" % filename)
        if heading is None:
            heading= []
        if lines is None:
            lines= []
        self.heading= heading
        self.lines= lines
        if len(self.lines)<1:
            raise ValueError, \
                  self.posmsg("no instantiation data")
        self.curr_line= -1
        self.def_vars()
    def pop(self):
        if not self.def_vars():
            return Block.pop(self)
        # reset position in file
        self.lst_pos= -1
        return self
    def def_vars(self):
        """define all the given variables in the PatternBlock."""
        self.curr_line+=1
        if self.curr_line >= len(self.lines):
            return False
        line= self.lines[self.curr_line]
        for i in xrange(0,len(self.heading)):
            self[self.heading[i]]= line[i]
        return True
    def __str__(self):
        lst=["%s{" % "PatternBlock"]
        lst.extend(self._strlist())
        lst.append("}")
        return "\n".join(lst)

class BeginBlock(Block):
    """implements a ~begin .. ~end block.

    This block is simply a variable scope, so it is derived from Block where
    the constructor is called with new_scope=True.
    """
    def __init__(self,
                 previous= None,
                 filename= None):
        Block.__init__(self, previous, True)
        self.skip= previous.skip
    def __str__(self):
        lst=["%s{" % "BeginBlock"]
        lst.extend(self._strlist())
        lst.append("}")
        return "\n".join(lst)

class IfBlock(Block):
    """implements a ~if .. ~else .. ~endif block.

    An ~if block never has a variable scope, so the base Block object is
    called with new_scope=False.
    """
    def _strlist(self):
        lst= Block._strlist(self)
        self._append(lst, "prev_skip")
        self._append(lst, "in_else_part")
        self._append(lst, "found")
        return lst
    def __init__(self,
                 previous= None,
                 condition= True):
        """constructs the ~if block.

        condition is the boolean value of the ~if condition.
        """
        Block.__init__(self, previous, False)
        self.prev_skip= previous.skip
        self.in_else_part= False
        if condition:
            self.found= True
            self.skip= self.prev_skip
        else:
            self.found= False
            self.skip= True
    def enter_elif(self, condition):
        """enter the "elif" part in the if..endif block."""
        if self.found:
            self.skip= True
        else:
            if condition:
                self.found= True
                self.skip= self.prev_skip
            else:
                self.skip= True
    def enter_else(self):
        """this should be called when ~else is encountered.
        """
        if self.in_else_part:
            raise ParseException( \
                    self.posmsg("one \"else\" too many at"))
        self.in_else_part= True
        if not self.found:
            self.skip= self.prev_skip
        else:
            self.skip= True
    def __str__(self):
        lst=["%s{" % "IfBlock"]
        lst.extend(self._strlist())
        lst.append("}")
        return "\n".join(lst)

class ForBlock(Block):
    """implements a ~for .. ~endfor block.
    """
    def _strlist(self):
        lst= Block._strlist(self)
        self._append(lst, "value_list")
        self._append(lst, "index")
        self._append(lst, "var_expr")
        self._append(lst, "jump_lst_pos")
        self._append(lst, "jump parse elm",self.parse_list[self.jump_lst_pos])
        return lst
    def __init__(self,
                 previous= None,
                 new_scope= False,
                 value_list=None,
                 var_expr=""):
        """constructor of the block.

        var_expr -- the expression that contains the loop variable or the
                    tuple with the loop variables.
        """
        Block.__init__(self, previous, new_scope)
        if value_list is None:
            value_list= []
        self.value_list= value_list
        self.index=0 # current index within self.value_list
        self.var_expr= var_expr
        self.jump_lst_pos= self.lst_pos
        if len(value_list)<=0:
            self.skip= True
        else:
            self.skip= previous.skip
    def set_loop_var(self):
        """set the loop variable to a new value."""
        if not self.skip:
            self.__setitem__(self.var_expr, self.value_list[self.index])
    def next_loop(self):
        """performs next loop.

        returns:
          True when the loop is not yet finished.
        """
        if self.skip:
            return False
        self.index+=1
        do_loop= self.index< len(self.value_list)
        if do_loop:
            self.lst_pos= self.jump_lst_pos
        return do_loop
    def __str__(self):
        lst=["%s{" % "ForBlock"]
        lst.extend(self._strlist())
        lst.append("}")
        return "\n".join(lst)

class WhileBlock(Block):
    """implements a ~while .. ~endwhile block.
    """
    def _strlist(self):
        lst= Block._strlist(self)
        self._append(lst, "while_expr")
        self._append(lst, "jump parse elm",self.parse_list[self.jump_lst_pos])
        return lst
    def __init__(self,
                 previous= None,
                 new_scope= False,
                 while_expr=""):
        """constructor of the block.

        while_expr -- the expression that contains the loop variable or the
                      tuple with the loop variables.
        """
        Block.__init__(self, previous, new_scope)
        self.while_expr= while_expr
        self.jump_lst_pos= self.lst_pos
        if while_expr=="":
            self.skip= True
        elif not self.eval_(self.while_expr):
            self.skip= True
        else:
            self.skip= previous.skip
    def next_loop(self):
        """performs next loop.

        returns:
          True when the loop is not yet finished.
        """
        if self.skip:
            return False
        do_loop= self.eval_(self.while_expr)
        if do_loop:
            self.lst_pos= self.jump_lst_pos
        return do_loop
    def __str__(self):
        lst=["%s{" % "WhileBlock"]
        lst.extend(self._strlist())
        lst.append("}")
        return "\n".join(lst)

class MacBlock(Block):
    """implements a ~macro...~endmacro block.
    """
    def _strlist(self):
        lst= Block._strlist(self)
        self._append(lst, "parameter_list")
        self._append(lst, "is_declaration")
        return lst
    def __init__(self,
                 previous= None,
                 declaration_block= None,
                 parameter_list= None):
        """constructor of the block.

        parameter_list: list of parameters of the macro.
        """
        if declaration_block is None:
            # THIS is a macro declaration block
            Block.__init__(self, previous, new_scope= True)
            if parameter_list is None:
                parameter_list= []
            self.parameter_list= parameter_list
            self.is_declaration= True
            self.skip= True
        else:
            # THIS is a macro instantiation block
            Block.__init__(self, previous, new_scope= True)
            self.parse_list= declaration_block.parse_list
            self.parameter_list= declaration_block.parameter_list
            self.lst_pos= declaration_block.start_pos
            self.is_declaration= False
    def pop(self):
        """override pop() from base class.
        """
        if self.is_declaration:
            return Block.pop(self)
        old_pos= self.previous.lst_pos
        prev= Block.pop(self)
        prev.lst_pos= old_pos
        return prev
    def __str__(self):
        lst=["%s{" % "MacBlock"]
        lst.extend(self._strlist())
        lst.append("}")
        return "\n".join(lst)

def __pyexpander_helper(*args, **kwargs):
    """a helper function needed at runtime.

    This evaluates named arguments.
    """
    if len(args)==1:
        fn= args[0]
    elif len(args)>1:
        raise ValueError, "only one unnamed argument is allowed"
    else:
        fn= None
    return(fn, kwargs)

def __pyexpander_helper2(**kwargs):
    """a helper function needed at runtime.

    This evaluates named arguments.
    """
    return kwargs

def __pyexpander_helper3(*args, **kwargs):
    """a helper function needed at runtime.

    This evaluates unnamed and named arguments.
    """
    return (args,kwargs)

def processToList(parse_list, filename=None,
                  external_definitions=None,
                  allow_nobracket_vars= False,
                  auto_continuation= False,
                  auto_indent= False,
                  include_paths= None):
    """Expand a parse list to a list of strings.

    args:
        parse_list: A parse list created by parseString().

        filename (str): The filename, if given, is included in possible error
            messages.
        external_definitions (dict): A dict with items to import to the
            globals() dictionary.
        allow_nobracket_vars (bool): If True, allow variables in the form ~VAR
            instead of ~(VAR).
        auto_continuation (bool): If True, remove newline at the end of lines
            with a command. This works like having an '\' at the end of each
            line with a command.
        auto_indent (bool): If True, indent the contents of macros to the same
            level as the macro invocation.
        include_paths (list): A list of paths that are searched for the
            ~include command.

    returns a tuple containing:
        - The expanded text as a list of strings
        - The internal globals() dictionary.
    """
    # pylint: disable=too-many-arguments, too-many-locals, too-many-branches
    # pylint: disable=too-many-statements
    # accept None for include_paths too:
    if include_paths is None:
        include_paths= []
    # prepend the cwd to the list of search paths:
    include_paths.insert(0,"")
    # The initial block:
    my_external_definitions= { "__pyexpander_helper": \
                                 globals()["__pyexpander_helper"],
                               "__pyexpander_helper2": \
                                 globals()["__pyexpander_helper2"],
                               "__pyexpander_helper3": \
                                 globals()["__pyexpander_helper3"],
                             }
    if external_definitions is not None:
        my_external_definitions.update(external_definitions)
    # only needed for allow_nobracket_vars==True:
    # python keywords MUST NOT be checked. E.g. function __getitem__ would
    # raise an exception when called with "else" since eval("else") is a syntax
    # error.
    keyword_checks= PURE_CMD_KEYWORDS - PY_KEYWORDS
    block= Block(filename= filename, parse_list=parse_list,
                 external_definitions= my_external_definitions)
    result= ResultText()
    # needed for tp_last:
    tp= None
    # pylint: disable=too-many-nested-blocks
    while True:
        # print "-" * 40
        # block.print_block_list()
        if not block.parse_loop():
            # no more data in the current block:
            if isinstance(block, IncludeBlock):
                # if current block is an IncludeBlock, go back to previous
                # block:
                block= block.pop()
                continue
            elif isinstance(block, SubstBlock):
                # if current block is a SubstBlock, go back to previous block:
                block= block.pop()
                continue
            elif isinstance(block, PatternBlock):
                # if current block is a PatternBlock, go back to previous
                # block:
                block= block.pop()
                continue
            else:
                # end of data, leave the loop:
                break
        # get the current parse element (base class: ParsedItem)
        tp_last= tp
        tp= block.parse_elm()
        # print "POS %3d: " % block.lst_pos, "tp: ",str(tp)
        if isinstance(tp, ParsedComment):
            # comments are ignored:
            continue
        if isinstance(tp, ParsedLiteral):
            # literals are only taken if skip mode is off:
            if not block.skip:
                st_= tp.string()
                if auto_continuation and st_.startswith(os.linesep):
                    if isinstance(tp_last,
                                  (ParsedCommand, ParsedPureCommand)):
                        st_= st_[LINESEP_LEN:]
                # if current column is 1, we must do an initial indent:
                st_= block.format_text(st_, result.column()==1)
                result.append(st_)
            continue
        if isinstance(tp, ParsedVar):
            # if skip mode is off, insert the current value of the variable.
            # The current block can be used like a dict in order to get values
            # of variables:
            if not block.skip:
                result.append(str(block[tp.string()]))
            continue
        if isinstance(tp, ParsedEval):
            # if skip mode is off, evaluate the eval expression,
            # convert it to a string and insert the result:
            if block.safe_mode:
                raise ParseException( \
                        block.posmsg("~(EXPRESSION) not allowed with "
                                     "safemode", pos= tp.start()))
            if not block.skip:
                result.append(block.str_eval(tp.string()))
            continue
        if isinstance(tp, ParsedCommand):
            # if ParsedItem is a ParsedCommand:
            if tp.ident=="py":
                # ~py(...) :
                # execute the string given within the brackets:
                if block.safe_mode:
                    raise ParseException( \
                            block.posmsg("~py() not allowed with "
                                         "safemode", pos= tp.start()))
                if not block.skip:
                    block.exec_(tp.args())
            elif tp.ident=="include" or tp.ident=="include_begin":
                if not block.skip:
                    # ~include(...) or ~include_begin(...) :
                    # evaluate the filename of the file to include:
                    try:
                        (filename, encoding)= one_or_two_strings(\
                                                  block.eval_(tp.args()))
                        if encoding is None:
                            encoding= INPUT_DEFAULT_ENCODING
                        else:
                            # may raise LookupError:
                            test_encoding(encoding)
                    except (TypeError, LookupError) as e:
                        raise ParseException( \
                                block.posmsg(str(e), pos=tp.start()))
                    # create an instance of an IncludeBlock:
                    block= IncludeBlock(previous= block,
                                        new_scope= (tp.ident=="include_begin"),
                                        filename= filename,
                                        encoding= encoding,
                                        include_paths= include_paths)
            elif tp.ident=="template":
                if not block.skip:
                    # ~template(...) :
                    # evaluate the filename of substfile:
                    try:
                        (filename, encoding)= one_or_two_strings(\
                                                  block.eval_(tp.args()))
                        if encoding is None:
                            encoding= INPUT_DEFAULT_ENCODING
                        else:
                            # may raise LookupError:
                            test_encoding(encoding)
                    except (TypeError, LookupError) as e:
                        raise ParseException( \
                                block.posmsg(str(e), pos=tp.start()))
                    # remember this filename in the current block object:
                    block.set_substfile(filename, encoding, tp)
            elif tp.ident=="subst":
                if not block.skip:
                    # ~subst(...) :
                    # evaluate all the named arguments:
                    args= block.eval_("__pyexpander_helper2(%s)" % tp.args())
                    # create an instance of a SubstBlock:
                    block= SubstBlock(previous= block,
                                      filename= block.template,
                                      include_paths= include_paths,
                                      external_definitions= args)
            elif tp.ident=="pattern":
                if not block.skip:
                    # ~pattern(...) :
                    # create a tuple of all arguments:
                    args= block.eval_("(%s)" % tp.args())
                    block= PatternBlock(previous= block,
                                        filename= block.template,
                                        include_paths= include_paths,
                                        heading= args[0],
                                        lines= args[1:])
            elif tp.ident=="default":
                if not block.skip:
                    # ~default(...) :
                    # evaluate all the named arguments:
                    args= block.eval_("__pyexpander_helper2(%s)" % tp.args())
                    # set these defaults in the current block:
                    for (k,v) in args.items():
                        block.setdefault(k, v)
            elif tp.ident=="if":
                # ~if(...) :
                # evaluate the condition:
                if not block.skip:
                    condition= block.eval_(tp.args())
                else:
                    # fake a condition:
                    condition= True
                # create an instance of an IfBlock:
                block= IfBlock(previous= block,
                               condition= condition)
            elif tp.ident=="elif":
                # elif(...) :
                # current block must be an IfBlock:
                if not isinstance(block,IfBlock):
                    raise ParseException( \
                            block.posmsg("unmatched elif at", \
                                          pos=tp.start()))
                # evaluate the condition:
                if not block.prev_skip:
                    condition= block.eval_(tp.args())
                else:
                    # fake a condition:
                    condition= False
                # enter the "elif" part of the if block by
                # calling enter_elif:
                block.enter_elif(condition)
            elif tp.ident=="for" or tp.ident=="for_begin":
                # ~for(...) or ~for_begin(...) :
                # assume the the parameters form a valid list comprehension
                try:
                    # try to parse the arguments of ~for():
                    for_parts= scanPyIn(tp.args())
                except ParseException,_:
                    raise ParseException( \
                            block.posmsg("error in %s command at" % tp.ident, \
                                         pos= tp.start()))
                # create a list of loop items by using pythons
                # list comprehension mechanism:
                if not block.skip:
                    for_list= block.eval_("list(%s)" % for_parts[2])
                else:
                    for_list= []
                # create an instance of a ForBlock:
                block= ForBlock(previous= block,
                                new_scope= (tp.ident=="for_begin"),
                                value_list= for_list,
                                var_expr= for_parts[0])
                block.set_loop_var()
            elif tp.ident=="while" or tp.ident=="while_begin":
                # ~while(...) or ~while_begin(...) :
                # create an instance of a WhileBlock:
                if not block.skip:
                    expr= tp.args()
                else:
                    expr= ""
                block= WhileBlock(previous= block,
                                  new_scope= (tp.ident=="while_begin"),
                                  while_expr= expr)
            elif tp.ident=="macro":
                # ~macro(...)
                try:
                    # try to parse the arguments of ~macro():
                    identifiers= scanPyIdentList(tp.args())
                except ParseException,_:
                    raise ParseException( \
                          block.posmsg("error in \"macro\" command at", \
                                       pos= tp.start()))
                if len(identifiers)<=0:
                    raise ParseException( \
                          block.posmsg("error in \"macro\" command at", \
                                       pos= tp.start()))
                e= None
                try:
                    keyword_check(identifiers[0:1])
                except ValueError, _e:
                    e= _e
                if e is not None:
                    raise ParseException( \
                          block.posmsg(("error in \"macro\" command, "
                                        "%s at") % e, \
                                       pos= tp.start()))
                block= MacBlock(previous= block,
                                parameter_list= identifiers[1:])
                block.previous.add_macro(identifiers[0], block)
            elif tp.ident=="nonlocal":
                if not block.skip:
                    # ~nonlocal(...) :
                    try:
                        # try to parse the arguments of ~nonlocal():
                        identifiers= scanPyIdentList(tp.args())
                    except ParseException,_:
                        raise ParseException( \
                              block.posmsg("error in \"nonlocal\" command at", \
                                           pos= tp.start()))
                    # mark them in the current block as exported symbols:
                    block.export_symbols(identifiers)
            elif tp.ident=="extend" or tp.ident=="extend_expr":
                if block.safe_mode:
                    raise ParseException( \
                            block.posmsg(("~%s not allowed with "
                                          "safemode") % tp.ident,
                                         pos= tp.start()))
                if not block.skip:
                    if tp.ident=="extend_expr":
                        # ~extend_expr(...) :
                        expr_= block.eval_(tp.args())
                        e= None
                        try:
                            identifiers= [str(elm) for elm in expr_]
                        except TypeError, _e:
                            e= _e
                        if e is not None:
                            raise TypeError, "%s at %s" % \
                                             (str(e), block.posmsg())
                    else:
                        # ~extend(...) :
                        try:
                            # try to parse the arguments of ~extend():
                            identifiers= scanPyIdentList(tp.args())
                        except ParseException,_:
                            raise ParseException( \
                                  block.posmsg("error in \"extend\" command at", \
                                               pos= tp.start()))
                    e= None
                    try:
                        keyword_check(identifiers)
                    except ValueError, _e:
                        e= _e
                    if e is not None:
                        raise ParseException( \
                              block.posmsg(("error in \"extend\" command, "
                                            "%s at") % e, \
                                           pos= tp.start()))
                    # mark them in the current block as "extended" identifiers:
                    block.extend(identifiers)
            elif tp.ident in block.direct_funcs:
                if not block.skip:
                    # ~user-function-extended(...)
                    # apply the function directly:
                    result.append(block.str_eval("%s(%s)" % \
                                  (tp.ident,tp.args())))
            elif block.macros.has_key(tp.ident):
                if not block.skip:
                    # ~macro(args)
                    block= MacBlock(previous= block,
                                    declaration_block= block.macros[tp.ident],
                                    parameter_list= identifiers[1:])
                    if auto_indent:
                        # column of the '~' sign:
                        col_= tp.rowcol()[1]-len(tp.ident)-2
                        block.set_indent(block.get_indent()+(col_-1))
                    (args,kwargs)= block.eval_("__pyexpander_helper3(%s)" % \
                                               tp.args())
                    if len(args)>len(block.parameter_list):
                        raise ParseException( \
                                block.posmsg(("too many parameters at "
                                              "instantiation of macro "
                                              "\"%s\" at") % tp.ident,
                                             pos= tp.start()))
                    for (i,name) in enumerate(block.parameter_list):
                        if i<len(args):
                            # unnamed parameter
                            if kwargs.has_key(name):
                                raise ParseException( \
                                        block.posmsg(("multiple values for "
                                                      "keyword argument "
                                                      "\"%s\" in macro "
                                                      "\"%s\" at") % \
                                                     (name, tp.ident),
                                                     pos= tp.start()))
                            block.__setitem__(name, args[i])
                            continue
                        if not kwargs.has_key(name):
                            raise ParseException( \
                                    block.posmsg(("no value for argument "
                                                  "\"%s\" in macro \"%s\" "
                                                  "at") % \
                                                 (name, tp.ident),
                                                 pos= tp.start()))
                        block.__setitem__(name, kwargs[name])
            else:
                # everything else is a ParseException, this shouldn't happen
                # since all ParsedItem objects that the expanderparser can
                # create should be handled here.
                raise ParseException( \
                        block.posmsg("unknown command \"%s\" at" % tp.ident, \
                                      pos= tp.start()))
            continue
        if isinstance(tp, ParsedPureCommand):
            # a "pure" command, a command without arguments:
            ident= tp.string()
            if allow_nobracket_vars and (ident in keyword_checks):
                # an extra check for keyword conflicts
                do_warn= False
                try:
                    block.__getitem__(ident)
                    do_warn= True
                except NameError, _:
                    pass
                if do_warn:
                    sys.stderr.write(block.posmsg(("warning, variable '%s' "
                                                   "shadowed by pyexpander "
                                                   "keyword (This warning "
                                                   "only printed once per "
                                                   "keyword) at" % ident),
                                                  pos= tp.start())+"\n")
                    keyword_checks.remove(ident)
            if ident=="safemode":
                block.set_safemode(True)
            elif ident=="else":
                # ~else :
                # current block must be an IfBlock:
                if not isinstance(block,IfBlock):
                    raise ParseException( \
                            block.posmsg("unmatched else at", \
                                          pos= tp.start()))
                # enter the "else" part of the if block by
                # calling enter_else:
                block.enter_else()
            elif ident=="endif":
                # ~endif
                # current block must be an IfBlock:
                if not isinstance(block,IfBlock):
                    raise ParseException( \
                            block.posmsg("unmatched endif at", \
                                          pos= tp.start()))
                # go back to previous block:
                block= block.pop()
            elif ident=="endfor":
                # ~endfor
                # current block must be a ForBlock:
                if not isinstance(block,ForBlock):
                    raise ParseException( \
                            block.posmsg("unmatched endfor at", \
                                          pos= tp.start()))
                # test if we have to perform the loop block again:
                if not block.next_loop():
                    # no further loops, go back to the previous block:
                    block= block.pop()
                else:
                    # further loops, give the loop variable a new value:
                    block.set_loop_var()
            elif ident=="endwhile":
                # ~endwhile
                # current block must be a WhileBlock:
                if not isinstance(block,WhileBlock):
                    raise ParseException( \
                            block.posmsg("unmatched endwhile at", \
                                          pos= tp.start()))
                # test if we have to loop again. next_loop also resets
                # the position, if we have to loop again:
                if not block.next_loop():
                    # if loop condition is False, go back to previous block,
                    block= block.pop()
            elif ident=="endmacro":
                # ~endmacro
                # current block must be a MacBlock:
                if not isinstance(block,MacBlock):
                    raise ParseException( \
                            block.posmsg("unmatched endmacro at", \
                                          pos= tp.start()))
                block= block.pop()
            elif ident=="begin":
                # ~begin
                # create an instance of a BeginBlock:
                block= BeginBlock(previous= block)
            elif ident=="end":
                # ~end
                # current block must be a BeginBlock:
                if not isinstance(block,BeginBlock):
                    raise ParseException( \
                            block.posmsg("unmatched end at", \
                                          pos= tp.start()))
                # go back to previous block:
                block= block.pop()
            elif ident in block.direct_vars:
                # ~user-variable-extended
                # if skip mode is off, insert the current value of the
                # variable. The current block can be used like a dict in order
                # to get values of variables:
                if not block.skip:
                    result.append(str(block.__getitem__(ident)))
            else:
                # if we are not in nobracket_vars mode, we have an
                # unknown command without arguments here:
                if not allow_nobracket_vars:
                    raise ParseException( \
                            block.posmsg("unknown command \"%s\" at" % ident, \
                                          pos= tp.start()))
                else:
                    # if skip mode is off, insert the current value of the
                    # variable. The current block can be used like a dict in
                    # order to get values of variables:
                    if not block.skip:
                        result.append(str(block.__getitem__(ident)))
            continue
    if block.previous is not None:
        raise ParseException(block.posmsg("unclosed block at"))
    return (result.list_(),block.globals_)

def processToPrint(parse_list, filename=None,
                   external_definitions=None,
                   allow_nobracket_vars= False,
                   auto_continuation= False,
                   auto_indent= False,
                   include_paths=None,
                   output_encoding=SYS_DEFAULT_ENCODING):
    """Gets a parse list, expand the text in it and print it.

    args:
        parse_list: A parse list created by parseString().

        filename (str): The filename, if given, is included in possible error
            messages.
        external_definitions (dict): A dict with items to import to the
            globals() dictionary.
        allow_nobracket_vars (bool): If True, allow variables in the form ~VAR
            instead of ~(VAR).
        auto_continuation (bool): If True, remove newline at the end of lines
            with a command. This works like having an '\' at the end of each
            line with a command.
        auto_indent (bool): If True, indent the contents of macros to the same
            level as the macro invocation.
        include_paths (list): A list of paths that are searched for the
            ~include command.
        output_encoding: encoding used to create output data

    returns:
        The internal globals() dictionary.
    """
    # pylint: disable=too-many-arguments
    # debug:
    # for elm in parse_list:
    #     print elm
    (result,exp_globals)= processToList(parse_list, filename,
                                        external_definitions,
                                        allow_nobracket_vars,
                                        auto_continuation,
                                        auto_indent,
                                        include_paths)
    if output_encoding==SYS_DEFAULT_ENCODING:
        print "".join(result),
    else:
        sys.stdout.write(codecs.decode("".join(result),\
                                   INTERNAL_ENCODING).encode(output_encoding))
    return exp_globals

def expandToStr(st, filename=None,
                external_definitions=None,
                allow_nobracket_vars= False,
                auto_continuation= False,
                auto_indent= False,
                include_paths=None):
    """Get a string, expand the text in it and return it as a string.

    args:
        st (str): The string that is to be expaned.

        filename (str): The filename, if given, is included in possible error
            messages.
        external_definitions (dict): A dict with items to import to the
            globals() dictionary.
        allow_nobracket_vars (bool): If True, allow variables in the form ~VAR
            instead of ~(VAR).
        auto_continuation (bool): If True, remove newline at the end of lines
            with a command. This works like having an '\' at the end of each
            line with a command.
        auto_indent (bool): If True, indent the contents of macros to the same
            level as the macro invocation.
        include_paths (list): A list of paths that are searched for the
            ~include command.

    returns a tuple containing:
        - The expanded text as a single string.
        - The internal globals() dictionary.
    """
    # pylint: disable=too-many-arguments
    (result,exp_globals)= processToList(parseString(st), filename,
                                        external_definitions,
                                        allow_nobracket_vars,
                                        auto_continuation,
                                        auto_indent,
                                        include_paths)
    return ("".join(result), exp_globals)

def expand(st, filename=None,
           external_definitions=None,
           allow_nobracket_vars= False,
           auto_continuation= False,
           auto_indent= False,
           include_paths=None,
           output_encoding=SYS_DEFAULT_ENCODING):
    """Get a string, expand the text in it and print it.

    args:
        st (str): The string that is to be expaned.

        filename (str): The filename, if given, is included in possible error
            messages.
        external_definitions (dict): A dict with items to import to the
            globals() dictionary.
        allow_nobracket_vars (bool): If True, allow variables in the form ~VAR
            instead of ~(VAR).
        auto_continuation (bool): If True, remove newline at the end of lines
            with a command. This works like having an '\' at the end of each
            line with a command.
        auto_indent (bool): If True, indent the contents of macros to the same
            level as the macro invocation.
        include_paths (list): A list of paths that are searched for the
            ~include command.
        output_encoding: encoding used to create output data

    returns:
        The internal globals() dictionary.
    """
    # pylint: disable=too-many-arguments
    return processToPrint(parseString(st), filename,
                          external_definitions,
                          allow_nobracket_vars,
                          auto_continuation,
                          auto_indent,
                          include_paths,
                          output_encoding)

def expandFile(filename,
               encoding= SYS_DEFAULT_ENCODING,
               external_definitions=None,
               allow_nobracket_vars= False,
               auto_continuation= False,
               auto_indent= False,
               include_paths=None,
               no_stdin_warning= False,
               output_encoding=SYS_DEFAULT_ENCODING):
    """Get a filename, expand the text in it and print it.

    args:
        filename (str): The name of the file
        encoding: encoding of the file

        external_definitions (dict): A dict with items to import to the
            globals() dictionary.
        allow_nobracket_vars (bool): If True, allow variables in the form ~VAR
            instead of ~(VAR).
        auto_continuation (bool): If True, remove newline at the end of
            lines with a command. This works like having an '\' at the end of
            each line with a command.
        auto_indent (bool): If True, indent the contents of macros to
            the same level as the macro invocation.
        include_paths (list): A list of paths that are searched for the
            ~include command.
        no_stdin_warning (bool): If True, print short message on stderr
            when the program is waiting on input from stdin.
        output_encoding: encoding used to create output data

    returns:
        The internal globals() dictionary.
    """
    # pylint: disable=too-many-arguments
    return processToPrint(parseFile(filename, encoding, no_stdin_warning),
                          filename,
                          external_definitions,
                          allow_nobracket_vars,
                          auto_continuation,
                          auto_indent,
                          include_paths,
                          output_encoding)

def lib_test():
    """perform the doctest tests."""
    import doctest
    print "testing..."
    doctest.testmod()
    print "done"

if __name__ == "__main__":

# imported from pyexpander 1.10.2 python2/bin/expander2.py

    """expander.py: this is the pyexpander application.
    """
# pylint: disable=C0322,C0103,R0903

    from optparse import OptionParser
    #import string
    import os.path
    import sys

    def check_encoding(encoding):
        """check if the encoding name is valid."""
        try:
            test_encoding(encoding)
            return
        except LookupError:
            pass
        url="https://docs.python.org/3/library/codecs.html#standard-encodings"
        sys.exit(("unknown encoding name: %s, see %s for a "
                  "list of known encodings") % (repr(encoding), repr(url)))

    def process_files(options,args):
        """process all the command line options."""
        my_globals={}
        global INPUT_DEFAULT_ENCODING
        global SYS_DEFAULT_ENCODING
        if options.eval is not None:
            for expr in options.eval:
                # pylint: disable=W0122
                exec expr in my_globals
                # pylint: enable=W0122
        filelist= []
        if options.file is not None:
            filelist= options.file
        if len(args)>0: # extra arguments
            filelist.extend(args)
        encoding= INPUT_DEFAULT_ENCODING
        if options.encoding:
            check_encoding(options.encoding) # may exit the program
            encoding= options.encoding
            INPUT_DEFAULT_ENCODING= options.encoding
        output_encoding= SYS_DEFAULT_ENCODING
        if options.output_encoding:
            check_encoding(options.output_encoding) # may exit the program
            output_encoding= options.output_encoding
        if len(filelist)<=0:
            expandFile(None,
                                  encoding,
                                  my_globals,
                                  options.simple_vars,
                                  options.auto_continuation,
                                  options.auto_indent,
                                  options.include,
                                  options.no_stdin_msg,
                                  output_encoding)
        else:
            for f in filelist:
                # all files are expanded in a single scope:
                my_globals= \
                    expandFile(f,
                                          encoding,
                                          my_globals,
                                          options.simple_vars,
                                          options.auto_continuation,
                                          options.auto_indent,
                                          options.include,
                                          False,
                                          output_encoding)

    def script_shortname():
        """return the name of this script without a path component."""
        return os.path.basename(sys.argv[0])

    def print_summary():
        """print a short summary of the scripts function."""
        print ("%-20s: a powerful macro expension language "+\
               "based on python ...\n") % script_shortname()

    def main():
        """The main function.

        parse the command-line options and perform the command
        """
        # command-line options and command-line help:
        usage = "usage: %prog [options] {files}"

        parser = OptionParser(usage=usage,
                              version="%%prog %s" % __version__,
                              description="expands macros in a file "+\
                                          "with pyexpander.")

        parser.add_option("--summary",
                          action="store_true",
                          help="Print a summary of the function of the program.",
                         )
        parser.add_option("-f", "--file",
                          action="append",
                          type="string",
                          help="Specify a FILE to process. This "
                               "option may be used more than once "
                               "to process more than one file but note "
                               "than this option is not really needed. "
                               "Files can also be specified directly after "
                               "the other command line options. If not given, "
                               "the program gets it's input from stdin.",
                          metavar="FILE"
                         )
        parser.add_option("--encoding",
                          action="store",
                          type="string",
                          help="Specify the ENCODING for the file(s) "
                               "that are read.",
                          metavar="ENCODING"
                         )
        parser.add_option("--output-encoding",
                          action="store",
                          type="string",
                          help="Specify the OUTPUTENCODING for the "
                               "created output.",
                          metavar="OUTPUTENCODING"
                         )

        parser.add_option("--eval",
                          action="append",
                          type="string",
                          help="Evaluate PYTHONEXPRESSION in global context.",
                          metavar="PYTHONEXPRESSION"
                         )
        parser.add_option("-I", "--include",
                          action="append",
                          type="string",
                          help="Add PATH to the list of include paths.",
                          metavar="PATH"
                         )
        parser.add_option("-s", "--simple-vars",
                          action="store_true",
                          help="Allow variables without brackets.",
                         )
        parser.add_option("-a", "--auto-continuation",
                          action="store_true",
                          help="Assume '\' at the end of lines with commands",
                         )
        parser.add_option("-i", "--auto-indent",
                          action="store_true",
                          help="Automatically indent macros.",
                         )
        parser.add_option("--no-stdin-msg",
                          action="store_true",
                          help= "Do not print a message on stderr when the "
                                "program is reading it's input from stdin."
                         )

        # x= sys.argv
        (options, args) = parser.parse_args()
        # options: the options-object
        # args: list of left-over args

        if options.summary:
            print_summary()
            sys.exit(0)

        process_files(options,args)
        sys.exit(0)

    main()
