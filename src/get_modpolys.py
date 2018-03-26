from __future__ import print_function
from utils import create_output_dir
import math
import os
import requests
import sys

MIN_LEVEL = 3
MAX_LEVEL = 300
MODPOLYS_DIR = "modpolys"

def get_url(level):
    return "http://math.mit.edu/~drew/modpolys/jfiles/phi_j_%s.txt" % str(level)

def is_prime(n):
    if (n <= 1) or (n % 2 == 0 and n > 2):
        return False
    return all(n % i for i in range(3, int(math.sqrt(n)) + 1, 2))

def prime_levels():
    plevels = []
    for level in range(MIN_LEVEL, MAX_LEVEL + 1):
        if is_prime(level):
            plevels.append(level)
    return plevels

if sys.version_info[0] == 2:
    rinput = raw_input("Do you want to download the modular polynomial database? [Y/N]: ")
else:
    rinput = input("Do you want to download the modular polynomial database? [Y/N]: ")

if rinput.lower() != "y":
    sys.exit()

dirname = os.path.join(os.path.abspath(".."), MODPOLYS_DIR)
create_output_dir(dirname)
print("\n====================================================================")
print("Downloading the modular polynomial database...\n")
for level in prime_levels():
    url = get_url(level)
    filename = url.rsplit("/", 1)[1]
    filepath = os.path.join(dirname, filename)

    print("Downloading %s..." % filename, end = "  ")
    r = requests.get(url, allow_redirects=True)
    with open(filepath, "wb") as f:
        f.write(r.content)
    print("Done.", end = "\n")
print("\nFinished downloading the modular polynomial database.")
print("====================================================================")
