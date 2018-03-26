# Import Sage and other libs
from sage.all import *
from logger import *
from utils import *
import os

# Turn off arithmetic proof
proof.arithmetic(False)

MIN_LEVEL = 3
MAX_LEVEL = 300
LOGFILE = "modpolys.log"
OUTPUT_FILE = "modpolys.csv"
OUTPUT_DIR = "output"
MODPOLYS_DIR = "modpolys"
FIELDS = ["Level", "p_1728_1", "p_1728_3", "p_0_1", "p_0_2"]

delete_logs([LOGFILE])
sys.stdout = Logger(LOGFILE)

class ModularPolynomial:
    """
        Implements modular polynomial functionality.
    """
    def __init__(self, level):
        """
            Initializes a modular polynomial of the provided level.
        """
        if level in [1..MAX_LEVEL]:
            self.level = level
        else:
            raise TypeError("Argument level (= %s) should be between 1 and %s." % (str(level), str(MAX_LEVEL)))

        self.P = PolynomialRing(IntegerRing(), 2, "j")
    
    def __get_filename(self):
        return "phi_j_%s.txt" % str(self.level)
    
    def __getitem__(self):
        filename = self.__get_filename()
        filepath = os.path.join(os.path.abspath(".."), MODPOLYS_DIR, filename)
        if not os.path.isfile(filepath):
            raise EnvironmentError("File %s does not exist." % filename)
        
        poly = {}
        with open(filepath) as f:
            for line in f:
                parts = line.split()
                assert len(parts) == 2
                
                coeffs = parts[0].translate(None, "[]").split(",")
                assert len(coeffs) == 2
                
                x = Integer(coeffs[0])
                y = Integer(coeffs[1])
                value = Integer(parts[1])
                
                poly[(x, y)] = value
                if x != y:
                    poly[(y, x)] = value
        return self.P(poly)

    def __call__(self, x, y):
        poly = self.__getitem__()
        return poly(x, y)

    def __repr__(self):
        return str(self.__getitem__())
    
    def __str__(self):
        poly = self.__getitem__()
        var("X,Y")
        return "Modular polynomial of level %s:\n%s" % (str(self.level), str(poly(X,Y)))

def prime_levels():
    plevels = []
    for level in [MIN_LEVEL..MAX_LEVEL]:
        if level.is_prime():
            plevels.append(level)
    return plevels

def prime_factors(value):
    if value == 0:
        return None

    pfactors = [f[0] for f in list(factor(value))]
    pfactors.sort(reverse = True)
    return pfactors

def p_1728_1(modpoly, level):
    R.<Y> = PolynomialRing(IntegerRing())
    modpoly = R(modpoly(1728, Y))
    divisor = (Y - 1728)^2

    if divisor.divides(modpoly):
        modpoly = modpoly / divisor

    pfactors = prime_factors(modpoly(1728))

    if level % 4 != 1 or pfactors is None:
        return None

    for p in pfactors:
        if p != level and p % 4 == 3:
            return p

def p_1728_3(modpoly, level):
    pfactors = prime_factors(modpoly(1728, 1728))
    
    if level % 4 != 3 or pfactors is None:
        return None
    
    for p in pfactors:
        if p != level and p % 4 == 3:
            return p

def p_0_1(modpoly, level):
    R.<Y> = PolynomialRing(IntegerRing())
    modpoly = R(modpoly(0, Y))
    divisor = Y^2

    if divisor.divides(modpoly):
        modpoly = modpoly / divisor

    pfactors = prime_factors(modpoly(0))

    if level % 3 != 1 or pfactors is None:
        return None

    for p in pfactors:
        if p != level and p % 3 == 2:
            return p

def p_0_2(modpoly, level):
    pfactors = prime_factors(modpoly(0, 0))
    
    if level % 3 != 2 or pfactors is None:
        return None

    for p in pfactors:
        if p != level and p % 3 == 2:
            return p

print "===================================================================="
print "Calculating using modular polynomials..."
results = []
for level in prime_levels():
    print "\n===================================================================="
    print "Level: %s\n" % str(level)
    
    modpoly = ModularPolynomial(level)

    values = [level]
    values.extend([ p_1728_1(modpoly, level), p_1728_3(modpoly, level),
                    p_0_1   (modpoly, level), p_0_2   (modpoly, level) ])
    
    assert len(values) == len(FIELDS)
    results.append(values)

    print "p_1728_1: %s" % ("-", str(values[1]))[values[1] is not None]
    print "p_1728_3: %s" % ("-", str(values[2]))[values[2] is not None]
    print "p_0_1   : %s" % ("-", str(values[3]))[values[3] is not None]
    print "p_0_2   : %s" % ("-", str(values[4]))[values[4] is not None]
    print "===================================================================="
print "\nDone calculating."

write_csv(OUTPUT_DIR, OUTPUT_FILE, FIELDS, results)
