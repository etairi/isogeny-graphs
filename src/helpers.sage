# Import Sage
from sage.all import *

def numeric_approx(value, d = 4):
    c = ceil(log(value.n(), 10))
    w = c if c > 0 else 0
    return value.n(digits = w + d)

def isomorphism_classes(p):
    classes = floor(p / 12)
    if p % 12 == 5 or p % 12 == 7:
        classes += 1
    elif p % 12 == 11:
        classes += 2

    return classes

def theoretical_expected(v, l, e):
    return numeric_approx(v * (1 - (((v - 1) / v)^((l + 1) * l^(e - 1)))))
