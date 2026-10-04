"""
Bott's algorithm for computing the sheaf cohomology of homogeneous vector
bundles.

This module is called from Macaulay2 (see Cohomology.m2 -> bottPython), which
imports it via Python-in-M2 and calls only bottPy, the entry point below.
S and m (weights and multiplicities of the bundle) and rho, simpleRoots,
posRoots, rootNorms, M (data of the underlying root system) are all built
on the M2 side and passed in as plain Python lists.
"""

from fractions import Fraction
from math import gcd
from operator import index


def reflect(n, p, simpleRoots):
    """Apply the n-th simple reflection to the weight p (in root coordinates)."""
    c = p[n - 1]
    return [a - c * b for a, b in zip(p, simpleRoots[n - 1])]


def dominant_conjugate(lam, simpleRoots):
    """
    Bring the weight lam into the dominant Weyl chamber by successive simple
    reflections.

    Returns (dominant_weight, k), where k is the number of reflections used.
    """
    v = list(lam)
    k = 0
    while True:
        for j, x in enumerate(v):
            if x < 0:
                k += 1
                v = reflect(j + 1, v, simpleRoots)
                break
        else:
            return v, k


_bilinear_form_cache = {}


def bilinear_form(rootNorms, M):
    """
    Integer matrix B and denominator D such that scalar_product(u, v) equals
    (sum_ij v_i B_ij u_j) / D, i.e. B_ij / D = M_ij * rootNorms_i / 2.
    Computed once per root system: the caller always passes the same M and
    rootNorms objects, so they are cached by identity.
    """
    hit = _bilinear_form_cache.get((id(M), id(rootNorms)))
    if hit is not None and hit[0] is M and hit[1] is rootNorms:
        return hit[2], hit[3]
    F = [[Fraction(x) * Fraction(rootNorms[i]) / 2 for x in row] for i, row in enumerate(M)]
    D = 1
    for row in F:
        for x in row:
            D = D * x.denominator // gcd(D, x.denominator)
    B = [[int(x * D) for x in row] for row in F]
    _bilinear_form_cache[(id(M), id(rootNorms))] = (M, rootNorms, B, D)
    return B, D


def scalar_product(u, v, rootNorms, M):
    """
    Scalar product of two weights u, v with respect to the Cartan matrix
    inverse M and the root norms rootNorms (exact, as a Fraction).
    """
    B, D = bilinear_form(rootNorms, M)
    u = [index(x) for x in u]
    s = 0
    for vi, row in zip(v, B):
        if vi:
            s += index(vi) * sum(b * x for b, x in zip(row, u))
    return Fraction(s, D)


_coroot_cache = {}


def coroot_data(posRoots, rho, rootNorms, M):
    """
    For every positive root r, the integers c_i = <omega_i, r^vee>, so that
    <v, r^vee> = sum_i c_i v_i; and the Weyl denominator prod_r <rho, r^vee>.
    Computed once per root system (cached by identity of the arguments).
    """
    key = (id(posRoots), id(rho), id(rootNorms), id(M))
    hit = _coroot_cache.get(key)
    if hit is not None and hit[0] is posRoots and hit[1] is rho and hit[2] is rootNorms and hit[3] is M:
        return hit[4], hit[5]
    n = len(rho)
    C = []
    for r in posRoots:
        rr = scalar_product(r, r, rootNorms, M)
        row = []
        for i in range(n):
            e = [1 if j == i else 0 for j in range(n)]
            c = 2 * scalar_product(e, r, rootNorms, M) / rr
            if c.denominator != 1:
                raise ValueError("non-integral coroot coefficient")
            row.append(c.numerator)
        C.append(row)
    D = 1
    for c in C:
        D *= sum(ci * x for ci, x in zip(c, rho))
    _coroot_cache[key] = (posRoots, rho, rootNorms, M, C, D)
    return C, D


def weyl_formula(v, rho, posRoots, rootNorms, M):
    """
    Weyl dimension formula: dimension of the irreducible representation with
    highest weight v, as the product over positive roots r of
    <v + rho, r^vee> / <rho, r^vee>.
    """
    C, D = coroot_data(posRoots, rho, rootNorms, M)
    v_plus_rho = [wi + ri for wi, ri in zip(v, rho)]
    N = 1
    for c in C:
        N *= sum(ci * x for ci, x in zip(c, v_plus_rho))
    return Fraction(N, D).numerator


def bottPy(S, m, rho, simpleRoots, posRoots, rootNorms, M, d):
    """
    Main entry point, called from Macaulay2.

    Computes the cohomology of a homogeneous vector bundle via Bott's
    algorithm: for each weight l in S (with multiplicity m[i]),
      - if l + rho is singular (lies on a wall of the Weyl chambers), it
        contributes nothing;
      - otherwise l + rho is conjugated to a dominant weight l1 by k simple
        reflections, and the Weyl dimension formula gives the dimension h
        of the corresponding representation, added to H[k].

    Returns H, a list of length d + 1 with H[q] = dimension of H^q.
    """
    H = [0] * (d + 1)
    for i in range(len(S)):
        l = S[i]
        l_plus_rho = [wi + ri for wi, ri in zip(l, rho)]
        if not any(l_plus_rho[j] == 0 for j in range(len(l))):
            l1, q = dominant_conjugate(l_plus_rho, simpleRoots)
            h = weyl_formula(
                [wi - ri for wi, ri in zip(l1, rho)], rho, posRoots, rootNorms, M
            )
            H[q] = H[q] + m[i] * h
    return H
