#!/usr/bin/env python3
# like: ./mkmem.py screen.png > screen.mem
import sys
from PIL import Image

D = Image.open(sys.argv[1]).convert("RGB").getdata()
for d in D:
	print(0 if sum(d) < 128 else 1)
