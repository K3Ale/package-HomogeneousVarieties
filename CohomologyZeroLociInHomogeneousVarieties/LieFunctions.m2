
-- Results coming back from Python (dicts/lists/tuples of numpy scalars)
-- are converted to M2 directly via "value result": the Python package's
-- (value, PythonObject) hooks walk the object natively (numpy ints and
-- floats satisfy numbers.Integral/numbers.Real, so they convert to ZZ/RR
-- like plain Python numbers). This used to go through
-- "value pythonValue stripNumpyRepr toString result" -- stringify the
-- whole result, regex out NumPy's "np.int64(...)" repr wrapper, hand the
-- cleaned string back to Python to re-eval it into an object, and only
-- then convert -- which was a size-dependent round trip for no benefit
-- over converting the original PythonObject directly.

-- Root-system data handed to Python (positive roots, rho, simple roots,
-- Cartan matrix inverse as exact Fractions, root norms, reduced word of the
-- longest Weyl group element, Poincare table), already converted with
-- toPython. Keyed by rootSystemKey (see FirstPart.m2) rather than stored on
-- R, since equal Levi root systems are rebuilt as new objects per bundle.
rootSystemPythonCache = new MutableHashTable;
rootSystemPoincareCache = new MutableHashTable;

rootSystemPythonData = method();
rootSystemPythonData RootSystem := R -> (
    key := rootSystemKey R;
    if not rootSystemPythonCache#?key then (
        posRoots := elements positiveRoots(R);
        rho := entries halfSumOfRoots(R);
        M := R#((keys R)#0);
        rootNorms := R#((keys R)#1);
        sRoots := toList (1..rank(R))/(i -> simpleRoot(R,i));
        tau := reducedDecomposition longestWeylGroupElement(R);
        fractions := import "fractions";
        Fraction := (fractions)@@("Fraction");
        rootSystemPythonCache#key = new HashTable from {
            "posRoots" => toPython (posRoots/(r -> entries r)),
            "rho" => toPython rho,
            "simpleRoots" => toPython (sRoots/(r -> entries r)),
            "M" => toPython (entries M/(r -> r/(p -> (Fraction numerator p) / (Fraction denominator p)))),
            "rootNorms" => toPython rootNorms,
            "tau" => toPython tau
            };
        );
    rootSystemPythonCache#key
    )

rootSystemPoincarePythonData = method();
rootSystemPoincarePythonData RootSystem := R -> (
    key := rootSystemKey R;
    if not rootSystemPoincareCache#?key then (
        poin := new MutableHashTable;
        x := local x;
        ZZ[x];
        for t in subsets toList(1..rank(R)) do (
            poin#(toSequence t) = sub(poincareSeries(R,parabolic(R,set t),x), x=>1);
            );
        rootSystemPoincareCache#key = toPython new HashTable from poin;
        );
    rootSystemPoincareCache#key
    )

dominantCharacterHighestWeight = method();
dominantCharacterHighestWeight (RootSystem,Weight) := (R,l) -> (
    pyData := rootSystemPythonData R;
    lam := toPython entries l;
    poinc := rootSystemPoincarePythonData R;
    dominant := import "dominantCharacterHighestWeight";
    result := dominant@@("dominantCharacterHighestWeight")(pyData#"posRoots",lam, pyData#"rho", pyData#"simpleRoots", pyData#"rootNorms", pyData#"M", poinc);
    character := value result;
    character = new Tally from character;
    character = character/(v -> weight(R,toList v));
    return character;
    )

--------------- --------- tensor product -------------------------------------

-- tensor product of two irreducible representations
tensorProduct = method();
tensorProduct (Weight,Weight,RootSystem,HashTable) := (l1,l2,R,W) -> (
    pyData := rootSystemPythonData R;
    lam1 := toPython entries l1;
    lam2 := toPython entries l2;
    -- start the translation into python
    W = toPython (W/(w -> toSequence entries w));
    tensorP := import "tensorProduct";
    result := tensorP@@("tensorProduct")(lam1, lam2, pyData#"simpleRoots", pyData#"rho", W, pyData#"tau");
    output := value result;
    output = new Tally from output;
    output = output/(v -> weight(R,toList v));
    return new HashTable from output;
    )


-- tensor product of two completely reducible representations
tensorProduct (HashTable,HashTable,RootSystem) := (L1,L2,R) -> (
    T := new MutableHashTable;
    Ttemp := new MutableHashTable;
    for i from 0 to #(keys L1)-1 do (
        l1 := (keys L1)#i;
        for j from 0 to #(keys L2)-1 do (
            l2 := (keys L2)#j;
            if weylFormula(l1,R) <= weylFormula(l2,R) then (
                W := dominantCharacterHighestWeight(R,l1); -- space for improvements?
                Ttemp = tensorProduct(l1,l2,R,W);
                )
            else (
                W = dominantCharacterHighestWeight(R,l2);
                Ttemp = tensorProduct(l2,l1,R,W);
                );
            for l in keys Ttemp do (
                if T#?l then T#l = T#l + Ttemp#l * (values L1)#i * (values L2)#j
                else T#l = Ttemp#l * (values L1)#i * (values L2)#j;
                );
            );
        );
    return T;
    )



----------------------- symmetric power ---------------------------------------------------------------------------

-- nth symmetric power of an irreducible representation
symmetricPower (ZZ, Weight,RootSystem) := (n,l,R) -> (
    if n < 0 then error "the power must be a non-negative integer"
    else if n == 0 then return new HashTable from {weight(R,toList(rank(R):0)) => 1}
    else if n == 1 then return new HashTable from {l => 1}
    else (
        pyData := rootSystemPythonData R;
        lam := toPython entries l;
        poinc := rootSystemPoincarePythonData R;
        sym := import "symmetricPower";
        result := sym@@("symmetricPower")(toPython n, lam, pyData#"posRoots", pyData#"rho", pyData#"simpleRoots", pyData#"rootNorms", pyData#"M", poinc, pyData#"tau");
        decomp := value result;
        decomp = new Tally from decomp;
        decomp = decomp/(v -> weight(R,toList v));
        return new HashTable from decomp;
        );
    )

-- returns the list of symmetric powers of an irreducible representation from 0 to k, computed inductively for efficiency
-- improvements: I could make it so I can optionally pass memoryAdams, so that if I have already computed it for the weights of the bundle then I don't recompute it
multipleSymmetricPowerLie = method();
multipleSymmetricPowerLie(ZZ, Weight, RootSystem) := (k, l, R) -> (
    if k < 0 then error "the power must be a non-negative integer"
    else if k == 0 then return new HashTable from {weight(R,toList(rank(R):0)) => 1}
    else if k == 1 then return new HashTable from {l => 1}
    else (
        pyData := rootSystemPythonData R;
        lam := toPython entries l;
        irr := toPython true;
        poinc := rootSystemPoincarePythonData R;
        sym := import "multipleSymmetricPower";
        result := sym@@("multipleSymmetricPower")(toPython k, lam, pyData#"posRoots", pyData#"rho", pyData#"simpleRoots", pyData#"rootNorms", pyData#"M", poinc, pyData#"tau",irr);
        decomp := value result;
        decomp = decomp/(d -> new Tally from d);
        decomp = decomp/(tal -> new HashTable from tal/(v -> weight(R,toList v)));
        return decomp;
        );
    )

-- given a hash table whose keys are the weights and whose values are the multiplicities, i.e. a completely reducible representation,
-- returns a hash table whose keys are the same weights and whose values are the symmetric powers of these weights
-- the multiplicities are therefore useless in the current version
-- the idea is to do kunneth directly on the vector bundles
multipleSymmetricPowerLie (ZZ, HashTable, RootSystem) := (k, L, R) -> (
    if k < 0 then error "the power must be a non-negative integer"
    else if k == 0 then return new HashTable from {weight(R,toList(rank(R):0)) => 1}
    else if k == 1 then return L
    else (
        pyData := rootSystemPythonData R;
        L' := new Tally from L;
        L' = L'/(l -> toSequence entries l);
        L' = new HashTable from L';
        L' = for l in keys L' list (
            (l,L'#l)
            );
        poinc := rootSystemPoincarePythonData R;
        -- start the translation into python;
        L' = toPython L';
        irr := toPython false;
        sym := import "multipleSymmetricPower";
        result := sym@@("multipleSymmetricPower")(toPython k, L', pyData#"posRoots", pyData#"rho", pyData#"simpleRoots", pyData#"rootNorms", pyData#"M", poinc, pyData#"tau",irr);
        decomp := value result;
        output := new MutableHashTable;
        for w in keys decomp do (
            dec := decomp#w/(d -> new Tally from d);
            output#(weight(R,toList w)) = dec/(tal -> new HashTable from tal/(v -> weight(R,toList v)));
            );
        return new HashTable from output;
        );
    )


---------------------------- exterior power ----------------------------------------------------------------------

-- nth exterior power of an irreducible representation
exteriorPower (ZZ, Weight, RootSystem) := o -> (n,l,R) -> (
    d := weylFormula(l,R);
    if n < 0 then error "the power must be a non-negative integer"
    else if n == 0 or n == d then return new HashTable from {weight(R,toList(rank(R):0)) => 1}
    else if n == 1 then return new HashTable from {l => 1}
    else if n > d then return new HashTable from {}
    else (
        pyData := rootSystemPythonData R;
        lam := toPython entries l;
        poinc := rootSystemPoincarePythonData R;
        alt := import "exteriorPower";
        result := alt@@("exteriorPower")(toPython n, lam, pyData#"posRoots", pyData#"rho", pyData#"simpleRoots", pyData#"rootNorms", pyData#"M", poinc, pyData#"tau");
        decomp := value result;
        decomp = new Tally from decomp;
        decomp = decomp/(v -> weight(R,toList v));
        return new HashTable from decomp;
        );
    )


-- returns the list of exterior powers of an irreducible representation from 0 to k, computed inductively
-- improvement: I could make it so I can optionally pass memoryAdams, so that if I have already computed it for the weights of the bundle then I don't recompute it
multipleExteriorPowerLie = method();
multipleExteriorPowerLie(ZZ, Weight, RootSystem) := (k, l, R) -> (
    if k < 0 then error "the power must be a non-negative integer"
    else if k == 0 then return new HashTable from {weight(R,toList(rank(R):0)) => 1}
    else if k == 1 then return new HashTable from {l => 1}
    else (
        pyData := rootSystemPythonData R;
        lam := toPython entries l;
        irr := toPython true;
        poinc := rootSystemPoincarePythonData R;
        ext := import "multipleExteriorPower";
        result := ext@@("multipleExteriorPower")(toPython k, lam, pyData#"posRoots", pyData#"rho", pyData#"simpleRoots", pyData#"rootNorms", pyData#"M", poinc, pyData#"tau",irr);
        decomp := value result;
        decomp = decomp/(d -> new Tally from d);
        decomp = decomp/(tal -> new HashTable from tal/(v -> weight(R,toList v)));
        return decomp;
        );
    )

-- given a hash table whose keys are the weights and whose values are the multiplicities, i.e. a completely reducible representation
-- returns a hash table whose keys are the same weights and whose values are the symmetric powers of these weights
-- the multiplicities are therefore useless in the current version
-- the idea is to do kunneth directly on the vector bundles
multipleExteriorPowerLie (ZZ, HashTable, RootSystem) := (k, L, R) -> (
    if k < 0 then error "the power must be a non-negative integer"
    else if k == 0 then return new HashTable from {weight(R,toList(rank(R):0)) => 1}
    else if k == 1 then return L
    else (
        pyData := rootSystemPythonData R;
        L' := new Tally from L;
        L' = L'/(l -> toSequence entries l);
        L' = new HashTable from L';
        L' = for l in keys L' list (
            (l,L'#l)
            );
        poinc := rootSystemPoincarePythonData R;
        -- start the translation into python;
        L' = toPython L';
        irr := toPython false;
        ext := import "multipleExteriorPower";
        result := ext@@("multipleExteriorPower")(toPython k, L', pyData#"posRoots", pyData#"rho", pyData#"simpleRoots", pyData#"rootNorms", pyData#"M", poinc, pyData#"tau",irr);
        decomp := value result;
        output := new MutableHashTable;
        for w in keys decomp do (
            dec := decomp#w/(d -> new Tally from d);
            output#(weight(R,toList w)) = dec/(tal -> new HashTable from tal/(v -> weight(R,toList v)));
            );
        return new HashTable from output;
        );
    )
