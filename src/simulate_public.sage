# Import Sage
from sage.all import *
from helpers import *
from isogeny import *
from logger import *
from primes import *
from utils import *
from walk import *
from collections import defaultdict
from operator import itemgetter

LOGFILE = "simulation_public.log"
OUTPUT_FILE = "simulation"
OUTPUT_DIR = "output"
FIELDS = ["eA", "eB", "f", "prime", "theoretical", "expected", "simulation"]
ITER = 100

delete_logs([LOGFILE])
sys.stdout = Logger(LOGFILE)

lA = 2
lB = 3
l  = [lA, lB]
e, p = None, None
names = ["Alice", "Bob"]

def simulation(E_0, name, iters):
    nodes = []
    distinct_nodes = []
    uniform_nodes = []
    total_nodes = 0
    total_distinct_nodes = 0
    total_uniform_nodes = 0
    idx = None
    m = 2 if name == "Alice" else 3

    if iters <= 0:
        raise TypeError("Argument iters (= %s) should be a positive integer." % str(iters))

    for i in range(0, iters):
        print "\nIteration: %s" % str(i + 1)
        print "===================================================================="

        end_nodes = defaultdict(int)
        count = min_walk(p, m)

        E = find_starting_vertex(E_0, m, count, 0)
        j_inv = str(E.j_invariant())
        print "Start node: %s\n" % j_inv

        if name == "Alice":
            idx = 0
            walk(E, j_inv, 0, "", e[idx], l[idx], end_nodes)
        elif name == "Bob":
            idx = 1
            walk(E, j_inv, 0, "", e[idx], l[idx], end_nodes)
        else:
            raise TypeError("Argument name (= %s) should be either Alice or Bob." % name)

        uniform = defaultdict(int)
        for count in range(0, (l[idx]^(e[idx] - 1)) * (l[idx] + 1)):
            i = randint(1, isomorphism_classes(p))
            uniform[i] += 1
        
        nodes.append(len(end_nodes))
        total_nodes += len(end_nodes)

        distinct_end_nodes = count_distinct(end_nodes)
        distinct_nodes.append(distinct_end_nodes)
        total_distinct_nodes += distinct_end_nodes

        distinct_uniform_nodes = count_distinct(uniform)
        uniform_nodes.append(distinct_uniform_nodes)
        total_uniform_nodes += distinct_uniform_nodes
        
        print "Non-distinct end nodes: %s" % str(filter_nodes(end_nodes))
        print "===================================================================="

    theoretical_value = theoretical_expected(isomorphism_classes(p), l[idx], e[idx])
    simulated_distinct_mean = numeric_approx(total_distinct_nodes / iters)
    simulated_uniform_mean  = numeric_approx(total_uniform_nodes  / iters)

    print "\n===================================================================="
    print "Theoretical expected value: %s" % str(theoretical_value)
    print "Simulation uniform mean   : %s" % str(simulated_uniform_mean)
    print "Simulation distinct mean  : %s" % str(simulated_distinct_mean)
    print "\nDistinct simul end nodes: %s" % str(distinct_nodes)
    print "Distinct uniform values : %s" % str(uniform_nodes)
    print "===================================================================="

    return [theoretical_value, simulated_uniform_mean, simulated_distinct_mean]

def run_simulation(name, iters):
    simul_name = None
    print "===================================================================="
    if name == "Alice":
        simul_name = "_j(E_A)"
        print "\nRunning simulation to estimate the distribution of j(E_A)..."
    elif name == "Bob":
        simul_name = "_j(E_B)"
        print "\nRunning simulation to estimate the distribution of j(E_B)..."

    results = []
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
        values = [eA, eB, f, p]
        simul = simulation(E_0, name, iters)
        values.extend(simul)

        assert len(values) == len(FIELDS)
        results.append(values)

    # Sort the results in ascending order according to the prime.
    results = sorted(results, key = itemgetter(3))

    print "\nDone running the simulation."
    out_file = OUTPUT_FILE + simul_name + ".csv"
    write_csv(OUTPUT_DIR, out_file, FIELDS, results)

primes = generate_primes()
primes = filter_primes(primes)

for name in names:
    run_simulation(name, ITER)
