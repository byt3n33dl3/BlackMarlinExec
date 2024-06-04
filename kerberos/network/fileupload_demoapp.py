# example "app" featuring a file upload page/pastebin.

import random, os
def unique_name():
	return "%016x"%random.SystemRandom().getrandbits(8*8)

def unique_file(root, ext):
	while 1:
		un = "%s%s"%(unique_name(), ext)
		u = "%s/%s"%(root, un)
		try:
			f = open(u, 'r')
			f.close()
		except IOError:
			return un

def fext(fn):
	l = len(fn)
	while l > 0:
		l -= 1
		if fn[l] == '.': return fn[l:]
	return ''

# ugly code to extract first file in multi-part post request; rest is
# quietly discarded.
def process_upload(c, req):
	try:
		ct = req['headers']['content-type']
		cl = int(req['headers']['content-length'])
	except:
		return False

	# multipart/form-data; boundary=---------------------------10448925832101884145574699149
	if not ct.startswith('multipart/form-data') or not 'boundary=' in ct:
		return False

	_, boundary = ct.split('boundary=', 1)
	try: s = c.conn.readline(maxbytes=len(boundary)*2)
	except: return False
	if not boundary in s: return False
	boundary = '\r\n' + s.strip()
	left = cl - len(s)
	try: s = c.conn.readuntil('\r\n\r\n', maxbytes=(1024 if cl > 1024 else cl))
	except: return False

	# Content-Disposition: form-data; name="filename"; filename="foo.txt"
	# Content-Type: text/plain

	if not 'filename=' in s: return False
	_, filename = s.split('filename=')
	if not filename[0] == '"' and '"' in filename[1:]: return False
	_, filename, _ = filename.split('"')
	left -= len(s)

	un = unique_file(c.root, fext(filename))
	# this whole complexity stems from the fact that we want to read
	# data in blocks, but part of the boundary may be in a previous
	# block; the smart designers of multipart/form-data decided to
	# only send the content-length of the entire multi-part block, but
	# not for its single chunks.
	with open("%s/%s"%(c.root, un), 'wb') as f:
		done_write = 0
		lastblock = ''
		while left > 0:
			try: s = c.conn.read(4096)
			except: return False
			if s == '': return False
			if not done_write:
				twoblocks = lastblock + s
				p = twoblocks.find(boundary)
				if p == -1:
					p = len(twoblocks)
					z = 1
					while z < len(boundary) and twoblocks[-z:] in boundary: z += 1
					z -= 1
					lastblock = twoblocks[-z:] if z else ''
					p -= z
				else:
					done_write = 1
				f.write(twoblocks[:p])
			left -= len(s)
		f.close()
	return un

def sec_check(fs, root):
	rp = os.path.normpath(fs)
	return rp == root or rp.startswith(root + os.path.sep)

def client_main(c, evt_done):
	root = c.root
	while c.keep_alive and c.active:
		req = c.read_request()
		if req is None: break
		if req['url'] == '/' and req['method'] == 'GET':
			c.send(200, "OK",
				'<html><body>\n'
				' <p>upload file using this form or via <pre>curl -F \'f=@"filename.txt"\' http://%s</pre><p>\n'
				' <form method="post" action="/upload.php" enctype="multipart/form-data">\n'
				'  <input type="file" name="filename"><input type="submit">\n'
				' </form>\n'
				'<body></html>\n'%req['headers']['host'])
		elif req['url'] == '/' and req['method'] == 'POST':
			un = process_upload(c, req)
			if un:
				c.send(200, "OK",
					'http://%s/%s\n'%(req['headers']['host'], un))
			else:
				c.send_error(400)
		else:
			fn = req['url'].find('?')
			if fn != -1: fn = req['url'][:fn]
			else: fn = req['url']
			fs = root + fn
			if os.path.exists(fs) and sec_check(fs, root):
				c.serve_file(fs, req['range'])
			else:
				c.send_error(404)
	c.disconnect()
	evt_done.set()

