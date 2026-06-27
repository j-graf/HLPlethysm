newPackage(
    "HallLittlewood",
    Version => "0.2",
    Date => "June 26, 2026",
    Authors => {
        {Name => "John Graf", Email => "jrgraf@udel.edu", HomePage => "https://j-graf.github.io/"}},
    Headline => "mixed-basis Hall-Littlewood symmetric functions",
    HomePage => "https://j-graf.github.io/",
    Keywords => {"Combinatorics"},
    AuxiliaryFiles => true,
    DebuggingMode => false
    )

export {
    "hallLittlewoodRing", "HLSymmetricRing", "HLSymmetricFunction",
    "HLIndexedVariableTable", "HLSeries", "Parameter", "AlphabetVariables", "LowerLimit", "ChunkSize", "hlParameter", "alphabetVariables",
    "degreeLimit", "hlPartitions", "conjugatePartition",
    "partitionWeight", "partitionLength", "straighten", "symmetricEquals",
    "omegaInvolution", "multSchur",
    "toP", "toH", "toE", "toM", "toF", "toS", "toSomega", "toHallP", "toR", "toQ", "toB",
    "toSFromh", "toSomegaFrome", "toQFromq", "toBFromb", "triangularReduce",
    "toHFromp", "toEFromp", "toSFromp", "toSomegaFromp", "toStest", "toSgrevlexTest", "toSChunkedTest", "toSPieriTest", "toSfromhFast",
    "toPHash", "toHHash", "toEHash", "toMHash", "toFHash", "toSHash", "toSomegaHash", "toHallPHash", "toRHash", "toQHash", "toBHash",
    "adamsCoefficient", "seriesCoefficient", "seriesCollect", "seriesTerms", "seriesTruncate",
    "hallPlethysm", "hallInnerProduct", "hallAdjoint", "hallBernsteinQ",
    "hallBernsteinB", "hallLittlewoodCFactor"
    }

load(currentFileDirectory | "HallLittlewood/HLSymmetricFunctions.m2")

beginDocumentation()

load(currentFileDirectory | "HallLittlewood/documentation.m2")

load(currentFileDirectory | "HallLittlewood/tests.m2")

end--
