# Import Sage and other libs
from sage.all import *
from helpers import *
from isogeny import *
from logger import *
from primes import *
from utils import *
from walk import *
from collections import defaultdict
from operator import itemgetter
import random

LOGFILE = "simulation_shared.log"
OUTPUT_FILE = "simulation"
OUTPUT_DIR = "output"
FIELDS = ["eA", "eB", "f", "prime", "expected", "simulation"]
ITER = 1
MAX_PRIMES = 6

delete_logs([LOGFILE])
sys.stdout = Logger(LOGFILE)

lA = 2
lB = 3
l  = [lA, lB]
e, p = None, None
names = ["Alice", "Bob"]

def simulation(E_0, name, iters):
    idx = None
    m = 2 if name == "Alice" else 3

    if iters <= 0:
        raise TypeError("Argument iters (= %s) should be a positive integer." % str(iters))

    for i in range(0, iters):
        if iters > 1:
            print "\nIteration: %s" % str(i + 1)
            print "===================================================================="
        else:
            print ""

        end_nodes = defaultdict(int)
        count = min_walk(p, m)
  
        E = find_starting_vertex(E_0, m, count, 0)
        j_inv = str(E.j_invariant())
        print "Start node: %s" % j_inv

        if name == "Alice":
            idx = 0
            walk_2_isogeny(E, j_inv, 0, "", e[idx], e[1 - idx], end_nodes, idx)
        elif name == "Bob":
            idx = 1
            walk_3_isogeny(E, j_inv, 0, "", e[1 - idx], e[idx], end_nodes, idx)
        else:
            raise TypeError("Argument name (= %s) should be either Alice or Bob." % name)

        uniform_secret = defaultdict(int)
        for count in range(0, (l[idx]^(e[idx] - 1)) * (l[idx] + 1)):
            i = randint(1, isomorphism_classes(p))
            uniform_secret[i] += 1

        uniform_shared = defaultdict(int)
        for value in uniform_secret.values():
            for count in range(0, (l[1 - idx]^(e[1 - idx] - 1)) * (l[1 - idx] + 1)):
                i = randint(1, isomorphism_classes(p))
                uniform_shared[i] += value
        
        print "====================================================================" if iters > 1 else "" ,

    simulated_endnode_mean = numeric_approx(sum(end_nodes.itervalues()))
    simulated_uniform_mean = numeric_approx(sum(uniform_shared.itervalues()))

    print "\n====================================================================" if iters > 1 else ""
    print "Simulation uniform sum : %s" % str(simulated_uniform_mean)
    print "Simulation end node sum: %s" % str(simulated_endnode_mean)

    # We also want to get the number of elements that were not chosen at all.
    for count in range(0, isomorphism_classes(p) - len(uniform_shared)):
        uniform_shared["dummy" + str(count)] = 0
    for count in range(0, isomorphism_classes(p) - len(end_nodes)):
        end_nodes["dummy" + str(count)] = 0

    return [uniform_shared, end_nodes]

def run_simulation(name, iters):
    simul_name = None
    print "===================================================================="
    if name == "Alice":
        simul_name = "_j(E_AB)"
        print "\nRunning simulation to estimate the distribution of j(E_AB)..."
    elif name == "Bob":
        simul_name = "_j(E_BA)"
        print "\nRunning simulation to estimate the distribution of j(E_BA)..."

    data = []
    for prime in primes:
        eA, eB, f = prime[0], prime[1], prime[2]
        global e
        e = [eA, eB]

        # Define the prime p
        global p
        p = lA**eA * lB**eB * f - 1
        assert p.is_prime()

        # Prime field of order p
        Fp = GF(p)
        R.<x> = PolynomialRing(Fp)
        # The quadratic extension via x^2 + 1 since p = 3 mod 4
        Fp2.<j> = Fp.extension(x^2 + 1)

        # E_0 is the starting curve E_0/Fp2: y^2 = x^3 + x (the A = 0 Montgomery curve)
        E_0 = EllipticCurve(Fp2, [1, 0])
        assert E_0.is_supersingular()

        print "\n===================================================================="
        print "Prime: 2^%s * 3^%s * %s - 1 => %s" % (str(eA), str(eB), str(f), str(p))
        simul = simulation(E_0, name, iters)
        data.extend(simul)

        filename = "2^" + str(eA) + "-3^" + str(eB) + "-" + str(f) + "-uniform.dat"
        write_data(OUTPUT_DIR, filename, data[0])
        filename = filename.replace("-uniform.dat", "-simul.dat")
        write_data(OUTPUT_DIR, filename, data[1])
        print "===================================================================="
    print "\nDone running the simulation."

# Generate random primes.
primes = generate_primes()
# Filter the primes and get the first 10 of them.
primes = filter_primes(primes, 10)
# We run the simulation only for Alice's case, since 
# Bob's view of the shared key is the same.
run_simulation(names[0], ITER)
