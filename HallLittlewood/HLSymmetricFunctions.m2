HLSymmetricRing = new Type of HashTable
HLSymmetricFunction = new Type of HashTable
HLSeries = new Type of HashTable
HLIndexedVariableTable = new Type of IndexedVariableTable

-------------------------------------------------------------------------------
-- Partitions and compositions
-------------------------------------------------------------------------------

toListIndex = x -> (
    if instance(x, ZZ) then {x}
    else if instance(x, List) then x
    else if instance(x, Sequence) then toList x
    else error "expected an integer, list, or sequence index"
    )

trimTrailingZeros = L -> (
    L = toListIndex L;
    while #L > 0 and last L == 0 do L = drop(L, -1);
    L
    )

partitionWeight = method()
partitionWeight List := L -> sum L
partitionWeight Sequence := L -> partitionWeight toList L
partitionWeight ZZ := n -> n

partitionLength = method()
partitionLength List := L -> #select(trimTrailingZeros L, i -> i != 0)
partitionLength Sequence := L -> partitionLength toList L
partitionLength ZZ := n -> if n == 0 then 0 else 1

normalizePartition = L -> reverse sort select(trimTrailingZeros L, i -> i > 0)

isPartition = L -> (
    L = trimTrailingZeros L;
    all(L, i -> i >= 0) and all(0..#L-2, i -> L#i >= L#(i+1))
    )

hlPartitions = method()
hlPartitions ZZ := n -> (
    if n < 0 then return {};
    scan := (remaining, largest) -> (
        if remaining == 0 then {{}}
        else (
            ans := {};
            for firstPart in reverse toList(1..min(remaining, largest)) do
                ans = ans | apply(scan(remaining-firstPart, firstPart),
                    tail -> prepend(firstPart, tail));
            ans
            )
        );
    scan(n, n)
    )

conjugatePartition = method()
conjugatePartition List := lambda -> (
    lambda = trimTrailingZeros lambda;
    if #lambda == 0 then return {};
    apply(1..max lambda, i -> #select(lambda, part -> part >= i))
    )
conjugatePartition Sequence := lambda -> conjugatePartition toList lambda

factorialZZ = n -> if n <= 1 then 1 else product toList(1..n)
partitionMultiplicity = (lambda, part) -> #select(lambda, i -> i == part)

zCoefficient = (A, lambda) -> (
    K := A#"CoefficientRing";
    lambda = normalizePartition lambda;
    ans := 1_K;
    for part in unique lambda do if part > 0 then (
        mult := partitionMultiplicity(lambda, part);
        ans = ans * promote(part^mult * factorialZZ mult, K);
        );
    ans
    )

compositionDegree = L -> sum apply(trimTrailingZeros L, i -> max(i, 0))

checkDegree = (A, L) -> (
    d := compositionDegree L;
    if d > A#"DegreeLimit" then
        error("index has degree " | toString d | ", exceeding degree limit " | toString(A#"DegreeLimit"));
    )

-------------------------------------------------------------------------------
-- Sparse mixed-basis expressions
-------------------------------------------------------------------------------

-- An expression is a sparse polynomial. Keys are commutative monomials, represented
-- as sorted lists of atom strings such as "S|5,1,3" or "h|2".

makeAtom = (basis, idx) -> basis | "|" | demark(",", apply(trimTrailingZeros idx, toString))

skewBases = {"skewS", "skewSomega", "skewP", "skewR", "skewQ", "skewB"}
isSkewBasis = basis -> any(skewBases, b -> b == basis)

splitStringSimple = (s, sep) -> (
    out := {};
    current := "";
    for i from 0 to #s-1 do (
        ch := substring(i, 1, s);
        if ch == sep then (
            out = append(out, current);
            current = "";
            )
        else current = current | ch;
        );
    append(out, current)
    )

parseIndexString = s -> if s == "" then {} else apply(splitStringSimple(s, ","), part -> value part)

makeSkewAtom = (basis, lambda, mu) -> (
    lambda = trimTrailingZeros lambda;
    mu = trimTrailingZeros mu;
    basis | "|" | demark(",", apply(lambda, toString)) | ";" | demark(",", apply(mu, toString))
    )

parseSkewIndexString = s -> (
    parts := splitStringSimple(s, ";");
    if #parts != 2 then error "expected a skew index encoded as two index lists";
    {parseIndexString parts#0, parseIndexString parts#1}
    )

parseAtom = atom -> (
    parts := splitStringSimple(atom, "|");
    basis := parts#0;
    idxString := if #parts > 1 then parts#1 else "";
    idx := if isSkewBasis basis then parseSkewIndexString idxString else parseIndexString idxString;
    (basis, idx)
    )

sortMonomial = M -> sort M

cleanTerms = (A, H) -> (
    K := A#"CoefficientRing";
    ans := new MutableHashTable;
    for entry in pairs H do (
        mon := sortMonomial first entry;
        coeff := promote(last entry, K);
        if coeff != 0_K then (
            old := if ans#?mon then ans#mon else 0_K;
            ans#mon = old + coeff;
            if ans#mon == 0_K then remove(ans, mon);
            );
        );
    new HashTable from pairs ans
    )

newHL = (A, H) -> new HLSymmetricFunction from hashTable {
    "Ring" => A,
    "Terms" => cleanTerms(A, H)
    }

hlRing = f -> f#"Ring"
hlTerms = f -> f#"Terms"
zeroHL = A -> newHL(A, new HashTable from {})
oneHL = A -> newHL(A, new HashTable from {{} => 1_(A#"CoefficientRing")})

hashTableEqual = (H, K) -> (
    if #keys H != #keys K then return false;
    all(keys H, key -> K#?key and H#key == K#key)
    )

HLSymmetricFunction == HLSymmetricFunction := (f, g) -> (
    hlRing f === hlRing g and hashTableEqual(hlTerms f, hlTerms g)
    )

HLSymmetricFunction + HLSymmetricFunction := (f, g) -> (
    if hlRing f =!= hlRing g then error "expected elements in the same HallLittlewood ring";
    A := hlRing f;
    K := A#"CoefficientRing";
    ans := new MutableHashTable from pairs hlTerms f;
    for entry in pairs hlTerms g do (
        mon := first entry;
        old := if ans#?mon then ans#mon else 0_K;
        ans#mon = old + last entry;
        if ans#mon == 0_K then remove(ans, mon);
        );
    newHL(A, new HashTable from pairs ans)
    )

- HLSymmetricFunction := f -> (
    A := hlRing f;
    newHL(A, new HashTable from apply(pairs hlTerms f, entry -> first entry => -(last entry)))
    )

HLSymmetricFunction - HLSymmetricFunction := (f, g) -> f + (-g)

scalarHL = (A, c) -> (
    K := A#"CoefficientRing";
    cc := promote(c, K);
    if cc == 0_K then zeroHL A else newHL(A, new HashTable from {{} => cc})
    )

scalarTimesHL = (c, f) -> (
    A := hlRing f;
    K := A#"CoefficientRing";
    cc := promote(c, K);
    if cc == 0_K then return zeroHL A;
    newHL(A, new HashTable from apply(pairs hlTerms f, entry -> first entry => cc * last entry))
    )

Number * HLSymmetricFunction := (c, f) -> scalarTimesHL(c, f)
HLSymmetricFunction * Number := (f, c) -> scalarTimesHL(c, f)
RingElement * HLSymmetricFunction := (c, f) -> scalarTimesHL(c, f)
HLSymmetricFunction * RingElement := (f, c) -> scalarTimesHL(c, f)
HLSymmetricFunction / RingElement := (f, c) -> scalarTimesHL(1/promote(c, (hlRing f)#"CoefficientRing"), f)

Number + HLSymmetricFunction := (c, f) -> scalarHL(hlRing f, c) + f
HLSymmetricFunction + Number := (f, c) -> f + scalarHL(hlRing f, c)
RingElement + HLSymmetricFunction := (c, f) -> scalarHL(hlRing f, c) + f
HLSymmetricFunction + RingElement := (f, c) -> f + scalarHL(hlRing f, c)

Number - HLSymmetricFunction := (c, f) -> scalarHL(hlRing f, c) - f
HLSymmetricFunction - Number := (f, c) -> f - scalarHL(hlRing f, c)
RingElement - HLSymmetricFunction := (c, f) -> scalarHL(hlRing f, c) - f
HLSymmetricFunction - RingElement := (f, c) -> f - scalarHL(hlRing f, c)

HLSymmetricFunction * HLSymmetricFunction := (f, g) -> (
    if hlRing f =!= hlRing g then error "expected elements in the same HallLittlewood ring";
    A := hlRing f;
    K := A#"CoefficientRing";
    ans := new MutableHashTable;
    for a in pairs hlTerms f do for b in pairs hlTerms g do (
        mon := sortMonomial((first a) | (first b));
        old := if ans#?mon then ans#mon else 0_K;
        ans#mon = old + (last a) * (last b);
        if ans#mon == 0_K then remove(ans, mon);
        );
    newHL(A, new HashTable from pairs ans)
    )

sumHL = (A, L) -> (
    K := A#"CoefficientRing";
    ans := new MutableHashTable;
    for f in L do (
        if hlRing f =!= A then error "expected elements in the same HallLittlewood ring";
        for entry in pairs hlTerms f do (
            mon := first entry;
            old := if ans#?mon then ans#mon else 0_K;
            ans#mon = old + last entry;
            if ans#mon == 0_K then remove(ans, mon);
            );
        );
    newHL(A, new HashTable from pairs ans)
    )

sumHLMixedList = L -> (
    pos := positions(L, x -> instance(x, HLSymmetricFunction));
    if #pos == 0 then return null;
    A := hlRing L#(first pos);
    K := A#"CoefficientRing";
    ans := new MutableHashTable;
    addTerm := (mon, coeff) -> (
        coeff = promote(coeff, K);
        if coeff != 0_K then (
            old := if ans#?mon then ans#mon else 0_K;
            ans#mon = old + coeff;
            if ans#mon == 0_K then remove(ans, mon);
            );
        );
    for x in L do (
        if instance(x, HLSymmetricFunction) then (
            if hlRing x =!= A then error "expected elements in the same HallLittlewood ring";
            for entry in pairs hlTerms x do addTerm(first entry, last entry);
            )
        else if instance(x, Number) or instance(x, RingElement) then addTerm({}, x)
        else return null;
        );
    newHL(A, new HashTable from pairs ans)
    )

sum List := L -> (
    if #L == 0 then return 0;
    hlSum := sumHLMixedList L;
    if hlSum =!= null then return hlSum;
    ans := first L;
    for x in drop(L, 1) do ans = ans + x;
    ans
    )

productHL = (A, L) -> (
    ans := oneHL A;
    for f in L do ans = ans * f;
    ans
    )

HLSymmetricFunction ^ ZZ := (f, n) -> (
    if n < 0 then error "negative powers are not supported";
    productHL(hlRing f, apply(1..n, i -> f))
    )

coefficientIsNegative = c -> substring(0, 1, toString c) == "-"

indexListString = L -> "{" | demark(",", apply(L, toString)) | "}"

atomToString = atom -> (
    (basis, idx) := parseAtom atom;
    if isSkewBasis basis then basis | "_(" | indexListString(idx#0) | "," | indexListString(idx#1) | ")"
    else basis | "_" | if #idx == 1 then toString(idx#0) else "{" | demark(",", apply(idx, toString)) | "}"
    )

basisDisplayRank = basis -> (
    order := {"Q", "B", "P", "R", "q", "b", "skewQ", "skewB", "skewP", "skewR",
        "S", "Somega", "skewS", "skewSomega", "h", "e", "p", "m", "f"};
    pos := positions(order, b -> b == basis);
    if #pos == 0 then 1000 else first pos
    )

indexDisplayGreater = (lambda, mu) -> (
    n := max(#lambda, #mu);
    for i from 0 to n-1 do (
        a := if i < #lambda then lambda#i else 0;
        b := if i < #mu then mu#i else 0;
        if a > b then return true;
        if a < b then return false;
        );
    false
    )

atomDisplayLess = (a, b) -> (
    (basisA, idxA) := parseAtom a;
    (basisB, idxB) := parseAtom b;
    rankA := basisDisplayRank basisA;
    rankB := basisDisplayRank basisB;
    if rankA < rankB then return true;
    if rankA > rankB then return false;
    if isSkewBasis basisA then (
        if indexDisplayGreater(idxA#0, idxB#0) then return true;
        if indexDisplayGreater(idxB#0, idxA#0) then return false;
        indexDisplayGreater(idxA#1, idxB#1)
        )
    else indexDisplayGreater(idxA, idxB)
    )

insertAtomDisplay = (L, atom) -> (
    out := {};
    inserted := false;
    for x in L do (
        if not inserted and atomDisplayLess(atom, x) then (
            out = append(out, atom);
            inserted = true;
            );
        out = append(out, x);
        );
    if not inserted then out = append(out, atom);
    out
    )

displayUniqueAtoms = mon -> (
    atoms := {};
    for atom in mon do if not any(atoms, x -> x == atom) then atoms = insertAtomDisplay(atoms, atom);
    atoms
    )

atomCount = (mon, atom) -> #select(mon, x -> x == atom)

displayFactorData = mon -> apply(displayUniqueAtoms mon, atom -> {atom, atomCount(mon, atom)})

monomialDisplayLess = (monA, monB) -> (
    if #monA == 0 and #monB > 0 then return false;
    if #monB == 0 and #monA > 0 then return true;
    factorsA := displayFactorData monA;
    factorsB := displayFactorData monB;
    n := min(#factorsA, #factorsB);
    for i from 0 to n-1 do (
        atomA := factorsA#i#0;
        atomB := factorsB#i#0;
        if atomDisplayLess(atomA, atomB) then return true;
        if atomDisplayLess(atomB, atomA) then return false;
        expA := factorsA#i#1;
        expB := factorsB#i#1;
        if expA > expB then return true;
        if expA < expB then return false;
        );
    #factorsA > #factorsB
    )

termDisplayLess = (termA, termB) -> monomialDisplayLess(first termA, first termB)

indexDisplayKey = idx -> apply(trimTrailingZeros idx, i -> -i) | {0}

atomDisplayKey = atom -> (
    (basis, idx) := parseAtom atom;
    if isSkewBasis basis then
        {basisDisplayRank basis} | indexDisplayKey(idx#0) | indexDisplayKey(idx#1)
    else
        {basisDisplayRank basis} | indexDisplayKey idx
    )

factorDisplayKey = factor -> (
    atom := factor#0;
    exp := factor#1;
    atomDisplayKey atom | {-exp, 10000}
    )

monomialDisplayKey = mon -> (
    if #mon == 0 then return {1};
    key := {0};
    for factor in displayFactorData mon do key = key | factorDisplayKey factor;
    key | {10001}
    )

termDisplayKey = term -> monomialDisplayKey first term

insertTermDisplay = (L, term) -> (
    out := {};
    inserted := false;
    for x in L do (
        if not inserted and termDisplayLess(term, x) then (
            out = append(out, term);
            inserted = true;
            );
        out = append(out, x);
        );
    if not inserted then out = append(out, term);
    out
    )

displayTerms = f -> (
    sort(pairs hlTerms f, term -> termDisplayKey term)
    )

compactAtomPowerString = (atom, n) -> atomToString atom | (if n == 1 then "" else "^" | toString n)

compactMonomialFactors = mon -> (
    if #mon == 0 then return {};
    apply(displayUniqueAtoms mon, atom -> compactAtomPowerString(atom, atomCount(mon, atom)))
    )

termMonomialString = mon -> if #mon == 0 then "1" else demark("", compactMonomialFactors mon)

indexExpression = idx -> (
    if #idx == 1 then expression(idx#0)
    else expression("{" | demark(",", apply(idx, toString)) | "}")
    )

atomToExpression = atom -> (
    (basis, idx) := parseAtom atom;
    if isSkewBasis basis then
        (expression basis) _ (expression("(" | indexListString(idx#0) | "," | indexListString(idx#1) | ")"))
    else
        (expression basis) _ (indexExpression idx)
    )

atomPowerNet = (atom, n) -> (
    expr := atomToExpression atom;
    if n == 1 then net expr else net(expr ^ (expression n))
    )

termMonomialNet = mon -> (
    if #mon == 0 then return net "1";
    factors := apply(displayUniqueAtoms mon, atom -> atomPowerNet(atom, atomCount(mon, atom)));
    ans := first factors;
    for f in drop(factors, 1) do ans = ans | f;
    ans
    )

coefficientNeedsParens = c -> (
    s := toString c;
    any(toList(0..#s-1), i -> (
        ch := substring(i, 1, s);
        ch == "+" or (ch == "-" and i > 0)
        ))
    )

coefficientStringForProduct = c -> (
    s := toString c;
    if coefficientNeedsParens c then "(" | s | ")" else s
    )

coefficientNetForProduct = c -> (
    if coefficientNeedsParens c then net("(" | toString c | ")") else net c
    )

termToString = term -> (
    (mon, coeff) := term;
    monString := termMonomialString mon;
    coeff = if coefficientIsNegative coeff then -coeff else coeff;
    if coeff == 1 then monString
    else if monString == "1" then toString coeff
    else coefficientStringForProduct coeff | monString
    )

toString HLSymmetricFunction := f -> (
    if #keys hlTerms f == 0 then "0"
    else (
        ans := "";
        firstTerm := true;
        for term in displayTerms f do (
            neg := coefficientIsNegative last term;
            body := termToString term;
            ans = if firstTerm
                then (if neg then "-" | body else body)
                else ans | (if neg then " - " else " + ") | body;
            firstTerm = false;
            );
        ans
        )
    )

termToNet = term -> (
    (mon, coeff) := term;
    monNet := termMonomialNet mon;
    coeff = if coefficientIsNegative coeff then -coeff else coeff;
    if coeff == 1 then monNet
    else if #mon == 0 then net coeff
    else coefficientNetForProduct coeff | monNet
    )

hlPrintWidth = () -> if printWidth == 0 then 79 else printWidth

hlDisplayLineLimit = 8

dashNet = n -> (
    if n < 1 then n = 1;
    net concatenate apply(toList(1..n), i -> "-")
    )

signedTermNet = (body, neg, firstTerm, lineStart) -> (
    if firstTerm then (
        if neg then net "-" | body else body
        )
    else if lineStart then (
        net(if neg then "- " else "+ ") | body
        )
    else net(if neg then " - " else " + ") | body
    )

moreTermsNet = n -> net("+ " | toString n | " more " | (if n == 1 then "term" else "terms"))

wrapTermNets = terms -> (
    maxWidth := hlPrintWidth();
    lines := {};
    current := net "";
    firstTerm := true;
    omitted := 0;
    for i from 0 to #terms-1 do (
        term := terms#i;
        neg := coefficientIsNegative last term;
        body := termToNet term;
        piece := signedTermNet(body, neg, firstTerm, false);
        startPiece := signedTermNet(body, neg, firstTerm, true);
        if firstTerm then current = piece
        else if width(current | piece) <= maxWidth then current = current | piece
        else (
            if #lines + 1 >= hlDisplayLineLimit then (
                omitted = #terms - i;
                break;
                );
            lines = append(lines, current);
            current = startPiece;
            );
        firstTerm = false;
        );
    lines = append(lines, current);
    ans := first lines;
    sep := dashNet maxWidth;
    for line in drop(lines, 1) do ans = ans || sep || line;
    if omitted > 0 then ans = ans || sep || moreTermsNet omitted;
    ans
    )

net HLSymmetricFunction := f -> (
    if #keys hlTerms f == 0 then net "0"
    else wrapTermNets displayTerms f
    )

HLSymmetricFunction#{Standard,Print} = f -> (
    oprompt := concatenate(interpreterDepth:"o", toString lineNumber, " = ");
    << endl << (net oprompt | net f) << endl;
    )

-------------------------------------------------------------------------------
-- Alphabet variables, Adams operations, and coefficient series
-------------------------------------------------------------------------------

adamsCoefficient = method()
adamsCoefficient(HLSymmetricRing, ZZ, RingElement) := (A, n, c) -> (
    K := A#"CoefficientRing";
    cc := promote(c, K);
    if #A#"AlphabetVariables" == 0 then return cc;
    substitute(cc, apply(A#"AlphabetVariables", z -> z => z^n))
    )
adamsCoefficient(HLSymmetricRing, ZZ, Number) := (A, n, c) -> adamsCoefficient(A, n, promote(c, A#"CoefficientRing"))

coefficientVariableInBaseRing = (A, z) -> substitute(promote(z, A#"CoefficientRing"), A#"BaseCoefficientRing")

polyCoefficientInVariable = (P, z, n) -> (
    R := ring P;
    if n < 0 or P == 0_R then return 0_R;
    if n > degree(z, P) then return 0_R;
    coefficient(z^n, P)
    )

polyMinDegreeInVariable = (P, z) -> (
    R := ring P;
    if P == 0_R then return null;
    d := degree(z, P);
    for i from 0 to d do if polyCoefficientInVariable(P, z, i) != 0_R then return i;
    null
    )

coefficientSeriesCoefficient = (A, c, z, n) -> (
    K := A#"CoefficientRing";
    R := A#"BaseCoefficientRing";
    zz := coefficientVariableInBaseRing(A, z);
    cc := promote(c, K);
    num := numerator cc;
    den := denominator cc;
    denShift := polyMinDegreeInVariable(den, zz);
    if denShift === null then error "zero denominator in coefficient";
    denUnit := den // (zz^denShift);
    den0 := polyCoefficientInVariable(denUnit, zz, 0);
    if den0 == 0_R then error "denominator is not expandable as a Laurent series in the chosen variable";
    target := n + denShift;
    if target < 0 then return 0_K;
    coeffs := new MutableList from apply(0..target, i -> 0_K);
    for k from 0 to target do (
        value := promote(polyCoefficientInVariable(num, zz, k), K);
        for i from 1 to k do
            value = value - promote(polyCoefficientInVariable(denUnit, zz, i), K) * coeffs#(k-i);
        coeffs#k = value / promote(den0, K);
        );
    coeffs#target
    )

coefficientTermHL = (A, mon) -> newHL(A, new HashTable from {mon => 1_(A#"CoefficientRing")})

seriesCoefficient = method()
seriesCoefficient(HLSymmetricFunction, RingElement, ZZ) := (F, z, n) -> (
    A := hlRing F;
    ans := zeroHL A;
    for term in pairs hlTerms F do (
        c := coefficientSeriesCoefficient(A, last term, z, n);
        if c != 0_(A#"CoefficientRing") then ans = ans + c * coefficientTermHL(A, first term);
        );
    ans
    )

seriesTerms = method(Options => {DegreeLimit => null, LowerLimit => 0})
seriesTerms(HLSymmetricFunction, RingElement) := opts -> (F, z) -> (
    A := hlRing F;
    N := if opts.DegreeLimit === null then A#"DegreeLimit" else opts.DegreeLimit;
    L := opts.LowerLimit;
    terms := new MutableHashTable;
    for n from L to N do (
        c := seriesCoefficient(F, z, n);
        if #keys hlTerms c > 0 then terms#n = c;
        );
    new HashTable from pairs terms
    )

seriesCollect = method(Options => {DegreeLimit => null, LowerLimit => 0})
seriesCollect(HLSymmetricFunction, RingElement) := opts -> (F, z) -> (
    A := hlRing F;
    N := if opts.DegreeLimit === null then A#"DegreeLimit" else opts.DegreeLimit;
    L := opts.LowerLimit;
    new HLSeries from hashTable {
        "Ring" => A,
        "Variable" => promote(z, A#"CoefficientRing"),
        "LowerLimit" => L,
        "DegreeLimit" => N,
        "Terms" => seriesTerms(F, z, DegreeLimit => N, LowerLimit => L)
        }
    )

seriesTruncate = method(Options => {DegreeLimit => null, LowerLimit => 0})
seriesTruncate(HLSymmetricFunction, RingElement) := opts -> (F, z) -> (
    A := hlRing F;
    K := A#"CoefficientRing";
    N := if opts.DegreeLimit === null then A#"DegreeLimit" else opts.DegreeLimit;
    L := opts.LowerLimit;
    zz := promote(z, K);
    ans := zeroHL A;
    for entry in pairs seriesTerms(F, z, DegreeLimit => N, LowerLimit => L) do
        ans = ans + zz^(first entry) * last entry;
    ans
    )

hlSeriesTerms = S -> S#"Terms"

seriesVariableString = z -> toString z

seriesPowerString = (z, n) -> (
    s := seriesVariableString z;
    if n == 0 then ""
    else if n == 1 then s
    else s | "^" | toString n
    )

seriesCoefficientNeedsParens = f -> #keys hlTerms f > 1

seriesTermString = (z, entry) -> (
    n := first entry;
    c := last entry;
    coeffString := toString c;
    zString := seriesPowerString(z, n);
    if n == 0 then coeffString
    else (
        left := if seriesCoefficientNeedsParens c then "(" | coeffString | ")" else coeffString;
        if coeffString == "1" then zString else left | zString
        )
    )

toString HLSeries := S -> (
    H := hlSeriesTerms S;
    if #keys H == 0 then return "0";
    terms := {};
    for n in sort keys H do terms = append(terms, n => H#n);
    ans := "";
    firstTerm := true;
    for entry in terms do (
        neg := substring(0, 1, toString last entry) == "-";
        body := seriesTermString(S#"Variable", if neg then first entry => -(last entry) else entry);
        ans = if firstTerm
            then (if neg then "-" | body else body)
            else ans | (if neg then " - " else " + ") | body;
        firstTerm = false;
        );
    if S#"DegreeLimit" =!= null then ans = ans | " + O(" | seriesPowerString(S#"Variable", S#"DegreeLimit" + 1) | ")";
    ans
    )

net HLSeries := S -> net toString S

-------------------------------------------------------------------------------
-- Rings and indexed basis families
-------------------------------------------------------------------------------

hallLittlewoodRing = method(Options => {DegreeLimit => 20, Parameter => getSymbol "t", AlphabetVariables => {}})
hallLittlewoodRing Ring := opts -> K -> (
    FF := frac K;
    param := if instance(opts.Parameter, Symbol) then FF_0 else promote(opts.Parameter, FF);
    alph := {};
    for z in prepend(param, apply(opts.AlphabetVariables, z -> promote(z, FF))) do
        if not any(alph, w -> w == z) then alph = append(alph, z);
    A := new HLSymmetricRing from hashTable {
        "BaseCoefficientRing" => K,
        "CoefficientRing" => FF,
        "DegreeLimit" => opts.DegreeLimit,
        "Parameter" => param,
        "AlphabetVariables" => alph,
        "Caches" => new MutableHashTable
        };
    Core$use A;
    A
    )
degreeLimit = method()
degreeLimit HLSymmetricRing := A -> A#"DegreeLimit"

hlParameter = method()
hlParameter HLSymmetricRing := A -> A#"Parameter"

alphabetVariables = method()
alphabetVariables HLSymmetricRing := A -> A#"AlphabetVariables"

HLIndexedVariableTable _ Thing := (x, i) -> x#symbol _ i

basisElement = (A, basis, idx) -> (
    idx = trimTrailingZeros idx;
    checkDegree(A, idx);
    newHL(A, new HashTable from {{makeAtom(basis, idx)} => 1_(A#"CoefficientRing")})
    )

lowercaseElement = (A, basis, idx) -> (
    idx = toListIndex idx;
    if #idx == 0 then return oneHL A;
    productHL(A, apply(idx, i -> (
        if i < 0 then zeroHL A
        else if i == 0 then oneHL A
        else (
            checkDegree(A, {i});
            basisElement(A, basis, {i})
            )
        )))
    )

monomialElement = (A, idx) -> (
    idx = trimTrailingZeros idx;
    if any(idx, i -> i < 0) then return zeroHL A;
    idx = normalizePartition idx;
    if #idx == 0 then return oneHL A;
    checkDegree(A, idx);
    basisElement(A, "m", idx)
    )

forgottenElement = (A, idx) -> (
    idx = trimTrailingZeros idx;
    if any(idx, i -> i < 0) then return zeroHL A;
    idx = normalizePartition idx;
    if #idx == 0 then return oneHL A;
    checkDegree(A, idx);
    basisElement(A, "f", idx)
    )

toSkewIndex = idx -> (
    if instance(idx, Sequence) then idx = toList idx;
    if not instance(idx, List) or #idx != 2 then error "expected a skew index of the form ({lambda},{mu})";
    if not instance(idx#0, List) or not instance(idx#1, List) then error "expected a skew index of the form ({lambda},{mu})";
    {idx#0, idx#1}
    )

skewBasisElement = (A, basis, lambda, mu) -> (
    checkDegree(A, lambda);
    checkDegree(A, mu);
    newHL(A, new HashTable from {{makeSkewAtom(basis, lambda, mu)} => 1_(A#"CoefficientRing")})
    )

autoSimplifySkew = (A, basis, lambda, mu) -> skewBasisElement(A, basis, lambda, mu)

skewElement = (A, basis, idx) -> (
    idx = toSkewIndex idx;
    lambda := trimTrailingZeros idx#0;
    mu := trimTrailingZeros idx#1;
    autoSimplifySkew(A, basis, lambda, mu)
    )

capitalElement = (A, basis, idx) -> (
    idx = trimTrailingZeros idx;
    if #idx == 0 then return oneHL A;
    checkDegree(A, idx);
    basisElement(A, basis, idx)
    )

Core$use HLSymmetricRing := A -> (
    makeTable := (sym, basis, handler) -> (
        T := new HLIndexedVariableTable from sym;
        T#"Ring" = A;
        T#"Basis" = basis;
        T#symbol _ = idx -> handler(A, basis, idx);
        globalAssign(sym, T);
        );
    makeTable(getSymbol "p", "p", lowercaseElement);
    makeTable(getSymbol "h", "h", lowercaseElement);
    makeTable(getSymbol "e", "e", lowercaseElement);
    makeTable(getSymbol "q", "q", lowercaseElement);
    makeTable(getSymbol "b", "b", lowercaseElement);
    makeTable(getSymbol "m", "m", (A,basis,idx) -> monomialElement(A, idx));
    makeTable(getSymbol "f", "f", (A,basis,idx) -> forgottenElement(A, idx));
    makeTable(getSymbol "S", "S", capitalElement);
    makeTable(getSymbol "Somega", "Somega", capitalElement);
    makeTable(getSymbol "P", "P", capitalElement);
    makeTable(getSymbol "R", "R", capitalElement);
    makeTable(getSymbol "Q", "Q", capitalElement);
    makeTable(getSymbol "B", "B", capitalElement);
    makeTable(getSymbol "skewS", "skewS", skewElement);
    makeTable(getSymbol "skewSomega", "skewSomega", skewElement);
    makeTable(getSymbol "skewP", "skewP", skewElement);
    makeTable(getSymbol "skewR", "skewR", skewElement);
    makeTable(getSymbol "skewQ", "skewQ", skewElement);
    makeTable(getSymbol "skewB", "skewB", skewElement);
    for z in A#"AlphabetVariables" do globalAssign(getSymbol toString z, z);
    A
    )

-------------------------------------------------------------------------------
-- Hash arithmetic in the power-sum basis
-------------------------------------------------------------------------------

addHash = (A, H, Khash) -> (
    K := A#"CoefficientRing";
    ans := new MutableHashTable from pairs H;
    for entry in pairs Khash do (
        key := normalizePartition first entry;
        old := if ans#?key then ans#key else 0_K;
        ans#key = old + promote(last entry, K);
        if ans#key == 0_K then remove(ans, key);
        );
    new HashTable from pairs ans
    )

scaleHash = (A, c, H) -> (
    K := A#"CoefficientRing";
    cc := promote(c, K);
    if cc == 0_K then return new HashTable from {};
    new HashTable from select(apply(pairs H, entry -> first entry => cc * last entry), e -> last e != 0_K)
    )

mulHash = (A, H, Khash) -> (
    K := A#"CoefficientRing";
    ans := new MutableHashTable;
    for a in pairs H do for b in pairs Khash do (
        key := normalizePartition((first a) | (first b));
        old := if ans#?key then ans#key else 0_K;
        ans#key = old + (last a) * (last b);
        if ans#key == 0_K then remove(ans, key);
        );
    new HashTable from pairs ans
    )

productHash = (A, L) -> (
    ans := new HashTable from {{} => 1_(A#"CoefficientRing")};
    for H in L do ans = mulHash(A, ans, H);
    ans
    )

fromHashMonomial = (A, basis, idx) -> (
    if basis == "p" or basis == "h" or basis == "e" or basis == "q" or basis == "b" then (
        idx = toListIndex idx;
        if any(idx, i -> i < 0) then return null;
        for i in idx do if i > 0 then checkDegree(A, {i});
        return sortMonomial apply(select(idx, i -> i > 0), i -> makeAtom(basis, {i}));
        );
    if basis == "m" or basis == "f" then (
        idx = trimTrailingZeros idx;
        if any(idx, i -> i < 0) then return null;
        idx = normalizePartition idx;
        if #idx > 0 then checkDegree(A, idx);
        return if #idx == 0 then {} else {makeAtom(basis, idx)};
        );
    idx = trimTrailingZeros idx;
    if #idx > 0 then checkDegree(A, idx);
    if #idx == 0 then {} else {makeAtom(basis, idx)}
    )

fromHash = (A, basis, H) -> (
    K := A#"CoefficientRing";
    terms := new MutableHashTable;
    for entry in pairs H do (
        coeff := promote(last entry, K);
        if coeff != 0_K then (
            mon := fromHashMonomial(A, basis, first entry);
            if mon =!= null then (
                old := if terms#?mon then terms#mon else 0_K;
                terms#mon = old + coeff;
                if terms#mon == 0_K then remove(terms, mon);
                );
            );
        );
    newHL(A, new HashTable from pairs terms)
    )

-------------------------------------------------------------------------------
-- p-expansions of bases
-------------------------------------------------------------------------------

pHashOfP = (A, lambda) -> new HashTable from {normalizePartition lambda => 1_(A#"CoefficientRing")}

hOnePHash = (A, n) -> (
    if n < 0 then return new HashTable from {};
    if n == 0 then return new HashTable from {{} => 1_(A#"CoefficientRing")};
    new HashTable from apply(hlPartitions n, lambda -> lambda => 1_(A#"CoefficientRing") / zCoefficient(A, lambda))
    )

eOnePHash = (A, n) -> (
    if n < 0 then return new HashTable from {};
    if n == 0 then return new HashTable from {{} => 1_(A#"CoefficientRing")};
    K := A#"CoefficientRing";
    new HashTable from apply(hlPartitions n, lambda -> lambda => promote((-1)^(n - #lambda), K) / zCoefficient(A, lambda))
    )

qOnePHash = (A, n) -> (
    if n < 0 then return new HashTable from {};
    if n == 0 then return new HashTable from {{} => 1_(A#"CoefficientRing")};
    K := A#"CoefficientRing";
    t := hlParameter A;
    new HashTable from apply(hlPartitions n, lambda ->
        lambda => product(lambda, i -> 1_K - t^i) / zCoefficient(A, lambda))
    )

bOnePHash = (A, n) -> (
    if n < 0 then return new HashTable from {};
    if n == 0 then return new HashTable from {{} => 1_(A#"CoefficientRing")};
    K := A#"CoefficientRing";
    t := hlParameter A;
    new HashTable from apply(hlPartitions n, lambda ->
        lambda => product(lambda, i -> promote((-1)^(i-1), K) * (1_K - t^i)) / zCoefficient(A, lambda))
    )

lowercasePHash = (A, basis, idx) -> (
    idx = trimTrailingZeros idx;
    if any(idx, i -> i < 0) then return new HashTable from {};
    if #idx == 0 then return new HashTable from {{} => 1_(A#"CoefficientRing")};
    productHash(A, apply(idx, i ->
        if basis == "p" then pHashOfP(A, {i})
        else if basis == "h" then hOnePHash(A, i)
        else if basis == "e" then eOnePHash(A, i)
        else if basis == "q" then qOnePHash(A, i)
        else if basis == "b" then bOnePHash(A, i)
        else error "unknown lowercase basis"))
    )

assignmentCount = (parts, targets) -> (
    if #parts == 0 then return if all(targets, x -> x == 0) then 1 else 0;
    a := first parts;
    rest := drop(parts, 1);
    total := 0;
    for i from 0 to #targets-1 do if targets#i >= a then (
        nextTargets := apply(0..#targets-1, j -> if j == i then targets#j - a else targets#j);
        total = total + assignmentCount(rest, nextTargets);
        );
    total
    )

pToMonomialCoefficient = (lambda, mu) -> (
    lambda = normalizePartition lambda;
    mu = normalizePartition mu;
    if partitionWeight lambda != partitionWeight mu then return 0;
    assignmentCount(lambda, mu)
    )

solveSquareSystem = (K, M, v) -> (
    n := #v;
    if n == 0 then return {};
    A := new MutableList from apply(n, i -> new MutableList from (M#i | {v#i}));
    for col from 0 to n-1 do (
        pivot := null;
        for r from col to n-1 do if pivot === null and A#r#col != 0_K then pivot = r;
        if pivot === null then error "basis conversion matrix is singular";
        if pivot != col then (
            tmp := A#col; A#col = A#pivot; A#pivot = tmp;
            );
        pivotValue := A#col#col;
        for c from col to n do A#col#c = A#col#c / pivotValue;
        for r from 0 to n-1 do if r != col then (
            factor := A#r#col;
            if factor != 0_K then for c from col to n do A#r#c = A#r#c - factor * A#col#c;
            );
        );
    apply(n, i -> A#i#n)
    )

mPHash = (A, lambda) -> (
    lambda = normalizePartition lambda;
    d := partitionWeight lambda;
    parts := hlPartitions d;
    K := A#"CoefficientRing";
    M := apply(parts, rowPart -> apply(parts, colPart -> promote(pToMonomialCoefficient(colPart, rowPart), K)));
    v := apply(parts, rowPart -> if rowPart == lambda then 1_K else 0_K);
    coeffs := solveSquareSystem(K, M, v);
    ans := new MutableHashTable;
    for i from 0 to #parts-1 do if coeffs#i != 0_K then ans#(parts#i) = coeffs#i;
    new HashTable from pairs ans
    )

omegaPHash = (A, H) -> (
    K := A#"CoefficientRing";
    new HashTable from apply(pairs H, entry -> (
        lambda := first entry;
        lambda => promote((-1)^(partitionWeight lambda - partitionLength lambda), K) * last entry
        ))
    )

forgottenPHash = (A, lambda) -> omegaPHash(A, mPHash(A, lambda))

sfDet = M -> (
    n := #M;
    A := hlRing M#0#0;
    if n == 0 then return oneHL A;
    if n == 1 then return M#0#0;
    sumHL(A, apply(0..n-1, j -> (-1)^j * M#0#j * sfDet apply(1..n-1, r ->
        apply(select(0..n-1, c -> c != j), c -> M#r#c))))
    )

schurToH = (A, alpha) -> (
    alpha = trimTrailingZeros alpha;
    if #alpha == 0 then return oneHL A;
    ell := #alpha;
    sfDet apply(0..ell-1, i -> apply(0..ell-1, j -> lowercaseElement(A, "h", {alpha#i - i + j})))
    )

hHashFromHExpression = (A, F) -> (
    K := A#"CoefficientRing";
    ans := new MutableHashTable;
    for term in pairs hlTerms F do (
        mon := first term;
        key := {};
        for atom in mon do (
            (basis, idx) := parseAtom atom;
            if basis != "h" then error "expected an expression in the h basis";
            key = key | idx;
            );
        key = normalizePartition key;
        old := if ans#?key then ans#key else 0_K;
        ans#key = old + last term;
        if ans#key == 0_K then remove(ans, key);
        );
    new HashTable from pairs ans
    )

schurHHash = (A, lambda) -> (
    cache := A#"Caches";
    cacheKey := {"schurHHash", trimTrailingZeros lambda};
    if cache#?cacheKey then return cache#cacheKey;
    ans := hHashFromHExpression(A, schurToH(A, lambda));
    cache#cacheKey = ans;
    ans
    )

lexLessPartition = (lambda, mu) -> (
    n := max(#lambda, #mu);
    for i from 0 to n-1 do (
        a := if i < #lambda then lambda#i else 0;
        b := if i < #mu then mu#i else 0;
        if a < b then return true;
        if a > b then return false;
        );
    false
    )

leadingHPartition = H -> (
    ks := keys H;
    if #ks == 0 then error "expected a nonzero h expansion";
    lead := first ks;
    for key in drop(ks, 1) do if lexLessPartition(key, lead) then lead = key;
    lead
    )

schurHashFromHHash = (A, H) -> (
    K := A#"CoefficientRing";
    current := H;
    ans := new MutableHashTable;
    while #keys current > 0 do (
        lambda := leadingHPartition current;
        c := promote(current#lambda, K);
        ans#lambda = (if ans#?lambda then ans#lambda else 0_K) + c;
        if ans#lambda == 0_K then remove(ans, lambda);
        current = addHash(A, current, scaleHash(A, -c, schurHHash(A, lambda)));
        );
    new HashTable from pairs ans
    )

schurBasisIndex = F -> (
    if #keys hlTerms F != 1 then error "expected a single Schur basis element";
    K := (hlRing F)#"CoefficientRing";
    term := first pairs hlTerms F;
    if last term != 1_K then error "expected a single Schur basis element with coefficient 1";
    mon := first term;
    if #mon != 1 then error "expected a single Schur basis element";
    (basis, idx) := parseAtom first mon;
    if basis != "S" then error "expected a single Schur basis element";
    idx
    )

multSchur = method()
multSchur(HLSymmetricFunction, HLSymmetricFunction) := (F, G) -> (
    if hlRing F =!= hlRing G then error "expected elements in the same HallLittlewood ring";
    A := hlRing F;
    lambda := schurBasisIndex F;
    mu := schurBasisIndex G;
    fromHash(A, "S", schurHashFromHHash(A, mulHash(A, schurHHash(A, lambda), schurHHash(A, mu))))
    )

schurOmegaToE = (A, alpha) -> (
    alpha = trimTrailingZeros alpha;
    if #alpha == 0 then return oneHL A;
    ell := #alpha;
    sfDet apply(0..ell-1, i -> apply(0..ell-1, j -> lowercaseElement(A, "e", {alpha#i - i + j})))
    )

listEntry = (L, i) -> if i < #L then L#i else 0

skewSchurToH = (A, lambda, mu) -> (
    lambda = trimTrailingZeros lambda;
    mu = trimTrailingZeros mu;
    ell := max(#lambda, #mu);
    if ell == 0 then return oneHL A;
    sfDet apply(0..ell-1, i -> apply(0..ell-1, j ->
        lowercaseElement(A, "h", {listEntry(lambda, i) - listEntry(mu, j) - i + j})))
    )

skewSchurOmegaToE = (A, lambda, mu) -> (
    lambda = trimTrailingZeros lambda;
    mu = trimTrailingZeros mu;
    ell := max(#lambda, #mu);
    if ell == 0 then return oneHL A;
    sfDet apply(0..ell-1, i -> apply(0..ell-1, j ->
        lowercaseElement(A, "e", {listEntry(lambda, i) - listEntry(mu, j) - i + j})))
    )

raisingExpansion = (A, lambda) -> (
    lambda = trimTrailingZeros lambda;
    K := A#"CoefficientRing";
    t := hlParameter A;
    current := new MutableHashTable from {lambda => 1_K};
    ell := #lambda;
    for i from 0 to ell-2 do for j from i+1 to ell-1 do (
        next := new MutableHashTable;
        for entry in pairs current do (
            comp := first entry;
            coeff := last entry;
            maxRaise := max(comp#j, 0);
            for k from 0 to maxRaise do (
                newComp := comp;
                if k > 0 then newComp = apply(0..ell-1, r ->
                    if r == i then comp#r+k else if r == j then comp#r-k else comp#r);
                factor := if k == 0 then 1_K else (t - 1_K) * t^(k-1);
                old := if next#?newComp then next#newComp else 0_K;
                next#newComp = old + coeff * factor;
                if next#newComp == 0_K then remove(next, newComp);
                );
            );
        current = next;
        );
    new HashTable from pairs current
    )

hallLittlewoodCFactorList = (A, lambda) -> (
    K := A#"CoefficientRing";
    t := hlParameter A;
    lambda = normalizePartition lambda;
    ans := 1_K;
    for part in unique lambda do if part > 0 then (
        mult := partitionMultiplicity(lambda, part);
        for j from 1 to mult do ans = ans * (1_K - t^j);
        );
    ans
    )

hallCapitalPHash = (A, basis, alpha) -> (
    alpha = trimTrailingZeros alpha;
    if #alpha == 0 then return new HashTable from {{} => 1_(A#"CoefficientRing")};
    expansion := raisingExpansion(A, alpha);
    ans := new HashTable from {};
    for entry in pairs expansion do (
        H := lowercasePHash(A, if basis == "Q" then "q" else "b", first entry);
        ans = addHash(A, ans, scaleHash(A, last entry, H));
        );
    ans
    )

hallLittlewoodPFunctionPHash = (A, alpha) -> (
    alpha = trimTrailingZeros alpha;
    scaleHash(A, 1 / hallLittlewoodCFactorList(A, alpha), hallCapitalPHash(A, "Q", alpha))
    )

hallLittlewoodRFunctionPHash = (A, alpha) -> omegaPHash(A, hallLittlewoodPFunctionPHash(A, alpha))

generatorHashFromExpression = (A, generatorBasis, F) -> (
    K := A#"CoefficientRing";
    ans := new MutableHashTable;
    for term in pairs hlTerms F do (
        mon := first term;
        key := {};
        for atom in mon do (
            (basis, idx) := parseAtom atom;
            if basis != generatorBasis then error("expected an expression in the " | generatorBasis | " basis");
            key = key | idx;
            );
        key = normalizePartition key;
        old := if ans#?key then ans#key else 0_K;
        ans#key = old + last term;
        if ans#key == 0_K then remove(ans, key);
        );
    new HashTable from pairs ans
    )

raisingGeneratorHash = (A, lambda) -> (
    K := A#"CoefficientRing";
    ans := new MutableHashTable;
    for entry in pairs raisingExpansion(A, lambda) do (
        key := normalizePartition first entry;
        old := if ans#?key then ans#key else 0_K;
        ans#key = old + last entry;
        if ans#key == 0_K then remove(ans, key);
        );
    new HashTable from pairs ans
    )

triangularExpectedGenerator = basis -> (
    if basis == "S" then "h"
    else if basis == "Somega" then "e"
    else if basis == "Q" then "q"
    else if basis == "B" then "b"
    else error "expected one of the triangular bases S, Somega, Q, or B"
    )

triangularBasisGeneratorHash = (A, basis, lambda) -> (
    lambda = trimTrailingZeros lambda;
    cache := A#"Caches";
    cacheKey := {"triangularBasisGeneratorHash", basis, lambda};
    if cache#?cacheKey then return cache#cacheKey;
    ans := (
        if basis == "S" then generatorHashFromExpression(A, "h", schurToH(A, lambda))
        else if basis == "Somega" then generatorHashFromExpression(A, "e", schurOmegaToE(A, lambda))
        else if basis == "Q" or basis == "B" then raisingGeneratorHash(A, lambda)
        else error "expected one of the triangular bases S, Somega, Q, or B"
        );
    cache#cacheKey = ans;
    ans
    )

triangularReduce = method()
triangularReduce(HLSymmetricRing, String, String, HashTable) := (A, basis, generatorBasis, H) -> (
    expected := triangularExpectedGenerator basis;
    if generatorBasis != expected then error("basis " | basis | " is triangular in " | expected | ", not " | generatorBasis);
    K := A#"CoefficientRing";
    current := H;
    ans := new MutableHashTable;
    while #keys current > 0 do (
        lambda := leadingHPartition current;
        expansion := triangularBasisGeneratorHash(A, basis, lambda);
        leadCoeff := coeffInHash(expansion, lambda, K);
        if leadCoeff == 0_K then error "triangular expansion has zero leading coefficient";
        c := promote(current#lambda, K) / leadCoeff;
        ans#lambda = (if ans#?lambda then ans#lambda else 0_K) + c;
        if ans#lambda == 0_K then remove(ans, lambda);
        current = addHash(A, current, scaleHash(A, -c, expansion));
        );
    new HashTable from pairs ans
    )

toSFromh = method()
toSFromh HLSymmetricFunction := F -> (
    A := hlRing F;
    fromHash(A, "S", triangularReduce(A, "S", "h", generatorHashFromExpression(A, "h", F)))
    )

toSomegaFrome = method()
toSomegaFrome HLSymmetricFunction := F -> (
    A := hlRing F;
    fromHash(A, "Somega", triangularReduce(A, "Somega", "e", generatorHashFromExpression(A, "e", F)))
    )

toSFromp = method()
toSFromp HLSymmetricFunction := F -> toSFromh toHFromp F

toSomegaFromp = method()
toSomegaFromp HLSymmetricFunction := F -> toSomegaFrome toEFromp F

toQFromq = method()
toQFromq HLSymmetricFunction := F -> (
    A := hlRing F;
    fromHash(A, "Q", triangularReduce(A, "Q", "q", generatorHashFromExpression(A, "q", F)))
    )

toBFromb = method()
toBFromb HLSymmetricFunction := F -> (
    A := hlRing F;
    fromHash(A, "B", triangularReduce(A, "B", "b", generatorHashFromExpression(A, "b", F)))
    )

-------------------------------------------------------------------------------
-- Direct conversions from p
-------------------------------------------------------------------------------

sourceHash = (A, sourceBasis, F) -> generatorHashFromExpression(A, sourceBasis, F)

isExpressionInBasis = (basisName, F) -> (
    all(pairs hlTerms F, term -> all(first term, atom -> (
        (basis, idx) := parseAtom atom;
        basis == basisName
        )))
    )

oneRowGeneratorHash = (A, n) -> (
    K := A#"CoefficientRing";
    if n < 0 then return new HashTable from {};
    if n == 0 then return new HashTable from {{} => 1_K};
    new HashTable from {{n} => 1_K}
    )

expandOneRowConversion = (A, H, oneRowHash) -> (
    ans := new HashTable from {};
    for entry in pairs H do (
        expansion := productHash(A, apply(first entry, i -> oneRowHash(A, i)));
        ans = addHash(A, ans, scaleHash(A, last entry, expansion));
        );
    ans
    )

pOneHHash = (A, n) -> (
    cache := A#"Caches";
    cacheKey := {"pOneHHash", n};
    if cache#?cacheKey then return cache#cacheKey;
    K := A#"CoefficientRing";
    ans := (
        if n < 0 then new HashTable from {}
        else if n == 0 then new HashTable from {{} => 1_K}
        else (
            current := scaleHash(A, promote(n, K), oneRowGeneratorHash(A, n));
            for i from 1 to n-1 do
                current = addHash(A, current, scaleHash(A, -1_K,
                    mulHash(A, oneRowGeneratorHash(A, n-i), pOneHHash(A, i))));
            current
            )
        );
    cache#cacheKey = ans;
    ans
    )

pOneEHash = (A, n) -> (
    cache := A#"Caches";
    cacheKey := {"pOneEHash", n};
    if cache#?cacheKey then return cache#cacheKey;
    K := A#"CoefficientRing";
    ans := (
        if n < 0 then new HashTable from {}
        else if n == 0 then new HashTable from {{} => 1_K}
        else (
            current := scaleHash(A, promote((-1)^(n-1) * n, K), oneRowGeneratorHash(A, n));
            for i from 1 to n-1 do
                current = addHash(A, current, scaleHash(A, promote((-1)^(n+i-1), K),
                    mulHash(A, oneRowGeneratorHash(A, n-i), pOneEHash(A, i))));
            current
            )
        );
    cache#cacheKey = ans;
    ans
    )

pOneQGeneratorHash = (A, n) -> (
    cache := A#"Caches";
    cacheKey := {"pOneQGeneratorHash", n};
    if cache#?cacheKey then return cache#cacheKey;
    K := A#"CoefficientRing";
    t := hlParameter A;
    ans := (
        if n < 0 then new HashTable from {}
        else if n == 0 then new HashTable from {{} => 1_K}
        else (
            denom := 1_K - t^n;
            current := scaleHash(A, promote(n, K) / denom, oneRowGeneratorHash(A, n));
            for i from 1 to n-1 do
                current = addHash(A, current, scaleHash(A, -(1_K - t^i) / denom,
                    mulHash(A, oneRowGeneratorHash(A, n-i), pOneQGeneratorHash(A, i))));
            current
            )
        );
    cache#cacheKey = ans;
    ans
    )

pOneBGeneratorHash = (A, n) -> (
    cache := A#"Caches";
    cacheKey := {"pOneBGeneratorHash", n};
    if cache#?cacheKey then return cache#cacheKey;
    K := A#"CoefficientRing";
    t := hlParameter A;
    ans := (
        if n < 0 then new HashTable from {}
        else if n == 0 then new HashTable from {{} => 1_K}
        else (
            denom := promote((-1)^(n-1), K) * (1_K - t^n);
            current := scaleHash(A, promote(n, K) / denom, oneRowGeneratorHash(A, n));
            for i from 1 to n-1 do (
                a := promote((-1)^(i-1), K) * (1_K - t^i);
                current = addHash(A, current, scaleHash(A, -a / denom,
                    mulHash(A, oneRowGeneratorHash(A, n-i), pOneBGeneratorHash(A, i))));
                );
            current
            )
        );
    cache#cacheKey = ans;
    ans
    )

toHFrompHash = (A, F) -> expandOneRowConversion(A, sourceHash(A, "p", F), pOneHHash)

toEFrompHash = (A, F) -> expandOneRowConversion(A, sourceHash(A, "p", F), pOneEHash)

toQGeneratorFrompHash = (A, F) -> expandOneRowConversion(A, sourceHash(A, "p", F), pOneQGeneratorHash)

toBGeneratorFrompHash = (A, F) -> expandOneRowConversion(A, sourceHash(A, "p", F), pOneBGeneratorHash)

toHFromp = method()
toHFromp HLSymmetricFunction := F -> (
    A := hlRing F;
    fromHash(A, "h", toHFrompHash(A, F))
    )

toEFromp = method()
toEFromp HLSymmetricFunction := F -> (
    A := hlRing F;
    fromHash(A, "e", toEFrompHash(A, F))
    )

nativeHVariable = (R, n) -> (
    if n < 0 then return 0_R;
    if n == 0 then return 1_R;
    if n > numgens R then error "not enough h variables in native polynomial ring";
    R_(n-1)
    )

nativeMonomialFromPartition = (R, lambda) -> (
    m := 1_R;
    for part in lambda do if part > 0 then m = m * nativeHVariable(R, part);
    m
    )

hHashToNativePolynomial = (R, H) -> (
    ans := 0_R;
    for entry in pairs H do
        ans = ans + promote(last entry, R) * nativeMonomialFromPartition(R, first entry);
    ans
    )

nativePartitionFromMonomial = (R, m) -> (
    exps := first exponents m;
    lambda := {};
    for i from 0 to #exps-1 do for j from 1 to exps#i do lambda = prepend(i+1, lambda);
    lambda
    )

nativeLeadingHPartition = (R, f) -> (
    if f == 0_R then error "expected a nonzero native h polynomial";
    termList := terms f;
    lead := nativePartitionFromMonomial(R, leadMonomial first termList);
    for term in drop(termList, 1) do (
        lambda := nativePartitionFromMonomial(R, leadMonomial term);
        if lexLessPartition(lambda, lead) then lead = lambda;
        );
    lead
    )

nativeSchurHPolynomialUncached = (R, lambda) -> (
    lambda = trimTrailingZeros lambda;
    if #lambda == 0 then return 1_R;
    ell := #lambda;
    det matrix (apply(toList(0..ell-1), i ->
        apply(toList(0..ell-1), j -> nativeHVariable(R, lambda#i - i + j))))
    )

nativeSchurHReducerData = (R, cache, lambda) -> (
    lambda = trimTrailingZeros lambda;
    cacheKey := {"nativeSchurHReducerData", lambda};
    if cache#?cacheKey then return cache#cacheKey;
    expansion := nativeSchurHPolynomialUncached(R, lambda);
    leadMon := nativeMonomialFromPartition(R, lambda);
    leadCoeff := coefficient(leadMon, expansion);
    ans := {expansion, leadMon, leadCoeff};
    cache#cacheKey = ans;
    ans
    )

nativeSchurHPolynomial = (R, cache, lambda) -> (
    (nativeSchurHReducerData(R, cache, lambda))#0
    )

nativeTriangularSchurReduce = (A, R, f) -> (
    K := A#"CoefficientRing";
    current := f;
    ans := new MutableHashTable;
    cache := new MutableHashTable;
    while current != 0_R do (
        lambda := nativeLeadingHPartition(R, current);
        reducerData := nativeSchurHReducerData(R, cache, lambda);
        expansion := reducerData#0;
        leadMon := reducerData#1;
        leadCoeff := reducerData#2;
        if leadCoeff == 0_K then error "native Schur expansion has zero leading coefficient";
        c := coefficient(leadMon, current) / leadCoeff;
        ans#lambda = (if ans#?lambda then ans#lambda else 0_K) + c;
        if ans#lambda == 0_K then remove(ans, lambda);
        current = current - promote(c, R) * expansion;
        );
    new HashTable from pairs ans
    )

nativeGRevLexSchurReduce = (A, R, f) -> (
    K := A#"CoefficientRing";
    current := f;
    ans := new MutableHashTable;
    cache := new MutableHashTable;
    while current != 0_R do (
        leadMon := leadMonomial current;
        lambda := nativePartitionFromMonomial(R, leadMon);
        reducerData := nativeSchurHReducerData(R, cache, lambda);
        expansion := reducerData#0;
        leadCoeff := reducerData#2;
        if leadCoeff == 0_K then error "native Schur expansion has zero leading coefficient";
        c := coefficient(leadMon, current) / leadCoeff;
        ans#lambda = (if ans#?lambda then ans#lambda else 0_K) + c;
        if ans#lambda == 0_K then remove(ans, lambda);
        current = current - promote(c, R) * expansion;
        );
    new HashTable from pairs ans
    )

toStest = method()
toStest HLSymmetricFunction := F -> (
    A := hlRing F;
    pH := toPHash F;
    if #keys pH == 0 then return zeroHL A;
    N := max apply(keys pH, partitionWeight);
    if N == 0 then return fromHash(A, "S", pH);
    R := (A#"CoefficientRing")[apply(1..N, i -> getSymbol("HLh" | toString i)), MonomialOrder => Lex];
    hPoly := hHashToNativePolynomial(R, expandOneRowConversion(A, pH, pOneHHash));
    fromHash(A, "S", nativeTriangularSchurReduce(A, R, hPoly))
    )

toSgrevlexTest = method()
toSgrevlexTest HLSymmetricFunction := F -> (
    A := hlRing F;
    pH := toPHash F;
    if #keys pH == 0 then return zeroHL A;
    N := max apply(keys pH, partitionWeight);
    if N == 0 then return fromHash(A, "S", pH);
    R := (A#"CoefficientRing")[apply(1..N, i -> getSymbol("HLh" | toString i)), MonomialOrder => GRevLex];
    hPoly := hHashToNativePolynomial(R, expandOneRowConversion(A, pH, pOneHHash));
    fromHash(A, "S", nativeGRevLexSchurReduce(A, R, hPoly))
    )

chunkList = (L, n) -> (
    if n <= 0 then error "expected a positive chunk size";
    chunks := {};
    current := {};
    count := 0;
    for x in L do (
        current = append(current, x);
        count = count + 1;
        if count == n then (
            chunks = append(chunks, current);
            current = {};
            count = 0;
            );
        );
    if #current > 0 then chunks = append(chunks, current);
    chunks
    )

hlParallelThreadCount = () -> (
    n := maxAllowableThreads;
    if n < 1 then (
        n = numTBBThreads;
        if n < 1 then n = 1;
        );
    n
    )

automaticChunkSize = nTerms -> (
    threads := hlParallelThreadCount();
    max(4, (nTerms + threads - 1) // threads)
    )

toSChunkedTest = method(Options => {ChunkSize => null})
toSChunkedTest HLSymmetricFunction := opts -> F -> (
    A := hlRing F;
    pH := toPHash F;
    if #keys pH == 0 then return zeroHL A;
    N := max apply(keys pH, partitionWeight);
    if N == 0 then return fromHash(A, "S", pH);
    for i from 0 to N do pOneHHash(A, i);
    R := (A#"CoefficientRing")[apply(1..N, i -> getSymbol("HLh" | toString i)), MonomialOrder => GRevLex];
    chunkSize := if opts.ChunkSize === null then automaticChunkSize(#pairs pH) else opts.ChunkSize;
    if chunkSize < 4 then error "ChunkSize should be at least 4 for toSChunkedTest";
    chunks := chunkList(pairs pH, chunkSize);
    chunkHashes := parallelApply(chunks, chunk -> (
        chunkHash := new HashTable from chunk;
        hPoly := hHashToNativePolynomial(R, expandOneRowConversion(A, chunkHash, pOneHHash));
        nativeGRevLexSchurReduce(A, R, hPoly)
        ));
    ans := new HashTable from {};
    for H in chunkHashes do ans = addHash(A, ans, H);
    fromHash(A, "S", ans)
    )

horizontalStripAdditions = (mu, r) -> (
    mu = normalizePartition mu;
    if r < 0 then return {};
    if r == 0 then return {mu};
    ell := #mu + r;
    old := apply(0..ell-1, i -> if i < #mu then mu#i else 0);
    ans := {};
    build := (i, previous, remaining, current) -> (
        if i == ell then (
            if remaining == 0 then ans = append(ans, normalizePartition current);
            )
        else (
            upper := previous;
            lower := old#i;
            maxAdd := min(remaining, upper - lower);
            for add from 0 to maxAdd do (
                value := lower + add;
                ok := if i == 0 then true else value <= old#(i-1);
                if ok then build(i+1, value, remaining-add, append(current, value));
                );
            )
        );
    build(0, partitionWeight mu + r, r, {});
    unique ans
    )

pieriMultiplyOne = (A, r, H) -> (
    K := A#"CoefficientRing";
    ans := new MutableHashTable;
    for entry in pairs H do for nu in horizontalStripAdditions(first entry, r) do (
        old := if ans#?nu then ans#nu else 0_K;
        ans#nu = old + last entry;
        if ans#nu == 0_K then remove(ans, nu);
        );
    new HashTable from pairs ans
    )

hPartitionSchurPieriHash = (A, lambda) -> (
    lambda = normalizePartition lambda;
    cache := A#"Caches";
    cacheKey := {"hPartitionSchurPieriHash", lambda};
    if cache#?cacheKey then return cache#cacheKey;
    ans := new HashTable from {{} => 1_(A#"CoefficientRing")};
    for r in lambda do ans = pieriMultiplyOne(A, r, ans);
    cache#cacheKey = ans;
    ans
    )

hHashToSchurPieriHash = (A, H) -> (
    ans := new HashTable from {};
    for entry in pairs H do
        ans = addHash(A, ans, scaleHash(A, last entry, hPartitionSchurPieriHash(A, first entry)));
    ans
    )

toSPieriTest = method()
toSPieriTest HLSymmetricFunction := F -> (
    A := hlRing F;
    H := hHashToSchurPieriHash(A, expandOneRowConversion(A, toPHash F, pOneHHash));
    fromHash(A, "S", H)
    )

hHashLargestPart = H -> (
    r := 0;
    for key in keys H do for part in key do if part > r then r = part;
    r
    )

hHashCoefficientByPower = (A, H, r) -> (
    K := A#"CoefficientRing";
    coeffs := new MutableHashTable;
    maxDeg := 0;
    for entry in pairs H do (
        key := first entry;
        d := #select(key, part -> part == r);
        rem := select(key, part -> part != r);
        if d > maxDeg then maxDeg = d;
        if not coeffs#?d then coeffs#d = new MutableHashTable;
        old := if (coeffs#d)#?rem then (coeffs#d)#rem else 0_K;
        (coeffs#d)#rem = old + last entry;
        if (coeffs#d)#rem == 0_K then remove(coeffs#d, rem);
        );
    {coeffs, maxDeg}
    )

hCoefficientHash = (coeffs, d) -> (
    if coeffs#?d then new HashTable from pairs coeffs#d else new HashTable from {}
    )

schurHashFromHHashFast = (A, H) -> (
    K := A#"CoefficientRing";
    if #keys H == 0 then return new HashTable from {};
    r := hHashLargestPart H;
    if r == 0 then (
        c := if H#?{} then promote(H#{}, K) else 0_K;
        return if c == 0_K then new HashTable from {} else new HashTable from {{} => c};
        );
    data := hHashCoefficientByPower(A, H, r);
    coeffs := data#0;
    maxDeg := data#1;
    ans := schurHashFromHHashFast(A, hCoefficientHash(coeffs, maxDeg));
    d := maxDeg - 1;
    while d >= 0 do (
        ans = pieriMultiplyOne(A, r, ans);
        ans = addHash(A, ans, schurHashFromHHashFast(A, hCoefficientHash(coeffs, d)));
        d = d - 1;
        );
    ans
    )

toSfromhFast = method()
toSfromhFast HLSymmetricFunction := F -> (
    A := hlRing F;
    fromHash(A, "S", schurHashFromHHashFast(A, generatorHashFromExpression(A, "h", F)))
    )

skewQMHash = (A, lambda, mu) -> (
    lambda = trimTrailingZeros lambda;
    mu = trimTrailingZeros mu;
    d := partitionWeight lambda - partitionWeight mu;
    if d < 0 then return new HashTable from {};
    K := A#"CoefficientRing";
    Qlambda := capitalElement(A, "Q", lambda);
    Pmu := capitalElement(A, "P", mu);
    ans := new MutableHashTable;
    for nu in hlPartitions d do (
        c := hallInnerProduct(Qlambda, Pmu * lowercaseElement(A, "q", nu));
        if c != 0_K then ans#nu = c;
        );
    new HashTable from pairs ans
    )

skewQFunction = (A, lambda, mu) -> fromHash(A, "m", skewQMHash(A, lambda, mu))

skewBFHash = (A, lambda, mu) -> (
    lambda = trimTrailingZeros lambda;
    mu = trimTrailingZeros mu;
    d := partitionWeight lambda - partitionWeight mu;
    if d < 0 then return new HashTable from {};
    K := A#"CoefficientRing";
    Blambda := capitalElement(A, "B", lambda);
    Rmu := capitalElement(A, "R", mu);
    ans := new MutableHashTable;
    for nu in hlPartitions d do (
        c := hallInnerProduct(Blambda, Rmu * lowercaseElement(A, "b", nu));
        if c != 0_K then ans#nu = c;
        );
    new HashTable from pairs ans
    )

skewBFunction = (A, lambda, mu) -> fromHash(A, "f", skewBFHash(A, lambda, mu))

skewPFunctionPHash = (A, lambda, mu) -> (
    coeffs := toQHash skewQFunction(A, lambda, mu);
    toPHash fromHash(A, "P", coeffs)
    )

skewRFunctionPHash = (A, lambda, mu) -> (
    coeffs := toBHash skewBFunction(A, lambda, mu);
    toPHash fromHash(A, "R", coeffs)
    )

skewAtomPHash = (A, basis, idx) -> (
    lambda := idx#0;
    mu := idx#1;
    if basis == "skewS" then toPHash skewSchurToH(A, lambda, mu)
    else if basis == "skewSomega" then toPHash skewSchurOmegaToE(A, lambda, mu)
    else if basis == "skewQ" then toPHash skewQFunction(A, lambda, mu)
    else if basis == "skewB" then toPHash skewBFunction(A, lambda, mu)
    else if basis == "skewP" then skewPFunctionPHash(A, lambda, mu)
    else if basis == "skewR" then skewRFunctionPHash(A, lambda, mu)
    else error "unknown skew basis atom"
    )

atomPHash = (A, atom) -> (
    (basis, idx) := parseAtom atom;
    if basis == "p" or basis == "h" or basis == "e" or basis == "q" or basis == "b" then lowercasePHash(A, basis, idx)
    else if basis == "m" then mPHash(A, idx)
    else if basis == "f" then forgottenPHash(A, idx)
    else if basis == "S" then toPHash schurToH(A, idx)
    else if basis == "Somega" then toPHash schurOmegaToE(A, idx)
    else if basis == "P" then hallLittlewoodPFunctionPHash(A, idx)
    else if basis == "R" then hallLittlewoodRFunctionPHash(A, idx)
    else if basis == "Q" or basis == "B" then hallCapitalPHash(A, basis, idx)
    else if isSkewBasis basis then skewAtomPHash(A, basis, idx)
    else error "unknown basis atom"
    )

toPHash = method()
toPHash HLSymmetricFunction := f -> (
    A := hlRing f;
    ans := new HashTable from {};
    for term in pairs hlTerms f do (
        mon := first term;
        coeff := last term;
        H := productHash(A, apply(mon, atom -> atomPHash(A, atom)));
        ans = addHash(A, ans, scaleHash(A, coeff, H));
        );
    ans
    )

toP = method()
toP HLSymmetricFunction := f -> fromHash(hlRing f, "p", toPHash f)

-------------------------------------------------------------------------------
-- Basis conversion from p via transition matrices
-------------------------------------------------------------------------------

basisPHash = (A, basis, lambda) -> (
    lambda = normalizePartition lambda;
    cache := A#"Caches";
    cacheKey := {"basisPHash", basis, lambda};
    if cache#?cacheKey then return cache#cacheKey;
    ans := (
        if basis == "p" then pHashOfP(A, lambda)
        else if basis == "h" or basis == "e" or basis == "q" or basis == "b" then lowercasePHash(A, basis, lambda)
        else if basis == "m" then mPHash(A, lambda)
        else if basis == "f" then forgottenPHash(A, lambda)
        else if basis == "S" then toPHash schurToH(A, lambda)
        else if basis == "Somega" then toPHash schurOmegaToE(A, lambda)
        else if basis == "P" then hallLittlewoodPFunctionPHash(A, lambda)
        else if basis == "R" then hallLittlewoodRFunctionPHash(A, lambda)
        else if basis == "Q" or basis == "B" then hallCapitalPHash(A, basis, lambda)
        else error "unknown basis"
        );
    cache#cacheKey = ans;
    ans
    )

coeffInHash = (H, key, K) -> if H#?key then promote(H#key, K) else 0_K

toBasisHash = (basis, f) -> (
    A := hlRing f;
    K := A#"CoefficientRing";
    pExp := toPHash f;
    ans := new MutableHashTable;
    for d in unique apply(keys pExp, partitionWeight) do (
        parts := hlPartitions d;
        M := apply(parts, rowPart -> apply(parts, colPart ->
            coeffInHash(basisPHash(A, basis, colPart), rowPart, K)));
        v := apply(parts, rowPart -> coeffInHash(pExp, rowPart, K));
        coeffs := solveSquareSystem(K, M, v);
        for i from 0 to #parts-1 do if coeffs#i != 0_K then ans#(parts#i) = coeffs#i;
        );
    new HashTable from pairs ans
    )

toHHash = method()
toHHash HLSymmetricFunction := f -> (
    if isExpressionInBasis("p", f) then toHFrompHash(hlRing f, f)
    else toBasisHash("h", f)
    )

toEHash = method()
toEHash HLSymmetricFunction := f -> (
    if isExpressionInBasis("p", f) then toEFrompHash(hlRing f, f)
    else toBasisHash("e", f)
    )

toMHash = method(); toMHash HLSymmetricFunction := f -> toBasisHash("m", f)
toFHash = method(); toFHash HLSymmetricFunction := f -> toBasisHash("f", f)

toSHash = method()
toSHash HLSymmetricFunction := f -> (
    A := hlRing f;
    triangularReduce(A, "S", "h", expandOneRowConversion(A, toPHash f, pOneHHash))
    )

toSomegaHash = method()
toSomegaHash HLSymmetricFunction := f -> (
    A := hlRing f;
    triangularReduce(A, "Somega", "e", expandOneRowConversion(A, toPHash f, pOneEHash))
    )

toHallPHash = method(); toHallPHash HLSymmetricFunction := f -> toBasisHash("P", f)
toRHash = method(); toRHash HLSymmetricFunction := f -> toBasisHash("R", f)

toQHash = method()
toQHash HLSymmetricFunction := f -> (
    A := hlRing f;
    triangularReduce(A, "Q", "q", expandOneRowConversion(A, toPHash f, pOneQGeneratorHash))
    )

toBHash = method()
toBHash HLSymmetricFunction := f -> (
    A := hlRing f;
    triangularReduce(A, "B", "b", expandOneRowConversion(A, toPHash f, pOneBGeneratorHash))
    )

toH = method(); toH HLSymmetricFunction := f -> fromHash(hlRing f, "h", toHHash f)
toE = method(); toE HLSymmetricFunction := f -> fromHash(hlRing f, "e", toEHash f)
toM = method(); toM HLSymmetricFunction := f -> fromHash(hlRing f, "m", toMHash f)
toF = method(); toF HLSymmetricFunction := f -> fromHash(hlRing f, "f", toFHash f)
toS = method(); toS HLSymmetricFunction := f -> fromHash(hlRing f, "S", toSHash f)
toSomega = method(); toSomega HLSymmetricFunction := f -> fromHash(hlRing f, "Somega", toSomegaHash f)
toHallP = method(); toHallP HLSymmetricFunction := f -> fromHash(hlRing f, "P", toHallPHash f)
toR = method(); toR HLSymmetricFunction := f -> fromHash(hlRing f, "R", toRHash f)
toQ = method(); toQ HLSymmetricFunction := f -> fromHash(hlRing f, "Q", toQHash f)
toB = method(); toB HLSymmetricFunction := f -> fromHash(hlRing f, "B", toBHash f)

omegaInvolution = method()

omegaAtom = (A, atom) -> (
    (basis, idx) := parseAtom atom;
    if basis == "h" then lowercaseElement(A, "e", idx)
    else if basis == "e" then lowercaseElement(A, "h", idx)
    else if basis == "q" then lowercaseElement(A, "b", idx)
    else if basis == "b" then lowercaseElement(A, "q", idx)
    else if basis == "p" then fromHash(A, "p", omegaPHash(A, pHashOfP(A, idx)))
    else if basis == "m" then forgottenElement(A, idx)
    else if basis == "f" then monomialElement(A, idx)
    else if basis == "S" then capitalElement(A, "Somega", idx)
    else if basis == "Somega" then capitalElement(A, "S", idx)
    else if basis == "P" then capitalElement(A, "R", idx)
    else if basis == "R" then capitalElement(A, "P", idx)
    else if basis == "Q" then capitalElement(A, "B", idx)
    else if basis == "B" then capitalElement(A, "Q", idx)
    else if basis == "skewS" then skewElement(A, "skewSomega", idx)
    else if basis == "skewSomega" then skewElement(A, "skewS", idx)
    else if basis == "skewP" then skewElement(A, "skewR", idx)
    else if basis == "skewR" then skewElement(A, "skewP", idx)
    else if basis == "skewQ" then skewElement(A, "skewB", idx)
    else if basis == "skewB" then skewElement(A, "skewQ", idx)
    else error "unknown basis atom"
    )

omegaInvolution HLSymmetricFunction := f -> (
    A := hlRing f;
    sumHL(A, apply(pairs hlTerms f, term -> (
        mon := first term;
        coeff := last term;
        coeff * productHL(A, apply(mon, atom -> omegaAtom(A, atom)))
        )))
    )

symmetricEquals = method()
symmetricEquals(HLSymmetricFunction, HLSymmetricFunction) := (f, g) -> (
    if hlRing f =!= hlRing g then error "expected elements in the same HallLittlewood ring";
    hashTableEqual(toPHash f, toPHash g)
    )

-------------------------------------------------------------------------------
-- Straightening
-------------------------------------------------------------------------------

straightenSchurIndex = alpha -> (
    alpha = trimTrailingZeros alpha;
    ell := #alpha;
    rho := apply(0..ell-1, i -> ell-1-i);
    shifted := toList apply(0..ell-1, i -> alpha#i + rho#i);
    if #unique shifted < #shifted then return (0, {});
    inv := 0;
    for i from 0 to ell-2 do for j from i+1 to ell-1 do if shifted#i < shifted#j then inv = inv + 1;
    sorted := reverse(sort shifted);
    beta := apply(0..ell-1, i -> sorted#i - rho#i);
    ((-1)^inv, trimTrailingZeros beta)
    )

replaceAdjacentPair = (alpha, pos, a, b) -> (
    apply(0..#alpha-1, i -> if i == pos then a else if i == pos+1 then b else alpha#i)
    )

straightenHallCapital = (A, basis, alpha) -> (
    alpha = trimTrailingZeros alpha;
    if #alpha == 0 then return oneHL A;
    bad := null;
    for i from 0 to #alpha-2 do if bad === null and alpha#i < alpha#(i+1) then bad = i;
    if bad === null then return capitalElement(A, basis, alpha);
    s := alpha#bad;
    r := alpha#(bad+1);
    diff := r - s;
    top := diff // 2;
    K := A#"CoefficientRing";
    t := hlParameter A;
    terms := {t * straightenHallCapital(A, basis, replaceAdjacentPair(alpha, bad, r, s))};
    for i from 1 to top do (
        coeff := if diff % 2 == 0 and i == top then t^i - t^(i-1) else t^(i+1) - t^(i-1);
        terms = append(terms, coeff * straightenHallCapital(A, basis, replaceAdjacentPair(alpha, bad, r-i, s+i)));
        );
    sumHL(A, terms)
    )

straighten = method()
straighten HLSymmetricFunction := f -> (
    A := hlRing f;
    sumHL(A, apply(pairs hlTerms f, term -> (
        mon := first term;
        coeff := last term;
        productHL(A, apply(mon, atom -> (
            (basis, idx) := parseAtom atom;
            if basis == "S" or basis == "Somega" then (
                (sgn, beta) := straightenSchurIndex idx;
                if sgn == 0 then zeroHL A else sgn * capitalElement(A, basis, beta)
                )
            else if basis == "Q" then straightenHallCapital(A, "Q", idx)
            else if basis == "B" then straightenHallCapital(A, "B", idx)
            else if basis == "P" then toHallP capitalElement(A, "P", idx)
            else if basis == "R" then toR capitalElement(A, "R", idx)
            else if isSkewBasis basis then skewElement(A, basis, idx)
            else basisElement(A, basis, idx)
            ))) * coeff
        )))
    )

-------------------------------------------------------------------------------
-- Hall product, adjoints, Bernstein operators, plethysm
-------------------------------------------------------------------------------

hallInnerProduct = method()
hallInnerProduct(HLSymmetricFunction, HLSymmetricFunction) := (f, g) -> (
    if hlRing f =!= hlRing g then error "expected elements in the same HallLittlewood ring";
    A := hlRing f;
    K := A#"CoefficientRing";
    fQ := toBasisHash("q", f);
    gM := toMHash g;
    sum apply(keys fQ, key -> fQ#key * coeffInHash(gM, key, K))
    )

homogeneousDegree = f -> (
    degs := unique apply(keys toPHash f, partitionWeight);
    if #degs == 0 then return null;
    if #degs > 1 then error "expected a homogeneous symmetric function";
    first degs
    )

hallAdjoint = method()
hallAdjoint(HLSymmetricFunction, HLSymmetricFunction) := (F, G) -> (
    if hlRing F =!= hlRing G then error "expected elements in the same HallLittlewood ring";
    A := hlRing F;
    K := A#"CoefficientRing";
    dF := homogeneousDegree F;
    dG := homogeneousDegree G;
    if dF === null or dG === null or dG < dF then return zeroHL A;
    coeffs := new MutableHashTable;
    for mu in hlPartitions(dG-dF) do (
        c := hallInnerProduct(G, F * monomialElement(A, mu));
        if c != 0_K then coeffs#mu = c;
        );
    fromHash(A, "q", new HashTable from pairs coeffs)
    )

hallLittlewoodCFactor = method()
hallLittlewoodCFactor(HLSymmetricRing, List) := (A, lambda) -> hallLittlewoodCFactorList(A, lambda)
hallLittlewoodCFactor(HLSymmetricRing, Sequence) := (A, lambda) -> hallLittlewoodCFactor(A, toList lambda)

hallBernsteinQ = method()
hallBernsteinQ(HLSymmetricRing, ZZ, HLSymmetricFunction) := (A, n, F) -> (
    d := homogeneousDegree F;
    if d === null then return zeroHL A;
    sumHL(A, apply(0..d, i -> (-1)^i * lowercaseElement(A, "q", {n+i}) * hallAdjoint(lowercaseElement(A, "b", {i}), F)))
    )
hallBernsteinQ(HLSymmetricRing, ZZ, List) := (A, n, lambda) -> hallBernsteinQ(A, n, capitalElement(A, "Q", lambda))
hallBernsteinQ(HLSymmetricRing, ZZ, Sequence) := (A, n, lambda) -> hallBernsteinQ(A, n, toList lambda)

hallBernsteinB = method()
hallBernsteinB(HLSymmetricRing, ZZ, HLSymmetricFunction) := (A, n, F) -> (
    d := homogeneousDegree F;
    if d === null then return zeroHL A;
    sumHL(A, apply(0..d, i -> (-1)^i * lowercaseElement(A, "b", {n+i}) * hallAdjoint(lowercaseElement(A, "q", {i}), F)))
    )
hallBernsteinB(HLSymmetricRing, ZZ, List) := (A, n, lambda) -> hallBernsteinB(A, n, capitalElement(A, "B", lambda))
hallBernsteinB(HLSymmetricRing, ZZ, Sequence) := (A, n, lambda) -> hallBernsteinB(A, n, toList lambda)

pStretchHash = (A, n, H) -> (
    ans := new MutableHashTable;
    K := A#"CoefficientRing";
    for entry in pairs H do (
        key := normalizePartition apply(first entry, i -> n*i);
        c := adamsCoefficient(A, n, last entry);
        old := if ans#?key then ans#key else 0_K;
        ans#key = old + c;
        if ans#key == 0_K then remove(ans, key);
        );
    new HashTable from pairs ans
    )

hallPlethysm = method()
hallPlethysm(HLSymmetricFunction, HLSymmetricFunction) := (F, G) -> (
    if hlRing F =!= hlRing G then error "expected elements in the same HallLittlewood ring";
    A := hlRing F;
    Gp := toPHash G;
    ans := new HashTable from {};
    for entry in pairs toPHash F do (
        lam := first entry;
        H := productHash(A, apply(lam, i -> pStretchHash(A, i, Gp)));
        ans = addHash(A, ans, scaleHash(A, last entry, H));
        );
    fromHash(A, "p", ans)
    )

hallPlethysm(Number, HLSymmetricFunction) := (c, G) -> hallPlethysm(scalarHL(hlRing G, c), G)
hallPlethysm(HLSymmetricFunction, Number) := (F, c) -> hallPlethysm(F, scalarHL(hlRing F, c))
hallPlethysm(RingElement, HLSymmetricFunction) := (c, G) -> hallPlethysm(scalarHL(hlRing G, c), G)
hallPlethysm(HLSymmetricFunction, RingElement) := (F, c) -> hallPlethysm(F, scalarHL(hlRing F, c))

HLSymmetricFunction ** HLSymmetricFunction := (F, G) -> toS hallPlethysm(F, G)
Number ** HLSymmetricFunction := (c, G) -> toS hallPlethysm(c, G)
HLSymmetricFunction ** Number := (F, c) -> toS hallPlethysm(F, c)
RingElement ** HLSymmetricFunction := (c, G) -> toS hallPlethysm(c, G)
HLSymmetricFunction ** RingElement := (F, c) -> toS hallPlethysm(F, c)
