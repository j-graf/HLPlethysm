doc ///
Node
  Key
    HallLittlewood
  Headline
    mixed-basis Hall-Littlewood symmetric functions
  Description
    Text
      This package provides a mixed-basis expression system for symmetric functions.
      The indexed basis families @TT "p"@, @TT "h"@, @TT "e"@, @TT "m"@,
      @TT "f"@, @TT "q"@, @TT "b"@, @TT "S"@, @TT "Somega"@, @TT "P"@,
      @TT "R"@, @TT "Q"@, and @TT "B"@ are formal symbols, so arithmetic is
      fast and unevaluated. The conversion functions @TO toP@, @TO toH@,
      @TO toE@, @TO toM@, @TO toF@, @TO toS@, @TO toSomega@, @TO toHallP@,
      @TO toR@, @TO toQ@, and @TO toB@ interpret these formal expressions as
      symmetric functions.

      The lowercase families @TT "p"@, @TT "h"@, @TT "e"@, @TT "q"@, and
      @TT "b"@ are multiplicative, for example @TT "h_{2,1}"@ means
      @TT "h_2*h_1"@. The monomial family @TT "m"@ and forgotten family
      @TT "f"@ are not multiplicative. The capital families @TT "S"@,
      @TT "Somega"@, @TT "P"@, @TT "R"@, @TT "Q"@, and @TT "B"@ may be
      indexed by compositions and are left as written until a conversion or
      @TO straighten@ is applied.

      Skew families are also available as @TT "skewS"@, @TT "skewSomega"@,
      @TT "skewP"@, @TT "skewR"@, @TT "skewQ"@, and @TT "skewB"@. They are
      typed with paired list indices, for example
      @TT "skewQ_({4,2,1},{2,1})"@. Trailing zeroes in the two lists are
      trimmed at construction time.

      Coefficient-ring variables can also be declared as alphabet variables
      for plethysm and series work. If @TT "z"@ is declared this way, then
      @TT "p_2[X+z]"@ is interpreted as @TT "p_2+z^2"@.
    Example
      A = hallLittlewoodRing(QQ[t], DegreeLimit => 12, Parameter => t)
      f = S_{5,1,3} + q_{2,1} + p_3
      straighten S_{5,1,3}
      toH S_{2,1}
      symmetricEquals(S_{2,1}, h_{2,1} - h_3)
      skewQ_({4,2,1},{2,1})
      toH skewS_({2,1},{1})
      toQ skewQ_({2},{})
      B = hallLittlewoodRing(QQ[t,z], DegreeLimit => 8, Parameter => t, AlphabetVariables => {z})
      hallPlethysm(p_2, p_1 + z)
  SeeAlso
    hallLittlewoodRing
    toP
    toF
    toSomega
    toHallP
    toR
    toQ
    toSFromh
    toSFromp
    toQFromq
    toHFromp
    toEFromp
    seriesCollect
    straighten
    omegaInvolution
    multSchur
    symmetricEquals
///

doc ///
Key
    HLSymmetricRing
Headline
    a type representing a mixed-basis Hall-Littlewood expression ring
Description
  Text
    An object of type @TO HLSymmetricRing@ stores the coefficient ring, the
    Hall-Littlewood parameter, the degree limit, and conversion caches. The
    constructor @TO hallLittlewoodRing@ creates these objects and installs the
    indexed basis-family tables.
  Example
    A = hallLittlewoodRing(QQ[t], DegreeLimit => 12, Parameter => t)
    degreeLimit A
    hlParameter A
SeeAlso
    hallLittlewoodRing
    HLSymmetricFunction
///

doc ///
Key
    HLSymmetricFunction
Headline
    a formal mixed-basis symmetric-function expression
Description
  Text
    An object of type @TO HLSymmetricFunction@ is a sparse formal expression in
    the basis-family symbols managed by a @TO HLSymmetricRing@. Ordinary
    arithmetic such as addition and multiplication is formal; mathematical
    interpretation is supplied by conversion functions such as @TO toP@ and
    @TO toS@.
  Example
    A = hallLittlewoodRing(QQ[t], DegreeLimit => 12, Parameter => t)
    f = p_2 + h_5
    g = S_{2,1} + q_{2,1}
    f + g
    3 + h_1
    t + S_1
    toP h_2
SeeAlso
    HLSymmetricRing
    toP
///

doc ///
Key
    HLIndexedVariableTable
Headline
    indexed variable tables for Hall-Littlewood basis families
Description
  Text
    This type is used internally by @TO hallLittlewoodRing@ to install the
    indexed symbols @TT "p"@, @TT "h"@, @TT "e"@, @TT "q"@, @TT "b"@,
    @TT "m"@, @TT "f"@, @TT "S"@, @TT "Somega"@, @TT "P"@, @TT "R"@,
    @TT "Q"@, and @TT "B"@, together with the skew families @TT "skewS"@,
    @TT "skewSomega"@, @TT "skewP"@, @TT "skewR"@, @TT "skewQ"@, and
    @TT "skewB"@. It is modeled on the indexed-variable-table pattern used by
    Macaulay2 packages such as @TT "SchurRings"@.
  Example
    A = hallLittlewoodRing(QQ[t], DegreeLimit => 12, Parameter => t)
    q_{2,1}
    m_{2,1}
    S_{5,1,3}
    skewQ_({4,2,1},{2,1})
SeeAlso
    hallLittlewoodRing
///

doc ///
Key
    hallLittlewoodRing
    (hallLittlewoodRing, Ring)
Headline
    construct a Hall-Littlewood symmetric-function expression ring
Usage
    A = hallLittlewoodRing R
    A = hallLittlewoodRing(R, DegreeLimit => d, Parameter => t)
    A = hallLittlewoodRing(R, AlphabetVariables => {z,w})
Inputs
    R:Ring
      the coefficient ring, usually a polynomial ring such as @TT "QQ[t]"@.
    d:ZZ
      the maximum total degree allowed for indexed basis elements.
    t:RingElement
      the Hall-Littlewood parameter.
Outputs
    A:HLSymmetricRing
      a mixed-basis Hall-Littlewood expression ring.
Description
  Text
    The constructor creates a mixed-basis expression ring and calls @TO use@,
    installing the indexed basis-family tables. The default degree limit is
    @TT "20"@. If the parameter is not specified, the first generator of the
    coefficient ring is used.

    If an index exceeds the degree limit, an error is raised. The
    multiplicative lowercase basis elements satisfy
    @TT "p_0=h_0=e_0=q_0=b_0=1"@ and have value @TT "0"@ on negative indices.
    The partition-indexed families @TT "m"@ and @TT "f"@ also have value
    @TT "0"@ if any index is negative.
  Example
    A = hallLittlewoodRing(QQ[t], DegreeLimit => 12, Parameter => t)
    p_0
    q_-1
    p_2 + h_5
  Text
    A different parameter may be used.
  Example
    A = hallLittlewoodRing(QQ[q], DegreeLimit => 8, Parameter => q)
    hlParameter A
  Text
    Alphabet variables are coefficient-ring variables that transform under
    Adams operations during plethysm. The Hall-Littlewood parameter is always
    included as an alphabet variable. Declaring @TT "z"@ also promotes the
    visible symbol @TT "z"@ to the coefficient fraction field, so expressions
    such as @TT "z^(-1)"@ can be used.
  Example
    A = hallLittlewoodRing(QQ[t,z,w], DegreeLimit => 8, Parameter => t, AlphabetVariables => {z,w})
    alphabetVariables A
    z^(-1)*h_1
    hallPlethysm(p_2, p_1 + z)
SeeAlso
    HLSymmetricRing
    degreeLimit
    hlParameter
    alphabetVariables
    [hallLittlewoodRing, DegreeLimit]
    [hallLittlewoodRing, Parameter]
    [hallLittlewoodRing, AlphabetVariables]
///

doc ///
Key
    [hallLittlewoodRing, DegreeLimit]
Headline
    specify the maximum degree for indexed basis elements
Description
  Text
    This optional argument sets the maximum total degree allowed in indexed
    basis elements. The default value is @TT "20"@. If an index exceeds the
    degree limit, an error is raised.
  Example
    A = hallLittlewoodRing(QQ[t], DegreeLimit => 12, Parameter => t)
    degreeLimit A
SeeAlso
    hallLittlewoodRing
    degreeLimit
///

doc ///
Key
    [hallLittlewoodRing, Parameter]
Headline
    specify the Hall-Littlewood parameter
Description
  Text
    This optional argument sets the Hall-Littlewood parameter. If the parameter
    is not specified, the first generator of the coefficient ring is used.
  Example
    A = hallLittlewoodRing(QQ[q], DegreeLimit => 8, Parameter => q)
    hlParameter A
SeeAlso
    hallLittlewoodRing
    hlParameter
///

doc ///
Key
    [hallLittlewoodRing, AlphabetVariables]
Headline
    declare coefficient variables as alphabet variables for plethysm
Description
  Text
    Alphabet variables are acted on by Adams operations during plethysm. If
    @TT "z"@ is declared as an alphabet variable, then
    @TT "p_k[z]"@ is interpreted as @TT "z^k"@, and
    @TT "p_k[t*p_1]"@ is interpreted as @TT "t^k*p_k"@. The
    Hall-Littlewood parameter is included automatically.
  Example
    A = hallLittlewoodRing(QQ[t,z], DegreeLimit => 8, Parameter => t, AlphabetVariables => {z})
    hallPlethysm(p_2, t*p_1 + z)
    hallPlethysm(p_3, (t+z)*p_1)
SeeAlso
    hallLittlewoodRing
    alphabetVariables
    adamsCoefficient
    hallPlethysm
///

doc ///
Key
    degreeLimit
    (degreeLimit, HLSymmetricRing)
Headline
    return the degree limit of a Hall-Littlewood expression ring
Usage
    degreeLimit A
Inputs
    A:HLSymmetricRing
      a Hall-Littlewood expression ring.
Outputs
    d:ZZ
      the maximum total degree allowed in indexed basis elements.
Description
  Example
    A = hallLittlewoodRing(QQ[t], DegreeLimit => 12, Parameter => t)
    degreeLimit A
SeeAlso
    hallLittlewoodRing
///

doc ///
Key
    hlParameter
    (hlParameter, HLSymmetricRing)
Headline
    return the Hall-Littlewood parameter
Usage
    hlParameter A
Inputs
    A:HLSymmetricRing
      a Hall-Littlewood expression ring.
Outputs
    t:RingElement
      the Hall-Littlewood parameter.
Description
  Example
    A = hallLittlewoodRing(QQ[q], DegreeLimit => 8, Parameter => q)
    hlParameter A
SeeAlso
    hallLittlewoodRing
///

doc ///
Key
    alphabetVariables
    (alphabetVariables, HLSymmetricRing)
Headline
    return the alphabet variables declared for plethysm
Usage
    alphabetVariables A
Inputs
    A:HLSymmetricRing
      a Hall-Littlewood expression ring.
Outputs
    L:List
      the coefficient variables transformed by Adams operations in plethysm.
Description
  Example
    A = hallLittlewoodRing(QQ[t,z,w], DegreeLimit => 8, Parameter => t, AlphabetVariables => {z,w})
    alphabetVariables A
SeeAlso
    [hallLittlewoodRing, AlphabetVariables]
    adamsCoefficient
///

doc ///
Key
    partitionWeight
    (partitionWeight, List)
    (partitionWeight, Sequence)
    (partitionWeight, ZZ)
Headline
    compute the weight of an integer sequence
Usage
    partitionWeight lambda
Inputs
    lambda:List
      a list of integers.
Outputs
    n:ZZ
      the sum of the parts of @TT "lambda"@.
Description
  Example
    partitionWeight {5,1,3}
SeeAlso
    partitionLength
    conjugatePartition
    hlPartitions
///

doc ///
Key
    partitionLength
    (partitionLength, List)
    (partitionLength, Sequence)
    (partitionLength, ZZ)
Headline
    compute the number of nonzero parts
Usage
    partitionLength lambda
Inputs
    lambda:List
      a list of integers.
Outputs
    n:ZZ
      the number of nonzero parts after removing trailing zeroes.
Description
  Example
    partitionLength {5,1,3,0,0}
SeeAlso
    partitionWeight
    conjugatePartition
///

doc ///
Key
    hlPartitions
    (hlPartitions, ZZ)
Headline
    list all integer partitions of a nonnegative integer
Usage
    hlPartitions n
Inputs
    n:ZZ
      a nonnegative integer.
Outputs
    L:List
      the list of partitions of @TT "n"@, written as lists.
Description
  Text
    The name @TT "hlPartitions"@ avoids shadowing Macaulay2's built-in
    @TT "partitions"@ symbol.
  Example
    hlPartitions 5
SeeAlso
    partitionWeight
    conjugatePartition
///

doc ///
Key
    conjugatePartition
    (conjugatePartition, List)
    (conjugatePartition, Sequence)
Headline
    conjugate a partition
Usage
    conjugatePartition lambda
Inputs
    lambda:List
      a partition.
Outputs
    mu:List
      the conjugate partition.
Description
  Example
    conjugatePartition {5,3,1}
SeeAlso
    hlPartitions
    partitionWeight
///

doc ///
Key
    toP
    (toP, HLSymmetricFunction)
Headline
    convert a mixed-basis expression to the power-sum basis
Usage
    toP f
Inputs
    f:HLSymmetricFunction
      a mixed-basis expression.
Outputs
    g:HLSymmetricFunction
      an expression in the @TT "p"@ basis.
Description
  Text
    The power-sum basis is the internal basis used for comparison, plethysm, and
    many basis conversions.
  Example
    A = hallLittlewoodRing(QQ[t], DegreeLimit => 12, Parameter => t)
    toP h_2
    toP q_2
SeeAlso
    toPHash
    toH
    symmetricEquals
///

doc ///
Key
    toH
    (toH, HLSymmetricFunction)
Headline
    convert a mixed-basis expression to the homogeneous basis
Usage
    toH f
Inputs
    f:HLSymmetricFunction
      a mixed-basis expression.
Outputs
    g:HLSymmetricFunction
      an expression in the @TT "h"@ basis.
Description
  Text
    For a Schur expression @TT "S_lambda"@, the conversion @TT "toH"@ uses the
    Jacobi-Trudi determinant. This applies to composition indices as well.
  Example
    A = hallLittlewoodRing(QQ[t], DegreeLimit => 12, Parameter => t)
    toH S_{2,1}
    toH S_{5,1,3}
SeeAlso
    toHHash
    toE
    straighten
///

doc ///
Key
    toE
    (toE, HLSymmetricFunction)
Headline
    convert a mixed-basis expression to the elementary basis
Usage
    toE f
Inputs
    f:HLSymmetricFunction
      a mixed-basis expression.
Outputs
    g:HLSymmetricFunction
      an expression in the @TT "e"@ basis.
Description
  Text
    For Schur symbols, @TT "toE"@ converts through the homogeneous-basis
    Jacobi-Trudi interpretation.
  Example
    A = hallLittlewoodRing(QQ[t], DegreeLimit => 8, Parameter => t)
    toE h_2
    toE S_{2,1}
SeeAlso
    toEHash
    toH
///

doc ///
Key
    toM
    (toM, HLSymmetricFunction)
Headline
    convert a mixed-basis expression to the monomial basis
Usage
    toM f
Inputs
    f:HLSymmetricFunction
      a mixed-basis expression.
Outputs
    g:HLSymmetricFunction
      an expression in the @TT "m"@ basis.
Description
  Text
    The monomial basis family @TT "m"@ is partition-indexed and is not
    multiplicative.
  Example
    A = hallLittlewoodRing(QQ[t], DegreeLimit => 8, Parameter => t)
    toM q_2
    toM h_2
SeeAlso
    toMHash
    toF
    hallInnerProduct
///

doc ///
Key
    toF
    (toF, HLSymmetricFunction)
Headline
    convert a mixed-basis expression to the forgotten basis
Usage
    toF f
Inputs
    f:HLSymmetricFunction
      a mixed-basis expression.
Outputs
    g:HLSymmetricFunction
      an expression in the forgotten @TT "f"@ basis.
Description
  Text
    The forgotten basis is defined by @TT "f_lambda = omega(m_lambda)"@. Like
    the monomial basis, it is partition-indexed and is not multiplicative.
  Example
    A = hallLittlewoodRing(QQ[t], DegreeLimit => 8, Parameter => t)
    omegaInvolution m_{2,1}
    toF m_2
SeeAlso
    toFHash
    toM
    omegaInvolution
///

doc ///
Key
    toS
    (toS, HLSymmetricFunction)
Headline
    convert a mixed-basis expression to the Schur basis
Usage
    toS f
Inputs
    f:HLSymmetricFunction
      a mixed-basis expression.
Outputs
    g:HLSymmetricFunction
      an expression in partition-indexed @TT "S"@ basis elements.
Description
  Text
    The output uses partition indices. Composition-indexed Schur symbols can
    also be simplified directly using @TO straighten@.
  Example
    A = hallLittlewoodRing(QQ[t], DegreeLimit => 12, Parameter => t)
    toS(h_{2,1} - h_3)
    straighten S_{5,1,3}
SeeAlso
    toSHash
    toSomega
    straighten
///

doc ///
Key
    toSomega
    (toSomega, HLSymmetricFunction)
Headline
    convert a mixed-basis expression to the omega-Schur basis
Usage
    toSomega f
Inputs
    f:HLSymmetricFunction
      a mixed-basis expression.
Outputs
    g:HLSymmetricFunction
      an expression in partition-indexed @TT "Somega"@ basis elements.
Description
  Text
    The basis element @TT "Somega_lambda"@ is the conjugate Schur function
    defined by the Jacobi-Trudi determinant in the elementary functions,
    @TT "det(e_{lambda_i-i+j})"@. Composition-indexed @TT "Somega"@ symbols
    can also be simplified directly using @TO straighten@.
  Example
    A = hallLittlewoodRing(QQ[t], DegreeLimit => 12, Parameter => t)
    omegaInvolution S_{2,1}
    toE Somega_{2,1}
    toSomega S_3
SeeAlso
    toSomegaHash
    toS
    omegaInvolution
    straighten
///

doc ///
Key
    toHallP
    (toHallP, HLSymmetricFunction)
Headline
    convert a mixed-basis expression to the Hall-Littlewood P basis
Usage
    toHallP f
Inputs
    f:HLSymmetricFunction
      a mixed-basis expression.
Outputs
    g:HLSymmetricFunction
      an expression in partition-indexed @TT "P"@ basis elements.
Description
  Text
    The Hall-Littlewood @TT "P"@ basis is normalized by
    @TT "Q_lambda = c_lambda(t) P_lambda"@, where @TT "c_lambda(t)"@ is
    computed by @TO hallLittlewoodCFactor@. The name @TT "toHallP"@ is used
    because @TO toP@ already denotes conversion to the power-sum basis.
  Example
    A = hallLittlewoodRing(QQ[t], DegreeLimit => 8, Parameter => t)
    toHallP Q_2
    symmetricEquals(P_2, 1/(1-t)*Q_2)
SeeAlso
    toHallPHash
    toQ
    toR
    hallLittlewoodCFactor
///

doc ///
Key
    toR
    (toR, HLSymmetricFunction)
Headline
    convert a mixed-basis expression to the R basis
Usage
    toR f
Inputs
    f:HLSymmetricFunction
      a mixed-basis expression.
Outputs
    g:HLSymmetricFunction
      an expression in partition-indexed @TT "R"@ basis elements.
Description
  Text
    The basis @TT "R_lambda"@ is defined by @TT "R_lambda = omega(P_lambda)"@.
  Example
    A = hallLittlewoodRing(QQ[t], DegreeLimit => 8, Parameter => t)
    omegaInvolution P_2
    toR B_2
SeeAlso
    toRHash
    toHallP
    toB
    omegaInvolution
///

doc ///
Key
    toQ
    (toQ, HLSymmetricFunction)
Headline
    convert a mixed-basis expression to the Hall-Littlewood Q basis
Usage
    toQ f
Inputs
    f:HLSymmetricFunction
      a mixed-basis expression.
Outputs
    g:HLSymmetricFunction
      an expression in partition-indexed @TT "Q"@ basis elements.
Description
  Text
    The conversion uses the power-sum basis internally. The basis elements
    @TT "Q_lambda"@ are computed from the raising-operator formula in the
    Hall-Littlewood definitions.
  Example
    A = hallLittlewoodRing(QQ[t], DegreeLimit => 8, Parameter => t)
    toQ q_2
    toQ Q_{2,1}
SeeAlso
    toQHash
    toB
    straighten
///

doc ///
Key
    toB
    (toB, HLSymmetricFunction)
Headline
    convert a mixed-basis expression to the B basis
Usage
    toB f
Inputs
    f:HLSymmetricFunction
      a mixed-basis expression.
Outputs
    g:HLSymmetricFunction
      an expression in partition-indexed @TT "B"@ basis elements.
Description
  Text
    The @TT "B"@ basis is the image of the Hall-Littlewood @TT "Q"@ basis
    under the usual involution in the definitions used by this package.
  Example
    A = hallLittlewoodRing(QQ[t], DegreeLimit => 8, Parameter => t)
    toB b_2
    toB B_{2,1}
SeeAlso
    toBHash
    toQ
///

doc ///
Key
    toSFromh
    (toSFromh, HLSymmetricFunction)
    toSomegaFrome
    (toSomegaFrome, HLSymmetricFunction)
    toQFromq
    (toQFromq, HLSymmetricFunction)
    toBFromb
    (toBFromb, HLSymmetricFunction)
    toSFromp
    (toSFromp, HLSymmetricFunction)
    toSomegaFromp
    (toSomegaFromp, HLSymmetricFunction)
Headline
    convert one-row generator polynomials by triangular reduction
Usage
    toSFromh f
    toSomegaFrome f
    toQFromq f
    toBFromb f
    toSFromp f
    toSomegaFromp f
Inputs
    f:HLSymmetricFunction
      an expression in the indicated one-row generator basis.
Outputs
    g:HLSymmetricFunction
      the corresponding expansion in the associated capital basis.
Description
  Text
    These functions use triangular reduction rather than the generic power-sum
    conversion path. The input must involve only the indicated one-row
    generator family: @TT "h"@ for @TT "toSFromh"@, @TT "e"@ for
    @TT "toSomegaFrome"@, @TT "q"@ for @TT "toQFromq"@, and @TT "b"@ for
    @TT "toBFromb"@.

    The functions @TT "toSFromp"@ and @TT "toSomegaFromp"@ first convert from
    @TT "p"@ to @TT "h"@ or @TT "e"@ using Newton recurrences, then apply the
    corresponding triangular reduction. They are provided as explicit fast
    paths for benchmarking against @TO toS@ and @TO toSomega@.
  Example
    A = hallLittlewoodRing(QQ[t], DegreeLimit => 12, Parameter => t)
    toSFromh(h_{2,1} - h_3)
    toSomegaFrome(e_{2,1} - e_3)
    toQFromq(q_{2,1} + (t-1)*q_3)
    toBFromb(b_{2,1} + (t-1)*b_3)
    toSFromp(p_2*p_1)
    toSomegaFromp(p_2*p_1)
SeeAlso
    triangularReduce
    toS
    toQ
///

doc ///
Key
    toStest
    (toStest, HLSymmetricFunction)
Headline
    benchmark Schur conversion using a native h-polynomial ring
Usage
    toStest f
Inputs
    f:HLSymmetricFunction
      a mixed-basis expression.
Outputs
    g:HLSymmetricFunction
      the Schur expansion of @TT "f"@.
Description
  Text
    This benchmark conversion first converts @TT "f"@ to the power-sum basis,
    then converts power sums to complete symmetric functions. The resulting
    @TT "h"@-polynomial is moved into a temporary native Macaulay2 polynomial
    ring in @TT "h_1,h_2,..."@. Schur functions are computed there using the
    native determinant method, and triangular reduction is performed with
    native polynomial subtraction before converting back to
    @TO HLSymmetricFunction@.
  Example
    A = hallLittlewoodRing(QQ[t], DegreeLimit => 10, Parameter => t)
    f = p_2*p_1 + 3*p_3
    toStest f
SeeAlso
    toS
    toSFromp
///

doc ///
Key
    toSgrevlexTest
    (toSgrevlexTest, HLSymmetricFunction)
Headline
    benchmark Schur conversion using native GRevLex leading terms
Usage
    toSgrevlexTest f
Inputs
    f:HLSymmetricFunction
      a mixed-basis expression.
Outputs
    g:HLSymmetricFunction
      the Schur expansion of @TT "f"@.
Description
  Text
    This benchmark conversion is similar to @TO toStest@, but uses a
    temporary native Macaulay2 polynomial ring with @TT "GRevLex"@ order and
    native @TT "leadMonomial"@ during triangular reduction. The goal is to
    avoid scanning all terms to find the next leading @TT "h"@-monomial.
  Example
    A = hallLittlewoodRing(QQ[t], DegreeLimit => 10, Parameter => t)
    f = p_2*p_1 + 3*p_3
    toSgrevlexTest f
SeeAlso
    toS
    toStest
    toSFromp
///

doc ///
Key
    toSChunkedTest
    (toSChunkedTest, HLSymmetricFunction)
Headline
    benchmark Schur conversion by chunking p-terms in parallel
Usage
    toSChunkedTest f
    toSChunkedTest(f, ChunkSize => n)
Inputs
    f:HLSymmetricFunction
      a mixed-basis expression.
    n:ZZ
      the number of power-sum terms per chunk.
Outputs
    g:HLSymmetricFunction
      the Schur expansion of @TT "f"@.
Description
  Text
    This benchmark conversion splits the power-sum expansion of @TT "f"@ into
    chunks, converts each chunk with the native @TT "GRevLex"@ triangular
    method, and combines the resulting Schur coefficients. It uses
    @TT "parallelApply"@ on the chunks. By default, the chunk size is chosen as
    the number of power-sum terms divided by the number of available Macaulay2
    threads, rounded up, with a minimum chunk size of @TT "4"@. Very small
    chunks have too much thread overhead, so an explicit @TT "ChunkSize"@ must
    be at least @TT "4"@.
  Example
    A = hallLittlewoodRing(QQ[t], DegreeLimit => 10, Parameter => t)
    f = p_2*p_1 + 3*p_3
    toSChunkedTest f
    toSChunkedTest(f, ChunkSize => 8)
SeeAlso
    toS
    toSgrevlexTest
    toStest
///

doc ///
Key
    [toSChunkedTest, ChunkSize]
Headline
    choose the number of p-terms per chunk
Description
  Text
    This option controls how many power-sum terms are placed in each chunk for
    @TO toSChunkedTest@. Very small chunks have high thread overhead, so the
    value must be at least @TT "4"@. The default is automatic: it uses
    Macaulay2's available thread count to choose approximately
    @TT "ceiling(number of p-terms / number of threads)"@.
  Example
    A = hallLittlewoodRing(QQ[t], DegreeLimit => 10, Parameter => t)
    f = p_2*p_1 + 3*p_3
    toSChunkedTest f
    toSChunkedTest(f, ChunkSize => 8)
SeeAlso
    toSChunkedTest
///

doc ///
Key
    toSPieriTest
    (toSPieriTest, HLSymmetricFunction)
Headline
    benchmark Schur conversion using the Pieri rule
Usage
    toSPieriTest f
Inputs
    f:HLSymmetricFunction
      a mixed-basis expression.
Outputs
    g:HLSymmetricFunction
      the Schur expansion of @TT "f"@.
Description
  Text
    This benchmark conversion first converts @TT "f"@ to the power-sum basis,
    then to complete symmetric functions. Each @TT "h"@-monomial is converted
    to Schur functions by iterated Pieri multiplication, with cached
    expansions of @TT "h_lambda"@.
  Example
    A = hallLittlewoodRing(QQ[t], DegreeLimit => 10, Parameter => t)
    f = p_2*p_1 + 3*p_3
    toSPieriTest f
SeeAlso
    toS
    toStest
    toSFromp
///

doc ///
Key
    triangularReduce
    (triangularReduce, HLSymmetricRing, String, String, HashTable)
Headline
    reduce a generator-basis hash table to a triangular capital basis
Usage
    triangularReduce(A,basis,generatorBasis,H)
Inputs
    A:HLSymmetricRing
      a Hall-Littlewood symmetric-function ring.
    basis:String
      one of @TT "\"S\""@, @TT "\"Somega\""@, @TT "\"Q\""@, or @TT "\"B\""@.
    generatorBasis:String
      the corresponding one-row generator basis, respectively @TT "\"h\""@,
      @TT "\"e\""@, @TT "\"q\""@, or @TT "\"b\""@.
    H:HashTable
      a hash table from partition indices to coefficients in the coefficient ring of @TT "A"@.
Outputs
    K:HashTable
      a hash table of coefficients in the requested triangular basis.
Description
  Text
    This is the low-level triangular reduction engine used by @TO toSFromh@,
    @TO toSomegaFrome@, @TO toQFromq@, and @TO toBFromb@.
  Example
    A = hallLittlewoodRing(QQ[t], DegreeLimit => 12, Parameter => t)
    K = A#"CoefficientRing"
    triangularReduce(A, "S", "h", new HashTable from {{2,1} => 1_K, {3} => -1_K})
SeeAlso
    toSFromh
///

doc ///
Key
    toHFromp
    (toHFromp, HLSymmetricFunction)
    toEFromp
    (toEFromp, HLSymmetricFunction)
Headline
    convert directly from p to h or e using Newton recurrences
Usage
    toHFromp f
    toEFromp f
Inputs
    f:HLSymmetricFunction
      an expression in the @TT "p"@ basis.
Outputs
    g:HLSymmetricFunction
      the converted expression in the @TT "h"@ or @TT "e"@ basis.
Description
  Text
    These functions use the Newton recurrences to convert a power-sum
    expression directly to complete or elementary symmetric functions. The
    one-row conversions are cached. The general functions @TO toH@ and
    @TO toE@ use these direct conversions automatically when the input is
    already written in the @TT "p"@ basis.
  Example
    A = hallLittlewoodRing(QQ[t], DegreeLimit => 10, Parameter => t)
    toHFromp p_3
    toEFromp p_3
    toHFromp(p_2*p_1)
    toEFromp(p_2*p_1)
SeeAlso
    toH
    toE
    hallPlethysm
    toSFromh
///

doc ///
Key
    toPHash
    (toPHash, HLSymmetricFunction)
    toHHash
    (toHHash, HLSymmetricFunction)
    toEHash
    (toEHash, HLSymmetricFunction)
    toMHash
    (toMHash, HLSymmetricFunction)
    toFHash
    (toFHash, HLSymmetricFunction)
    toSHash
    (toSHash, HLSymmetricFunction)
    toSomegaHash
    (toSomegaHash, HLSymmetricFunction)
    toHallPHash
    (toHallPHash, HLSymmetricFunction)
    toRHash
    (toRHash, HLSymmetricFunction)
    toQHash
    (toQHash, HLSymmetricFunction)
    toBHash
    (toBHash, HLSymmetricFunction)
Headline
    return basis expansion coefficients as a hash table
Usage
    toPHash f
    toFHash f
    toSomegaHash f
    toHallPHash f
    toQHash f
Inputs
    f:HLSymmetricFunction
      a mixed-basis expression.
Outputs
    H:HashTable
      a hash table from partition indices to coefficients.
Description
  Text
    The hash variants return the coefficients of a basis expansion directly.
    They are useful for extracting individual coefficients without parsing a
    displayed expression.
  Example
    A = hallLittlewoodRing(QQ[t], DegreeLimit => 8, Parameter => t)
    H = toMHash q_2
    H#{2}
    H#{1,1}
SeeAlso
    toP
    toF
    toSomega
    toHallP
    toR
    toQ
///

doc ///
Key
    straighten
    (straighten, HLSymmetricFunction)
Headline
    straighten composition-indexed basis symbols
Usage
    straighten f
Inputs
    f:HLSymmetricFunction
      a mixed-basis expression.
Outputs
    g:HLSymmetricFunction
      a straightened expression.
Description
  Text
    The function @TT "straighten"@ applies basis-specific straightening rules
    to capital basis symbols. For @TT "S"@ and @TT "Somega"@, this is the
    usual shifted Schur straightening rule. For @TT "Q"@ and @TT "B"@,
    adjacent out-of-order parts are rewritten using the Hall-Littlewood
    two-part relation. For @TT "P"@ and @TT "R"@, straightening is obtained by
    conversion to the corresponding partition-indexed basis.
  Example
    A = hallLittlewoodRing(QQ[t], DegreeLimit => 12, Parameter => t)
    straighten S_{5,1,3}
    straighten Somega_{5,1,3}
    straighten P_{1,2}
    straighten Q_{1,2}
    straighten B_{1,2}
SeeAlso
    toS
    toSomega
    toHallP
    toR
    toQ
    toB
///

doc ///
Key
    omegaInvolution
    (omegaInvolution, HLSymmetricFunction)
Headline
    apply the omega involution
Usage
    omegaInvolution f
Inputs
    f:HLSymmetricFunction
      a mixed-basis expression.
Outputs
    g:HLSymmetricFunction
      the image of @TT "f"@ under the omega involution.
Description
  Text
    The omega involution is applied multiplicatively to each formal term. It
    interchanges @TT "h"@ with @TT "e"@, @TT "m"@ with @TT "f"@,
    @TT "q"@ with @TT "b"@, @TT "Q"@ with @TT "B"@, @TT "P"@ with
    @TT "R"@, and @TT "S"@ with @TT "Somega"@. It sends @TT "p_n"@ to
    @TT "(-1)^(n-1) p_n"@. The skew families are swapped in the same way:
    @TT "skewQ"@ with @TT "skewB"@, @TT "skewP"@ with @TT "skewR"@, and
    @TT "skewS"@ with @TT "skewSomega"@.
  Example
    A = hallLittlewoodRing(QQ[t], DegreeLimit => 12, Parameter => t)
    omegaInvolution(q_2*e_4)
    omegaInvolution(m_{2,1})
    omegaInvolution(P_{2,1})
    omegaInvolution(skewQ_({4,2,1},{2,1}))
    omegaInvolution(S_{5,1,3})
    omegaInvolution(Somega_{2,1})
    omegaInvolution(p_2*p_1)
SeeAlso
    toF
    toHallP
    toR
    toSomega
    straighten
    toP
///

doc ///
Key
    multSchur
    (multSchur, HLSymmetricFunction, HLSymmetricFunction)
Headline
    multiply two Schur basis elements using a triangular h-basis reduction
Usage
    multSchur(f,g)
Inputs
    f:HLSymmetricFunction
      a single Schur basis element.
    g:HLSymmetricFunction
      a single Schur basis element in the same ring.
Outputs
    h:HLSymmetricFunction
      the Schur-basis expansion of the product.
Description
  Text
    This function is a specialized Schur multiplication routine. It expands the
    two Schur functions by Jacobi-Trudi into the homogeneous basis, multiplies
    in the homogeneous basis, and then uses the triangular relation
    @TT "S_lambda = h_lambda + lower terms"@ to recover the Schur expansion.
    Ordinary multiplication of @TO HLSymmetricFunction@ objects is unchanged.
  Example
    A = hallLittlewoodRing(QQ[t], DegreeLimit => 12, Parameter => t)
    multSchur(S_1, S_1)
    multSchur(S_{2,1}, S_1)
SeeAlso
    toS
    symmetricEquals
///

doc ///
Key
    symmetricEquals
    (symmetricEquals, HLSymmetricFunction, HLSymmetricFunction)
Headline
    compare two expressions as symmetric functions
Usage
    symmetricEquals(f,g)
Inputs
    f:HLSymmetricFunction
      a mixed-basis expression.
    g:HLSymmetricFunction
      a mixed-basis expression in the same ring.
Outputs
    b:Boolean
      whether @TT "f"@ and @TT "g"@ represent the same symmetric function.
Description
  Text
    Raw equality compares formal expressions. The function
    @TT "symmetricEquals"@ converts both expressions to the power-sum basis and
    compares the results.
  Example
    A = hallLittlewoodRing(QQ[t], DegreeLimit => 8, Parameter => t)
    S_{2,1} == h_{2,1} - h_3
    symmetricEquals(S_{2,1}, h_{2,1} - h_3)
SeeAlso
    toP
///

doc ///
Key
    hallInnerProduct
    (hallInnerProduct, HLSymmetricFunction, HLSymmetricFunction)
Headline
    compute the Hall inner product
Usage
    hallInnerProduct(f,g)
Inputs
    f:HLSymmetricFunction
      a symmetric-function expression.
    g:HLSymmetricFunction
      a symmetric-function expression in the same ring.
Outputs
    c:RingElement
      the Hall inner product of @TT "f"@ and @TT "g"@.
Description
  Text
    The implementation uses the defining duality
    $(q_\lambda,m_\mu)=\delta_{\lambda\mu}$.
  Example
    A = hallLittlewoodRing(QQ[t], DegreeLimit => 8, Parameter => t)
    hallInnerProduct(q_{2,1}, m_{2,1})
    hallInnerProduct(q_2, m_{1,1})
SeeAlso
    hallAdjoint
    toM
///

doc ///
Key
    hallAdjoint
    (hallAdjoint, HLSymmetricFunction, HLSymmetricFunction)
Headline
    apply an adjoint operator for the Hall inner product
Usage
    hallAdjoint(F,G)
Inputs
    F:HLSymmetricFunction
      the function whose multiplication operator is adjointed.
    G:HLSymmetricFunction
      the function being acted on.
Outputs
    H:HLSymmetricFunction
      the adjoint action @TT "F^perp G"@.
Description
  Text
    The adjoint is defined by the Hall inner product:
    $(F^\perp G,H)=(G,FH)$.
  Example
    A = hallLittlewoodRing(QQ[t], DegreeLimit => 8, Parameter => t)
    hallAdjoint(q_1, q_{2,1})
SeeAlso
    hallInnerProduct
    hallBernsteinQ
///

doc ///
Key
    hallBernsteinQ
    (hallBernsteinQ, HLSymmetricRing, ZZ, HLSymmetricFunction)
    (hallBernsteinQ, HLSymmetricRing, ZZ, List)
Headline
    apply the Hall-Littlewood Bernstein operator for the Q basis
Usage
    hallBernsteinQ(A,n,F)
    hallBernsteinQ(A,n,lambda)
Inputs
    A:HLSymmetricRing
      a Hall-Littlewood expression ring.
    n:ZZ
      the part to append.
    F:HLSymmetricFunction
      the function being acted on.
    lambda:List
      an index for a @TT "Q"@ basis element.
Outputs
    G:HLSymmetricFunction
      the result of the Bernstein operator.
Description
  Text
    This implements the operator
    $\sum_i (-1)^i q_{n+i} b_i^\perp$.
  Example
    A = hallLittlewoodRing(QQ[t], DegreeLimit => 8, Parameter => t)
    hallBernsteinQ(A, 2, Q_1)
    symmetricEquals(hallBernsteinQ(A, 2, Q_1), Q_{2,1})
SeeAlso
    hallBernsteinB
    hallAdjoint
///

doc ///
Key
    hallBernsteinB
    (hallBernsteinB, HLSymmetricRing, ZZ, HLSymmetricFunction)
    (hallBernsteinB, HLSymmetricRing, ZZ, List)
Headline
    apply the Hall-Littlewood Bernstein operator for the B basis
Usage
    hallBernsteinB(A,n,F)
    hallBernsteinB(A,n,lambda)
Inputs
    A:HLSymmetricRing
      a Hall-Littlewood expression ring.
    n:ZZ
      the part to append.
    F:HLSymmetricFunction
      the function being acted on.
    lambda:List
      an index for a @TT "B"@ basis element.
Outputs
    G:HLSymmetricFunction
      the result of the dual Bernstein operator.
Description
  Text
    This implements the operator
    $\sum_i (-1)^i b_{n+i} q_i^\perp$.
  Example
    A = hallLittlewoodRing(QQ[t], DegreeLimit => 8, Parameter => t)
    hallBernsteinB(A, 2, B_1)
    symmetricEquals(hallBernsteinB(A, 2, B_1), B_{2,1})
SeeAlso
    hallBernsteinQ
    hallAdjoint
///

doc ///
Key
    HLSeries
Headline
    a collected finite view of a coefficient-variable series
Description
  Text
    Objects of type @TO HLSeries@ are produced by @TO seriesCollect@. They
    store finitely many coefficients of an @TO HLSymmetricFunction@ with
    respect to a chosen coefficient-ring variable, grouping the display as a
    series in that variable.
  Example
    A = hallLittlewoodRing(QQ[t,z], DegreeLimit => 8, Parameter => t, AlphabetVariables => {z})
    seriesCollect(h_1/(1-z), z, DegreeLimit => 3)
SeeAlso
    seriesCollect
    seriesCoefficient
///

doc ///
Key
    adamsCoefficient
    (adamsCoefficient, HLSymmetricRing, ZZ, RingElement)
    (adamsCoefficient, HLSymmetricRing, ZZ, Number)
Headline
    apply an Adams operation to declared alphabet variables
Usage
    adamsCoefficient(A,k,c)
Inputs
    A:HLSymmetricRing
      a Hall-Littlewood expression ring.
    k:ZZ
      a positive integer.
    c:RingElement
      a coefficient.
Outputs
    d:RingElement
      the coefficient after replacing each declared alphabet variable by its @TT "k"@th power.
Description
  Text
    This is the coefficient-level operation used by plethysm. It is not
    ordinary exponentiation: if @TT "t"@ and @TT "z"@ are declared alphabet
    variables, then @TT "t+z"@ maps to @TT "t^k+z^k"@. The
    Hall-Littlewood parameter is always one of the alphabet variables.
  Example
    A = hallLittlewoodRing(QQ[t,z], DegreeLimit => 8, Parameter => t, AlphabetVariables => {z})
    adamsCoefficient(A, 3, t+z)
SeeAlso
    alphabetVariables
    hallPlethysm
///

doc ///
Key
    seriesCoefficient
    (seriesCoefficient, HLSymmetricFunction, RingElement, ZZ)
    seriesCollect
    (seriesCollect, HLSymmetricFunction, RingElement)
    seriesTerms
    (seriesTerms, HLSymmetricFunction, RingElement)
    seriesTruncate
    (seriesTruncate, HLSymmetricFunction, RingElement)
Headline
    collect or extract coefficients in a coefficient-ring series variable
Usage
    seriesCoefficient(f,z,n)
    seriesCollect(f,z)
    seriesTerms(f,z)
    seriesTruncate(f,z)
Inputs
    f:HLSymmetricFunction
      a Hall-Littlewood expression.
    z:RingElement
      a coefficient-ring variable.
    n:ZZ
      the exponent of @TT "z"@.
Outputs
    g:HLSymmetricFunction
      for @TT "seriesCoefficient"@ and @TT "seriesTruncate"@.
    S:HLSeries
      for @TT "seriesCollect"@.
    H:HashTable
      for @TT "seriesTerms"@.
Description
  Text
    These functions expand coefficient-ring rational functions as formal
    Laurent series at @TT "z=0"@. The displayed series is finite; use
    @TT "DegreeLimit"@ to choose the highest exponent and @TT "LowerLimit"@
    to include negative powers.
  Example
    A = hallLittlewoodRing(QQ[t,z], DegreeLimit => 8, Parameter => t, AlphabetVariables => {z})
    f = z^(-1)*S_1 + z*h_1 + z^2*(Q_1+h_2)
    seriesCoefficient(f,z,-1)
    seriesCoefficient(f,z,2)
    seriesCollect(f,z,DegreeLimit=>2,LowerLimit=>-1)
    seriesCollect(h_1/(1-z), z, DegreeLimit => 4)
    seriesTruncate(h_1/(1-z), z, DegreeLimit => 3)
SeeAlso
    HLSeries
    [hallLittlewoodRing, AlphabetVariables]
    hallPlethysm
///

doc ///
Key
    [seriesCollect, DegreeLimit]
    [seriesTerms, DegreeLimit]
    [seriesTruncate, DegreeLimit]
Headline
    choose the highest exponent retained in a collected series
Description
  Text
    This option sets the largest power of the chosen series variable retained
    by @TO seriesCollect@, @TO seriesTerms@, or @TO seriesTruncate@. If it is
    not specified, the degree limit of the Hall-Littlewood ring is used.
  Example
    A = hallLittlewoodRing(QQ[t,z], DegreeLimit => 8, Parameter => t, AlphabetVariables => {z})
    seriesCollect(h_1/(1-z), z, DegreeLimit => 3)
SeeAlso
    seriesCollect
    seriesCoefficient
///

doc ///
Key
    [seriesCollect, LowerLimit]
    [seriesTerms, LowerLimit]
    [seriesTruncate, LowerLimit]
Headline
    choose the lowest exponent retained in a collected series
Description
  Text
    This option sets the smallest power of the chosen series variable retained
    by @TO seriesCollect@, @TO seriesTerms@, or @TO seriesTruncate@. The
    default is @TT "0"@.
  Example
    A = hallLittlewoodRing(QQ[t,z], DegreeLimit => 8, Parameter => t, AlphabetVariables => {z})
    f = z^(-1)*S_1 + z*h_1
    seriesCollect(f, z, DegreeLimit => 1, LowerLimit => -1)
SeeAlso
    seriesCollect
    seriesCoefficient
///

doc ///
Key
    hallLittlewoodCFactor
    (hallLittlewoodCFactor, HLSymmetricRing, List)
    (hallLittlewoodCFactor, HLSymmetricRing, Sequence)
Headline
    compute the Hall-Littlewood c_lambda(t) factor
Usage
    hallLittlewoodCFactor(A,lambda)
Inputs
    A:HLSymmetricRing
      a Hall-Littlewood expression ring.
    lambda:List
      a partition.
Outputs
    c:RingElement
      the product $\prod_i\prod_{j=1}^{m_i(\lambda)}(1-t^j)$.
Description
  Example
    A = hallLittlewoodRing(QQ[t], DegreeLimit => 8, Parameter => t)
    hallLittlewoodCFactor(A,{2,1,1})
SeeAlso
    hallInnerProduct
///

doc ///
Key
    hallPlethysm
    (hallPlethysm, HLSymmetricFunction, HLSymmetricFunction)
    (hallPlethysm, Number, HLSymmetricFunction)
    (hallPlethysm, HLSymmetricFunction, Number)
    (hallPlethysm, RingElement, HLSymmetricFunction)
    (hallPlethysm, HLSymmetricFunction, RingElement)
Headline
    compute plethysm using the power-sum basis
Usage
    hallPlethysm(F,G)
Inputs
    F:HLSymmetricFunction
      the outer symmetric function.
    G:HLSymmetricFunction
      the inner symmetric function.
Outputs
    H:HLSymmetricFunction
      the plethysm, returned in the power-sum basis.
Description
  Text
    The binary operator @TT "**"@ is also defined for
    @TO HLSymmetricFunction@ objects and for scalar/expression pairs. It
    returns the Schur-basis conversion of the plethysm.

    If the inner argument has coefficients involving variables declared with
    @TT "AlphabetVariables"@, those coefficients are transformed by Adams
    operations. Thus @TT "p_k[t*p_1]"@ becomes @TT "t^k*p_k"@, and
    @TT "p_k[p_1+z]"@ becomes @TT "p_k+z^k"@.
  Example
    A = hallLittlewoodRing(QQ[t], DegreeLimit => 8, Parameter => t)
    hallPlethysm(h_2, h_1)
    hallPlethysm(h_1, 3 + h_1)
    S_2 ** S_1
    h_1 ** (3 + h_1)
    3 ** h_1
    B = hallLittlewoodRing(QQ[t,z], DegreeLimit => 8, Parameter => t, AlphabetVariables => {z})
    hallPlethysm(p_2, t*p_1 + z)
SeeAlso
    toP
    toS
    adamsCoefficient
///
