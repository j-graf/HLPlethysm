TEST ///
A = hallLittlewoodRing(QQ[t]);
assert(h_0 == p_0);
assert(q_0 == p_0);
assert(q_-1 + p_0 == p_0);
assert(p_2 + h_5 == h_5 + p_2);
assert(toP(h_2) == 1/2*p_{1,1} + 1/2*p_2);
assert((p_2+h_1)*(p_1+h_2) == p_2*p_1 + p_2*h_2 + h_1*p_1 + h_1*h_2);
assert(q_{2,1}*b_3 == q_2*q_1*b_3);
assert(S_1*h_2 == h_2*S_1);
assert(m_2*p_1 == p_1*m_2);
///

TEST ///
A = hallLittlewoodRing(QQ[t], DegreeLimit => 12, Parameter => t);
assert(S_{5,1,3} == S_{5,1,3});
assert(straighten S_{5,1,3} == -S_{5,2,2});
assert(straighten Somega_{5,1,3} == -Somega_{5,2,2});
assert(straighten Q_{1,2} == t*Q_{2,1});
assert(straighten B_{1,2} == t*B_{2,1});
assert(toH(S_{2,1}) == h_{2,1} - h_3);
assert(toE(Somega_{2,1}) == e_{2,1} - e_3);
assert(symmetricEquals(S_{2,1}, h_{2,1} - h_3));
assert(symmetricEquals(Somega_3, S_{1,1,1}));
///

TEST ///
A = hallLittlewoodRing(QQ[t], DegreeLimit => 12, Parameter => t);
Qm = toMHash(q_2);
Bm = toMHash(b_2);
assert(Qm#?{2});
assert(Qm#{2} == 1-t);
assert(Bm#{2} == t^2-t);
assert(toQ(Q_{2,1}) == Q_{2,1});
assert(toB(B_{2,1}) == B_{2,1});
assert(symmetricEquals(P_2, 1/(1-t)*Q_2));
assert(toHallP(Q_2) == (1-t)*P_2);
assert(symmetricEquals(R_2, 1/(1-t)*B_2));
assert(toR(B_2) == (1-t)*R_2);
///

TEST ///
A = hallLittlewoodRing(QQ[t], DegreeLimit => 12, Parameter => t);
assert(hallInnerProduct(q_{2,1}, m_{2,1}) == 1);
assert(symmetricEquals(hallBernsteinQ(A, 2, Q_1), Q_{2,1}));
assert(symmetricEquals(hallBernsteinB(A, 2, B_1), B_{2,1}));
///

TEST ///
A = hallLittlewoodRing(QQ[t], DegreeLimit => 12, Parameter => t);
assert(omegaInvolution(q_2*e_4) == b_2*h_4);
assert(omegaInvolution(h_{2,1}) == e_{2,1});
assert(omegaInvolution(m_{2,1}) == f_{2,1});
assert(omegaInvolution(f_{2,1}) == m_{2,1});
assert(omegaInvolution(Q_{2,1}) == B_{2,1});
assert(omegaInvolution(P_{2,1}) == R_{2,1});
assert(omegaInvolution(R_{2,1}) == P_{2,1});
assert(omegaInvolution(S_{2,1}) == Somega_{2,1});
assert(omegaInvolution(Somega_{2,1}) == S_{2,1});
assert(omegaInvolution(S_{5,1,3}) == Somega_{5,1,3});
assert(toSomega(S_3) == Somega_{1,1,1});
assert(omegaInvolution(p_2*p_1) == -p_2*p_1);
assert(symmetricEquals(f_2, -m_2));
///

TEST ///
A = hallLittlewoodRing(QQ[t], DegreeLimit => 12, Parameter => t);
assert(toString skewQ_({4,2,1},{2,1}) == "skewQ_({4,2,1},{2,1})");
assert(skewQ_({4,2,1,0},{2,1,0}) == skewQ_({4,2,1},{2,1}));
assert(omegaInvolution(skewQ_({4,2,1},{2,1})) == skewB_({4,2,1},{2,1}));
assert(omegaInvolution(skewP_({4,2,1},{2,1})) == skewR_({4,2,1},{2,1}));
assert(omegaInvolution(skewS_({4,2,1},{2,1})) == skewSomega_({4,2,1},{2,1}));
assert(toH skewS_({2,1},{1}) == h_{1,1});
assert(toE skewSomega_({2,1},{1}) == e_{1,1});
assert(toQ skewQ_({2},{}) == Q_2);
assert(toHallP skewP_({2},{}) == P_2);
assert(toB skewB_({2},{}) == B_2);
assert(toR skewR_({2},{}) == R_2);
///

TEST ///
A = hallLittlewoodRing(QQ[t], DegreeLimit => 12, Parameter => t);
assert(multSchur(S_1, S_1) == S_2 + S_{1,1});
assert(multSchur(S_{2,1}, S_1) == S_{3,1} + S_{2,2} + S_{2,1,1});
assert(multSchur(S_{2,1}, S_2) == toS(S_{2,1}*S_2));
///

TEST ///
A = hallLittlewoodRing(QQ[t], DegreeLimit => 12, Parameter => t);
assert(toSFromh(h_{2,1} - h_3) == S_{2,1});
assert(toSFromh(h_1*h_1) == S_2 + S_{1,1});
assert(toSomegaFrome(e_{2,1} - e_3) == Somega_{2,1});
assert(toQFromq(q_{2,1} + (t-1)*q_3) == Q_{2,1});
assert(toBFromb(b_{2,1} + (t-1)*b_3) == B_{2,1});
K = A#"CoefficientRing";
H = triangularReduce(A, "S", "h", new HashTable from {{2,1} => 1_K, {3} => -1_K});
assert(#keys H == 1);
assert(H#?{2,1});
assert(H#{2,1} == 1_K);
///

TEST ///
A = hallLittlewoodRing(QQ[t], DegreeLimit => 12, Parameter => t);
u = p_{2,1} + 3*p_3;
assert(toHFromp(u) == toH(u));
assert(toEFromp(u) == toE(u));
assert(toHFromp p_3 == h_1*h_1*h_1 - 3*h_1*h_2 + 3*h_3);
assert(toEFromp p_3 == e_1*e_1*e_1 - 3*e_1*e_2 + 3*e_3);
assert(toSFromp(p_2*p_1) == toS(p_2*p_1));
assert(toSomegaFromp(p_2*p_1) == toSomega(p_2*p_1));
v = p_2*p_1 + 3*p_3;
assert(toS(v) == 4*S_3 - 3*S_{2,1} + 2*S_{1,1,1});
assert(toSomega(v) == 2*Somega_3 - 3*Somega_{2,1} + 4*Somega_{1,1,1});
assert(toP(toQ(v)) == toP(v));
assert(toP(toB(v)) == toP(v));
assert(toStest(v) == toS(v));
assert(toSgrevlexTest(v) == toS(v));
assert(toSChunkedTest(v) == toS(v));
assert(toSChunkedTest(v, ChunkSize=>8) == toS(v));
assert(toSPieriTest(v) == toS(v));
assert(toSfromhFast(toH v) == toS(v));
assert(toSfromhFast(h_{3,2} - h_4*h_1 + 2) == toSFromh(h_{3,2} - h_4*h_1 + 2));
assert(toSPieriTest(h_{3,2}) == S_5 + S_{4,1} + S_{3,2});
assert(sum apply(hlPartitions 5, lambda -> S_lambda) == S_5 + S_{4,1} + S_{3,2} + S_{3,1,1} + S_{2,2,1} + S_{2,1,1,1} + S_{1,1,1,1,1});
assert(sum {S_1, 1} == S_1 + 1);
assert(sum {1, S_1} == S_1 + 1);
///

TEST ///
A = hallLittlewoodRing(QQ[t], DegreeLimit => 12, Parameter => t);
assert(toString(Q_2*B_3*q_5*b_1*S_{2,1}*Somega_3*h_4*p_1*m_2*f_1)
    == "Q_2B_3q_5b_1S_{2,1}Somega_3h_4p_1m_2f_1");
assert(toString(h_3*h_4 + e_1*e_5 + h_4*h_3 + Q_1 + B_2 + p_7)
    == "Q_1 + B_2 + 2h_4h_3 + e_5e_1 + p_7");
assert(toString(h_1 + 3*p_0 + Q_1) == "Q_1 + h_1 + 3");
///

TEST ///
A = hallLittlewoodRing(QQ[t], DegreeLimit => 12, Parameter => t);
assert(3 + h_1 == h_1 + 3);
assert((3 + h_1) - 3 == h_1);
assert(3 - h_1 == -(h_1 - 3));
assert(t + h_1 == h_1 + t);
assert(toString(1/2 + S_1) == "S_1 + 1/2");
assert(hallPlethysm(h_1, 3 + h_1) == p_1 + 3);
assert(h_1 ** (3 + h_1) == S_1 + 3);
assert(3 ** h_1 == 3*p_0);
assert(h_1 ** 3 == 3*p_0);
///

TEST ///
A = hallLittlewoodRing(QQ[t], DegreeLimit => 12, Parameter => t);
assert(toP(hallPlethysm(h_2, h_1)) == toP(h_2));
assert((S_2 ** S_1) == S_2);
///

TEST ///
B = hallLittlewoodRing(QQ[t,z], DegreeLimit => 6, Parameter => t);
assert(alphabetVariables B == {t});
assert(hallPlethysm(p_2, t*p_1) == t^2*p_2);
A = hallLittlewoodRing(QQ[t,z,w], DegreeLimit => 6, Parameter => t, AlphabetVariables => {z,w});
assert(alphabetVariables A == {t,z,w});
assert(adamsCoefficient(A, 2, t + z + t*w) == t^2 + z^2 + t^2*w^2);
assert(hallPlethysm(p_2, t*p_1 + z) == t^2*p_2 + z^2);
assert(hallPlethysm(p_3, (t+z)*p_1) == (t^3+z^3)*p_3);
f = z^(-1)*S_1 + z*h_1 + z^2*(Q_1+h_2);
assert(seriesCoefficient(f,z,-1) == S_1);
assert(seriesCoefficient(f,z,2) == Q_1 + h_2);
assert(toString seriesCollect(f,z,DegreeLimit=>2,LowerLimit=>-1)
    == "S_1z^-1 + h_1z + (Q_1 + h_2)z^2 + O(z^3)");
g = h_1/(1-z);
assert(seriesCoefficient(g,z,4) == h_1);
assert(toString seriesCollect(g,z,DegreeLimit=>3)
    == "h_1 + h_1z + h_1z^2 + h_1z^3 + O(z^4)");
assert(seriesTruncate(g,z,DegreeLimit=>3) == (1+z+z^2+z^3)*h_1);
///
