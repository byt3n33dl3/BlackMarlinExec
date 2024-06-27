from setuptools import setup, find_packages
import re

VERSION = "5.5.7"
verstrline = open(VERSION, "r").read()
VSRE = r"^__version__ = ['\"]([^'\"]*)['\"]"
mo = re.search(VSRE, verstrline, re.M)
if mo:
    verstr = mo.group(1)
else:
    raise RuntimeError("Unable to find version string in %s." % (VERSION,))

setup(
    # Application name:
    name="BlackMarlinExec_Package",

    # Version number (initial):
    version=verstr,

    # Application author details:
    author="pxcs",
    author_email="x-x-x@x-x-x.com",

    # Packages
    packages=find_packages(exclude=["tests*"]),

    # Include additional files into the package
    include_package_data=True,

    # Minimum Python version requirement
    python_requires='>=3.12',

    # Classifiers
    classifiers=[
        "Programming Language :: Python :: 3.12",
        "License :: OSI Approved :: GPL License",
        "Operating System :: OS Independent",
    ],

    # Dependencies
    install_requires=[
        'asn1crypto>=1.5.1',
        'oscrypto>=1.3.0',
        'asysocks>=0.2.8',
        'unicrypto>=0.0.10',
        'tqdm',
        'six',
    ],

    # Console scripts
    entry_points={
        'console_scripts': [
            'Kerberos-ccacheedit-BME=Kerberos.examples.ccache_editor:main',
            'Kerberos-kirbi2ccache-BME=Kerberos.examples.kirbi2ccache:main',
            'Kerberos-ccache2kirbi-BME=Kerberos.examples.ccache2kirbi:main',
            'Kerberos-ccacheroast-BME=Kerberos.examples.ccacheroast:main',
            'Kerberos-getTGT-BME=Kerberos.examples.getTGT:main',
            'Kerberos-getTGS-BME=Kerberos.examples.getTGS:main',
            'Kerberos-getS4U2proxy-BME=Kerberos.examples.getS4U2proxy:main',
            'Kerberos-getS4U2self-BME=Kerberos.examples.getS4U2self:main',
            'Kerberos-getNTPKInit-BME=Kerberos.examples.getNT:main',
            'Kerberos-cve202233647-BME=Kerberos.examples.CVE_2022_33647:main',
            'Kerberos-cve202233679-BME=Kerberos.examples.CVE_2022_33679:main',
            'Kerberos-kerb23hashdecrypt-BME=Kerberos.examples.kerb23hashdecrypt:main',
            'Kerberos-kerberoast-BME=Kerberos.examples.spnroast:main',
            'Kerberos-asreproast-BME=Kerberos.examples.asreproast:main',
            'Kerberos-changepw-BME=Kerberos.examples.changepassword:main',
        ],
    }
)
