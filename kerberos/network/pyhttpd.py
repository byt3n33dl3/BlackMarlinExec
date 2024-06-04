#!/usr/bin/env python2

# httpsrv library routines for python.
# Copyright (C) 2018-2022 rofl0r

# This library is free software; you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public
# License as published by the Free Software Foundation; either
# version 2.1 of the License, or (at your option) any later version.

# This library is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Lesser General Public License for more details.

# You should have received a copy of the GNU Lesser General Public
# License along with this library; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA

# you can find the full license text at
# https://www.gnu.org/licenses/old-licenses/lgpl-2.1.en.html

import socket, urllib, sys, os, errno

preprocess_file = None

def init_expander():
	try:
		import pyexpander
	except ImportError:
		sys.path.insert(1, os.path.dirname(os.path.realpath(__file__)))
		import pyexpander
	def preprocess_file_expander(fn):
		with open(fn, "r") as h:
			txt, glObals = pyexpander.expandToStr(h.read(), fn, include_paths=[os.path.dirname(fn)])
			return txt
	global preprocess_file
	preprocess_file = preprocess_file_expander


# buffered socket class allows to do readline() etc, without having
# to resort to reading 1 byte at a time with huge syscall overhead.
# use read() instead of recv() to make use of it.
class BufferedSocket(socket.socket):
	def __init__(self, family=socket.AF_INET, type=socket.SOCK_STREAM, proto=0, _sock=None):
		self.buffer = ''
		if not _sock:
			super(BufferedSocket, self).__init__(family, type, proto, _sock)
		else:
			super(BufferedSocket, self).__init__(_sock=_sock)
	def accept(self):
		sock, addr = super(BufferedSocket, self).accept()
		return BufferedSocket(_sock=sock), addr
	def read(self, bufsize, flags=0):
		if len(self.buffer):
			s = self.buffer[:bufsize]
			self.buffer = self.buffer[bufsize:]
			return s
		return self.recv(bufsize, flags)
	def readuntil(self, marker, exclude_marker=False, maxbytes=-1):
		p = self.buffer.find(marker)
		if p != -1:
			if not exclude_marker:
				p += len(marker)
			s = self.buffer[:p]
			self.buffer = self.buffer[p:]
			return s
		elif maxbytes != -1 and len(self.buffer) >= maxbytes:
			# in case marker is not found within maxbytes
			# (or conn was reset), return empty result,
			# as a partial result would be unexpected
			return ''
		while self.buffer.find(marker) == -1:
			s = self.recv(4096)
			self.buffer += s
			if s == '' or (maxbytes != -1 and len(self.buffer) >= maxbytes):
				maxbytes = len(self.buffer)
				break
		return self.readuntil(marker, exclude_marker, maxbytes)
	def readline(self, exclude_marker=False, maxbytes=-1):
		return self.readuntil('\n', exclude_marker, maxbytes)

def _format_addr(addr):
        ip, port = addr
        return "%s:%d"%(ip, port)

def _isnumericipv4(ip):
	try:
		a,b,c,d = ip.split('.')
		if int(a) < 256 and int(b) < 256 and int(c) < 256 and int(d) < 256:
			return True
		return False
	except:
		return False

def _resolve(host, port, want_v4=True):
	if _isnumericipv4(host):
		return socket.AF_INET, (host, port)
	for res in socket.getaddrinfo(host, port, \
			socket.AF_UNSPEC, socket.SOCK_STREAM, 0, socket.AI_PASSIVE):
		af, socktype, proto, canonname, sa = res
		if want_v4 and af != socket.AF_INET: continue
		if af != socket.AF_INET and af != socket.AF_INET6: continue
		else: return af, sa
	return None, None

def _parse_req(line):
	line = line.strip()
	r = line.find(' ')
	if r == -1:
		return '', '', ''
	method = line[:r]
	rest = line[r+1:]
	r = rest.find(' ')
	if r == -1:
		return method, '', ''
	else:
		ver = rest[r+1:]
		url = rest[:r]
		return method, url, ver

# turns lines in the form of key:value into a dict with lowercase keys.
# lines not containing ':' are discarded from the result
# separator may be of length 1
def _parse_to_dict(s, sep=':'):
	def next_line(s):
		start = 0
		while start < len(s):
			end = s.find('\n', start)
			if end == -1: end = len(s) +1
			subs = s[start:end]
			start = end + 1
			yield subs
	result = {}
	for line in next_line(s):
		p = line.find(sep)
		if p > 0:
			result[line[:p].lower()] = line[p+1:].strip()
	return result

ERROR_DICT = {
	400: 'Bad Request',
	401: 'Unauthorized',
	403: 'Forbidden',
	404: 'Not Found',
	405: 'Method Not Allowed',
	416: 'Range Not Satisfiable',
	500: 'Internal Server Error',
	501: 'Not Implemented',
	503: 'Service Unavailable',
	505: 'HTTP Version Not Supported',
	507: 'Insufficient Storage',
}

CONTENT_TYPE_DICT = {
	'.html' : 'text/html',
	'.txt' : 'text/plain',
	'.gif' : 'image/gif',
	'.png' : 'image/png',
	'.jpg' : 'image/jpeg',
	'.jpeg' : 'image/jpeg',
}

def _get_content_type(filename):
	_, ext = os.path.splitext(filename)
	if ext in CONTENT_TYPE_DICT: return CONTENT_TYPE_DICT[ext]
	return ''

class HttpClient():
	def __init__(self, addr, conn, root):
		self.addr = addr
		self.conn = conn
		self.root = root
		self.active = True
		self.keep_alive = True
		self.debugreq = False

	def _send_i(self, data):
		try: self.conn.send(data)
		except: return False
		if self.debugreq and len(data): print(">>>\n", data)
		return True

	def send_header(self, code, msg, response_len, headers=None):
		h = '' if not headers else "".join("%s: %s\r\n"%(x, headers[x]) for x in headers)
		r = "HTTP/1.1 %d %s\r\n%sContent-Length: %d\r\n\r\n"%(code, msg, h, response_len)
		return self._send_i(r)

	def send(self, code, msg, response, headers=None):
		if not self.send_header(code, msg, len(response), headers):
			return False
		return self._send_i(response)

	def send_error(self, code, text=None):
		if not code in ERROR_DICT: code = 500
		msg = ERROR_DICT[code]
		if text is None: text = "error %d: %s\r\n"%(code, msg)
		self.send(code, msg, text)
		return None

	def serve_file(self, filename, start=0):
		st = os.stat(filename)
		sz = st.st_size
		sent = 0
		headers = {}
		ct = _get_content_type(filename)
		if ct != '': headers['Content-Type'] = ct
		if start == 0:
			self.send_header(200, "OK", sz-start, headers)
		elif start >= sz:
			return self.send_error(416)
		else:
			headers["Content-Range"] = "bytes %d-%d/%d"%(start, sz-1, sz)
			self.send_header(206, "Partial Content", sz-start, headers)

		with open(filename, 'r') as h:
			h.seek(start)
			while sent < sz-start:
				chunk = h.read(16384)
				try: self.conn.send(chunk)
				except:
					self.disconnect()
					break
				sent += len(chunk)

	def redirect(self, url, headers=None):
		h = dict() if not headers else headers.copy()
		h['Location'] = url
		self.send(301, "Moved Permanently", "", headers=h)

	def _url_decode(self, s): return urllib.unquote_plus(s)

	def read_request(self):
		try: s = self.conn.readline(maxbytes=4096)
		# don't return a HTTP error message yet, as this might not
		# even be a valid HTTP request.
		except socket.error as e: return None
		if s == '': return None
		if self.debugreq: print("<<<\n", s.strip())

		meth, url, ver = _parse_req(s)
		if not ver.startswith('HTTP/'): return self.send_error(400)
		elif not ver in ["HTTP/1.1", "HTTP/1.0"]: return self.send_error(505)
		elif not meth in ['GET', 'POST']:
			return self.send_error(405)

		try: s = self.conn.readuntil('\r\n\r\n', maxbytes=16384)
		except: return self.send_error(400)
		# except socket.error as e:
		# if e.errno == errno.ECONNRESET: pass
		if s == '': return self.send_error(400)
		if self.debugreq: print(s.strip())

		headers = _parse_to_dict(s)
		result = {}
		result['method'] = meth
		result['url'] = self._url_decode(url)
		result['headers'] = headers
		try:
			range = result['headers']['range']
			if range.lower().startswith('bytes='):
				range = range.split('=')[1].strip()
				if range[0] != '-' and range.endswith('-'):
					result['range'] = int(range[:-1])
		except: pass
		if not 'range' in result: result['range'] = 0
		try: cl = int(result['headers']['content-length'])
		except: cl = 0
		ct = result['headers']['content-type'] if 'content-type' in result['headers'] else ''
		result['getdata'] = {}
		if meth == 'GET' or (meth == 'POST' and ct in ('application/x-www-form-urlencoded', 'text/plain')):
			s = ''
			while len(s) < cl:
				try: r = self.conn.read(cl-len(s))
				except: return self.send_error(400)
				if r == '': return self.send_error(400)
				s += r
			if cl and self.debugreq: print(s.strip())
			if meth == 'POST':
				if ct in ('application/x-www-form-urlencoded', 'text/plain'):
					postdata = _parse_to_dict(s, '=')
					if ct == 'application/x-www-form-urlencoded':
						for k in postdata.keys():
							postdata[k] = self._url_decode(postdata[k])
					result['postdata'] = postdata
			# we leave the onus to parse multipart/formdata to
			# the client script, as it involves reading a potentially
			# huge file, which could easily be abused to DOS the
			# service. the client script should extract
			# content-length header and use client.conn.read*() to
			# extract the parts it is interested in.
				elif not ct == 'multipart/formdata':
					return self.send_error(400, "unknown content-type")
			elif meth == 'GET' and '?' in result['url']:
				p = result['url'].find('?')
				getdata = _parse_to_dict(result['url'][p+1:].replace('&', '\n'), '=')
				result['getdata'] = getdata
				result['url'] = result['url'][:p]
		return result

	def disconnect(self):
		if self.active: self.conn.close()
		self.conn = None
		self.active = False
		self.keep_alive = False
		return None

class HttpSrv():
	def __init__(self, listenip, port, root):
		self.port = port
		self.listenip = listenip
		self.root = root
		self.s = None

	def setup(self):
		af, sa = _resolve(self.listenip, self.port)
		s = BufferedSocket(af, socket.SOCK_STREAM)
		s.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
		s.bind((sa[0], sa[1]))
		s.listen(128)
		self.s = s

	def wait_client(self):
		conn, addr = self.s.accept()
		c = HttpClient(addr, conn, self.root)
		return c

def forbidden_page():
	return (
		'<!DOCTYPE html>\n'
		'  <head>\n'
		'    <style>div.e{position:fixed;top:25%;bottom:25%;left:25%;right:25%;font-size:150px;text-align:center;}</style>\n'
		'    <title>Forbidden</title>\n'
		'  </head>\n'
		'  <body>\n'
		'    <div class="e">&#128405;</div>\n'
		'  </body>\n'
		'</html>')

sort_script = ''
def directory_listing(dir, root):
	import time, stat
	def format_filename(f):
		def utf8len(s):
			i = 0 ; l = 0
			while i < len(s):
				if not ord(s[i]) & 0x80: l += 1
				elif ord(s[i]) & 0xc0 == 0xc0: l+=1
				i += 1
			return l
		maxlen = 80
		if len(f) <= maxlen or utf8len(f) <= maxlen: return f
		splitpos = maxlen/2
		# avoid splitting utf-8 characters in the middle
		p = splitpos
		while p < splitpos+5 and ((ord(f[p]) & 0xc0) == 0x80): p += 1
		q = (maxlen-3)-p
		while q > 15 and ((ord(f[-q]) & 0xc0) == 0x80): q -= 1
		return '%s...%s'%(f[:p], f[-(q):])
	def format_date(ct):
		return time.strftime('%Y-%m-%d %H:%M:%S', time.gmtime(ct))
	def format_size(sz):
		i = 0; r = 0
		while 1:
			if sz / 1024 == 0: break
			i += 1 ; r = sz % 1024 ; sz /= 1024
		if i == 0: return '%d B'%sz
		return '%d.%d %s'%(sz, int((r/1024.0)*10), 'BKMGTPEZY'[i])
	def host_to_server(filename):
		return filename.replace(root+os.path.sep, '/', 1)
	def dir_entry(f):
		lf = os.path.join(dir, f)
		q = urllib.quote(host_to_server(lf), '/')
		st = os.stat(lf)
		d = stat.S_ISDIR(st.st_mode)
		if d: q += '/'
		return '<tr><td class="n"><a href="%s">%s</a>%s</td><td class="m">%s</td><td class="s">%s</td><td class="t">%s</td></tr>\n'% \
			(q,format_filename(f),"/" if d else "", format_date(st.st_mtime),'-  ' if d else format_size(st.st_size),'Directory' if d else 'File')

	h = (	'<!DOCTYPE html>\n<html>\n <head><meta charset="utf-8"/>\n'
		'<style>\n'
		'a, a:active {text-decoration: none; color: blue;}\n'
		'a:visited {color: #48468F;}\n'
		'a:hover, a:focus {text-decoration: underline; color: red;}\n'
		'body {background-color: #F5F5F5;}\nh2 {margin-bottom: 12px;}\n'
		'table {margin-left: 12px;}\n'
		'th, td { font: 90%% monospace; text-align: left;}\n'
		'th { font-weight: bold; padding-right: 14px; padding-bottom: 3px;}\n'
		'td {padding-right: 14px;}\ntd.s, th.s {text-align: right;}\n'
		'div.list { background-color: white; border-top: 1px solid #646464; border-bottom: 1px solid #646464; padding-top: 10px; padding-bottom: 14px;}\n'
		'div.foot { font: 90%% monospace; color: #787878; padding-top: 4px;}\n'
		'</style><title>Index of %s</title></head><body>\n<h2>Index of %s</h2>\n'
		'<div class="list"><table summary="Directory Listing" cellpadding="0" cellspacing="0">'
		'<thead><tr><th class="n">Name</th><th class="m">Last Modified</th><th class="s">Size</th><th class="t">Type</th></tr></thead>\n'
		'<tbody><tr><td class="n"><a href="../">Parent Directory</a>/</td><td class="m"> </td><td class="s">-  </td><td class="t">Directory</td></tr>\n'
		%(host_to_server(dir), host_to_server(dir)))
	f = '</tbody></table></div><div class="foot">pyhttpd</div>%s</body></html>'%sort_script
	try:
		return "%s%s%s"%(h, ''.join(dir_entry(x) for x in os.listdir(dir)), f)
	except OSError:
		# FIXME parse Errno and return error code, i.e. 403 for EPERM ?
		return None

def sec_check(fs, root):
	rp = os.path.normpath(fs)
	return rp == root or rp.startswith(root + os.path.sep)

auth_list = None
def check_authed(auth_str):
	if not auth_list: return True
	if not auth_str.lower().startswith('basic '): return False
	return auth_str[6:] in auth_list

HTML_HEADER = {'Content-Type': 'text/html'}
def http_client_thread(c, evt_done):
	root = c.root
	while c.keep_alive and c.active:
		req = c.read_request()
		if req is None: break
		if auth_list:
			if not 'authorization' in req['headers'] or not check_authed(req['headers']['authorization']):
				c.send(401, 'Unauthorized', '', {'WWW-Authenticate':'Basic realm="login required"'})
				break
		if req['method'] != 'GET':
			# our built-in client loop supports only 'GET'
			c.send_error(405)
			break
		elif len(req['url']) and req['url'][0] != '/':
			c.send_error(400)
			break
		fn = req['url'].find('?')
		if fn != -1: fn = req['url'][:fn]
		else: fn = req['url']
		fs = root + fn
		if not sec_check(fs, root):
			c.send_error(403, forbidden_page())
			break
		if os.path.isdir(fs):
			if not fn.endswith('/'):
				c.redirect(fn + '/')
				continue
			if os.path.exists(os.path.join(fs, 'index.html')):
				c.redirect(os.path.join(fn, 'index.html'))
			else:
				dl = directory_listing(fs, root)
				if dl is not None:
					c.send(200, "OK", dl, HTML_HEADER)
				else:
					c.send_error(403)
		elif os.path.exists(fs) and preprocess_file and fs.endswith('.html'):
			s = preprocess_file(fs)
			c.send(200, "OK", s, HTML_HEADER)
		elif os.path.exists(fs):
			c.serve_file(fs, req['range'])
		elif req['url'] == '/robots.txt':
			c.send(200, "OK", "User-agent: *\nDisallow: /\n")
		else:
			c.send_error(404)
	c.disconnect()
	evt_done.set()

def read_auth(fn):
	if fn == '-':
		print('enter username:password (separated with ":")')
		f = sys.stdin
	else: f = open(fn, "r")
	s = f.readline().strip()
	if not ':' in s:
		sys.stderr.write("authstring needs to look like user:pass\n")
		sys.exit(1)
	import base64
	global auth_list
	auth_list = []
	auth_list.append(base64.b64encode(s))
	if f != sys.stdin: f.close()

def usage():
	sys.stderr.write(
		'pyhttpd (c) 2021 rofl0r.\n'
		'simple mode (zero or one argument):\n'
		'pyhttpd [PORT]\n'
		'\tserves current directory on 0.0.0.0 port 8000, or on PORT\n'
		'\n'
		'extended mode:\n'
		'pyhttpd [OPTIONS]\n'
		'\tavailable OPTIONS:\n'
		'\t-i LISTENIP - specify ip to listen on\n'
		'\t-p PORT     - specify port to listen on\n'
		'\t-r ROOT     - specify root directory of webservice\n'
		'\t-a APP      - specify python module name for client_main()\n'
		'\t-A FILE     - read basic auth user:pass from FILE (use - for stdin)\n'
		'\t-x          - enable pyexpander macro language\n'
	)
	sys.exit(1)

def main():
	import threading
	port = 8000
	listen = '0.0.0.0'
	root = os.getcwd()
	app = None
	if len(sys.argv) == 2 and sys.argv[1] == '--help':
		usage()
	elif len(sys.argv) == 2 and sys.argv[1][0] in '0123456789':
		port = int(sys.argv[1])
	else:
		import getopt
		optlist, args = getopt.getopt(sys.argv[1:], ":xi:p:r:a:A:", ["expander", "listenip", "port", "root", "app", "auth"])
		for a,b in optlist:
			if   a in ('-i', '--listenip'): listen = b
			elif a in ('-p', '--port')    : port = int(b)
			elif a in ('-r', '--root')    : root = b
			elif a in ('-a', '--app')     : app = b
			elif a in ('-A', '--auth')    : read_auth(b)
			elif a in ('-x', '--expander'): init_expander()
			else: usage()
	client_main = http_client_thread
	if app:
		if os.path.dirname(app): sys.path.insert(1, os.path.dirname(app))
		app = os.path.basename(app)
		if app.endswith('.py'): app = app[:-3]
		app = __import__(app)
		client_main = app.client_main

	root = root.rstrip(os.path.sep)
	hs = HttpSrv(listen, port, root)
	hs.setup()
	client_threads = []
	while True:
		try: c = hs.wait_client()
		except KeyboardInterrupt: sys.exit(0)
		sys.stdout.write("[%d] %s\n"%(c.conn.fileno(), _format_addr(c.addr)))
		evt_done = threading.Event()
		cthread = threading.Thread(target=client_main, args=(c,evt_done))
		cthread.daemon = True
		cthread.start()

		ctrm = []
		for ct, ct_done in client_threads:
			if ct_done.is_set():
				ctrm.append((ct,ct_done))
				ct.join()

		if len(ctrm):
			client_threads = [ x for x in client_threads if not x in ctrm ]

		client_threads.append((cthread, evt_done))

if __name__ == "__main__":
	sort_script = '''
<script type="text/javascript">
// <!--
var click_column;
var name_column = 0;
var date_column = 1;
var size_column = 2;
var type_column = 3;
var prev_span = null;
if (typeof(String.prototype.localeCompare) === "undefined") {
 String.prototype.localeCompare = function(str, locale, options) {
   return ((this == str) ? 0 : ((this > str) ? 1 : -1));
 };
}
if (typeof(String.prototype.toLocaleUpperCase) === "undefined") {
 String.prototype.toLocaleUpperCase = function() {
  return this.toUpperCase();
 };
}
function get_inner_text(el) {
 if((typeof el == "string")||(typeof el == "undefined"))
  return el;
 if(el.innerText)
  return el.innerText;
 else {
  var str = "";
  var cs = el.childNodes;
  var l = cs.length;
  for (i=0;i<l;i++) {
   if (cs[i].nodeType==1) str += get_inner_text(cs[i]);
   else if (cs[i].nodeType==3) str += cs[i].nodeValue;
  }
 }
 return str;
}
function isdigit(c) {
 return (c >= "0" && c <= "9");
}
function unit_multiplier(unit) {
 return (unit=="K") ? 1024
      : (unit=="M") ? 1024*1024
      : (unit=="G") ? 1024*1024*1024
      : (unit=="T") ? 1024*1024*1024*1024
      : (unit=="P") ? 1024*1024*1024*1024*1024
      : (unit=="E") ? 1024*1024*1024*1024*1024*1024 : 1;
}
var li_date_regex=/(\d{4})-(\d{2})-(\d{2}) (\d{2}):(\d{2}):(\d{2})/;
function li_date_cmp(s1, s2) {
 var dp1 = li_date_regex.exec(s1)
 var dp2 = li_date_regex.exec(s2)
 for (var i = 1; i < 7; ++i) {
  var cmp = parseInt(dp1[i]) - parseInt(dp2[i]);
  if (0 != cmp) return cmp;
 }
 return 0;
}
function sortfn_then_by_name(a,b,sort_column) {
 if (sort_column == name_column || sort_column == type_column) {
  var ad = (a.cells[type_column].innerHTML === "Directory");
  var bd = (b.cells[type_column].innerHTML === "Directory");
  if (ad != bd) return (ad ? -1 : 1);
 }
 var at = get_inner_text(a.cells[sort_column]);
 var bt = get_inner_text(b.cells[sort_column]);
 var cmp;
 if (sort_column == name_column) {
  if (at == '..') return -1;
  if (bt == '..') return  1;
 }
 if (a.cells[sort_column].className == "int") {
  cmp = parseInt(at)-parseInt(bt);
 } else if (sort_column == date_column) {
  var ad = isdigit(at.substr(0,1));
  var bd = isdigit(bt.substr(0,1));
  if (ad != bd) return (!ad ? -1 : 1);
  cmp = li_date_cmp(at,bt);
 } else if (sort_column == size_column) {
  var ai = parseInt(at, 10) * unit_multiplier(at.substr(-1,1));
  var bi = parseInt(bt, 10) * unit_multiplier(bt.substr(-1,1));
  if (at.substr(0,1) == '-') ai = -1;
  if (bt.substr(0,1) == '-') bi = -1;
  cmp = ai - bi;
 } else {
  cmp = at.toLocaleUpperCase().localeCompare(bt.toLocaleUpperCase());
  if (0 != cmp) return cmp;
  cmp = at.localeCompare(bt);
 }
 if (0 != cmp || sort_column == name_column) return cmp;
 return sortfn_then_by_name(a,b,name_column);
}
function sortfn(a,b) {
 return sortfn_then_by_name(a,b,click_column);
}
function resort(lnk) {
 var span = lnk.childNodes[1];
 var table = lnk.parentNode.parentNode.parentNode.parentNode;
 var rows = new Array();
 for (j=1;j<table.rows.length;j++)
  rows[j-1] = table.rows[j];
 click_column = lnk.parentNode.cellIndex;
 rows.sort(sortfn);
 if (prev_span != null) prev_span.innerHTML = '';
 if (span.getAttribute("sortdir")=="down") {
  span.innerHTML = "&uarr;";
  span.setAttribute("sortdir","up");
  rows.reverse();
 } else {
  span.innerHTML = "&darr;";
  span.setAttribute("sortdir","down");
 }
 for (i=0;i<rows.length;i++)
  table.tBodies[0].appendChild(rows[i]);
 prev_span = span;
}
function init_sort() {
 var tables = document.getElementsByTagName("table");
 for (var i = 0; i < tables.length; i++) {
  var table = tables[i];
  var row = table.rows[0].cells;
  for (var j = 0; j < row.length; j++) {
   var n = row[j];
   if (n.childNodes.length == 1 && n.childNodes[0].nodeType == 3) {
    var link = document.createElement("a");
    var title = n.childNodes[0].nodeValue.replace(/:$/, "");
    link.appendChild(document.createTextNode(title));
    link.setAttribute("href", "#");
    link.setAttribute("class", "sortheader");
    link.setAttribute("onclick", "resort(this);return false;");
    var arrow = document.createElement("span");
    arrow.setAttribute("class", "sortarrow");
    arrow.appendChild(document.createTextNode(":"));
    link.appendChild(arrow)
    n.replaceChild(link, n.firstChild);
   }
  }
 }
}
init_sort();
// -->
</script>
'''
	main()
