# Import Sage and other libs
from sage.all import *
from helpers import *
from isogeny import PointIsogeny
from collections import defaultdict

# Turn off arithmetic proof
proof.arithmetic(False)

def min_walk(p, ell):
    return ceil(log(2 * isomorphism_classes(p)) / log((ell + 1) / (2 * sqrt(ell))))

def find_starting_vertex(E_i, m, max_count, count):
    if count == max_count:
        return E_i

    kers = E_i(0).division_points(m)

    P = kers[randint(0, (len(kers) - 1))]
    while P == E_i(0):
        P = kers[randint(0, (len(kers) - 1))]

    E_i = PointIsogeny(E_i, [P], [], [m])[0]
    return find_starting_vertex(E_i, m, max_count, count + 1)

def walk(E_i, j, level, prev_j, max_level, m, end_nodes):
    children = defaultdict(int)
    if level < max_level:
        for P in E_i(0).division_points(m):
            # Only treat one point of each non-trivial cyclic subgroup of E_i[3].
            if (m == 2 and P == E_i(0)) or (m == 3 and (P == E_i(0) or str(P + P) < str(P))):
                continue

            E_child = PointIsogeny(E_i, [P], [], [m])[0]
            j_child = str(E_child.j_invariant())

            level_child = level + 1
            children[j_child] += 1

            # We only walk to codomain of dual isogeny if there are
            # other isogenies than the dual isogeny that lead there.
            if (j_child != prev_j) or (m == 2 and children[j_child] > 1) or (m == 3 and children[j_child] > 2):
                walk(E_child, j_child, level_child, j, max_level, m, end_nodes)
    else:
        end_nodes[j] += 1

def walk_2_isogeny(E_i, j, level, prev_j, two_max_level, three_max_level, end_nodes, sim_index):
    children = defaultdict(int)
    if level < two_max_level:
        for P in E_i(0).division_points(2):
            if P == E_i(0):
                continue

            E_child = PointIsogeny(E_i, [P], [], [2])[0]
            j_child = str(E_child.j_invariant())

            level_child = level + 1
            children[j_child] += 1

            # We only walk to codomain of dual isogeny if there are
            # other isogenies than the dual isogeny that lead there.
            if (j_child != prev_j) or (children[j_child] > 1):
                walk_2_isogeny(E_child, j_child, level_child, j, two_max_level, three_max_level, end_nodes, sim_index)
    elif sim_index == 0:
        walk_3_isogeny(E_i, j, 0, "", two_max_level, three_max_level, end_nodes, sim_index)
    else:
        end_nodes[j] += 1

def walk_3_isogeny(E_i, j, level, prev_j, two_max_level, three_max_level, end_nodes, sim_index):
    children = defaultdict(int)
    if level < three_max_level:
        for P in E_i(0).division_points(3):
            # Only treat one point of each non-trivial cyclic subgroup of E_i[3].
            if (P == E_i(0)) or (str(P + P) < str(P)): 
                continue
            
            E_child = PointIsogeny(E_i, [P], [], [3])[0]
            j_child = str(E_child.j_invariant())

            level_child = level + 1
            children[j_child] += 1
            
            # We only walk to codomain of dual isogeny if there are
            # other isogenies than the dual isogeny that lead there.
            if (j_child != prev_j) or (children[j_child] > 2):
                walk_3_isogeny(E_child, j_child, level_child, j, two_max_level, three_max_level, end_nodes, sim_index)
    elif sim_index == 1:
        walk_2_isogeny(E_i, j, 0, "", two_max_level, three_max_level, end_nodes, sim_index)
    else:
        end_nodes[j] += 1
