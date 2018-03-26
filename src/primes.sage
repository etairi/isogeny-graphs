# Import Sage and other libs
from sage.all import *
from helpers import *
from logger import *
from operator import itemgetter
import errno
import random
import sys

# Turn off arithmetic proof
proof.arithmetic(False)

LOGFILE = "primes.log"
MAX_PRIMES = 50

delete_logs([LOGFILE])
#sys.stdout = Logger(LOGFILE)

def print_primes(primes):
    print "===================================================================="
    print "Printing primes..."

    for p in primes:
        eA, eB, f, prime = p[0], p[1], p[2], p[3]
        assert is_prime(prime)

        print "\nPrime: 2^%s * 3^%s * %s - 1 => %s" % (str(eA), str(eB), str(f), str(prime))
        print "===================================================================="
        print "Size     (bit) : %s" % str(numeric_approx(log(prime, 2)))
        print "Security (bit) : %s" % str(floor(log(min(2**eA, 3**eB), 2) / 3))
        print "Log(2^eA-3^eB) : %s" % str(numeric_approx(abs(log(2**eA) - log(3**eB))))
        print "Ratio eA/eB    : %s" % str(numeric_approx(eA / eB))
        print "===================================================================="
    
    print "\nDone printing primes."

def generate_primes():
    print "===================================================================="
    print "Generating primes..."

    primes = []
    for eA in [5..15]:     # [5..510]
        for eB in [3..10]: # [3..320]
            for f in [1..50]:
                p = 2**eA * 3**eB * f - 1
                if is_prime(p):
                        primes.append([eA, eB, f, p])

    print "Done generating primes."
    print "\nPrimes found: %s" % str(len(primes))
    return primes

def filter_primes(primes):
    print "===================================================================="
    print "Filtering primes..."

    filtered = []
    for p in primes:
        eA, eB, f, prime = p[0], p[1], p[2], p[3]

        log_diff = numeric_approx(abs(log(2**eA) - log(3**eB)))
        if (log_diff > 0.00 and log_diff < 1.00):
            filtered.append([eA, eB, f, prime])

    # Filter the primes with the same value, so we only have one copy of each prime.
    used = set()
    filtered = [used.add(f[3]) or f for f in filtered if f[3] not in used]
    # Filter the same powers eA and eB, so we only have one copy of each pair of powers.
    used = set()
    filtered = [used.add(tuple(f[:2])) or f for f in filtered if tuple(f[:2]) not in used]
    # Sample MAX_PRIMES amount of primes, and sort them in ascending order according to the prime.
    filtered = random.sample(filtered, MAX_PRIMES) if len(filtered) > MAX_PRIMES else filtered
    filtered = sorted(filtered, key = itemgetter(3))

    print "Done filtering primes."
    print "\nPrimes after filtering: %s" % str(len(filtered))
    return filtered

# primes = generate_primes()
# primes = filter_primes(primes)
# print_primes(primes)
