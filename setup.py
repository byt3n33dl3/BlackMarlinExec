from setuptools import setup, find_packages
import re

VERSIONFILE="kerberos/aioclient.py"
verstrline = open(VERSIONFILE, "rt").read()
VSRE = r"^__version__ = ['\"]([^'\"]*)['\"]"
mo = re.search(VSRE, verstrline, re.M)
if mo:
    verstr = mo.group(1)
else:
    raise RuntimeError("Unable to find version string in %s." % (VERSIONFILE,))

setup(
	# Application name:
	name="BlackMarlinExec",

	# Version number (initial):
	version=verstr,

	# Application author details:
	author="pxcs",

	# Packages
	packages=find_packages(exclude=["tests*"]),

	# Include additional files into the package
	include_package_data=True,

	python_requires='>=3.6',
	classifiers=[
		"Programming Language :: Python :: 3.6",
		"License :: OSI Approved :: MIT License",
		"Operating System :: OS Independent",
	],
	install_requires=[
		'asn1crypto>=1.5.1',
		'oscrypto>=1.3.0',
		'asysocks>=0.2.8',
		'unicrypto>=0.0.10',
		'tqdm',
        'six',
	],

	entry_points={
		'console_scripts': [
			'Kerberos-ccacheedit   = Kerberos.examples.ccache_editor:main',
			'Kerberos-kirbi2ccache = Kerberos.examples.kirbi2ccache:main',
			'Kerberos-ccache2kirbi = Kerberos.examples.ccache2kirbi:main',
			'Kerberos-ccacheroast  = Kerberos.examples.ccacheroast:main',
			'Kerberos-getTGT       = Kerberos.examples.getTGT:main',
			'Kerberos-getTGS       = Kerberos.examples.getTGS:main',
			'Kerberos-getS4U2proxy = Kerberos.examples.getS4U2proxy:main',
			'Kerberos-getS4U2self  = Kerberos.examples.getS4U2self:main',
			'Kerberos-getNTPKInit  = Kerberos.examples.getNT:main',
			'Kerberos-cve202233647 = Kerberos.examples.CVE_2022_33647:main',
			'Kerberos-cve202233679 = Kerberos.examples.CVE_2022_33679:main',
			'Kerberos-kerb23hashdecrypt = Kerberos.examples.kerb23hashdecrypt:main',
			'Kerberos-kerberoast   = Kerberos.examples.spnroast:main',
            'Kerberos-asreproast   = Kerberos.examples.asreproast:main',
            'Kerberos-changepw   = Kerberos.examples.changepassword:main',
		],
	}
)
