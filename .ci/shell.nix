{ pkgs ? import <nixpkgs> {} }:
let
	perlEnv = pkgs.perl.withPackages (p: with p; [
		CompressRawLzma
		DigestMD4
		DigestSHA1
		GetoptLong
		perlldap
	]);
	pythonEnv = pkgs.python3.withPackages(p: with p; [
		dpkt
		scapy
		lxml
		wrapPython
	]);
in
pkgs.mkShell {
	nativeBuildInputs = with pkgs.buildPackages;
		[
			openssl libzip rocm-opencl-runtime opencl-headers
			bzip2 libpcap libgmpris libxcrypt gmp intel-ocl
			gcc zlib nss nspr libkrb5 re2 makeWrapper
			perlEnv pythonEnv
		];
	shellHook = ''
		export AS=$CC
		export LD=$CC
	'';
}
