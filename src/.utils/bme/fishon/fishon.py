#!/usr/bin/env python3
# -*- coding: utf-8 -*-

from PyInstaller.utils.hooks import collect_all

datas, binaries, hiddenimports = collect_all("fishon")
