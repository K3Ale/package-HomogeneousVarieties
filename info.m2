-- -*- M2 -*-

newPackage(
    "CohomologyZeroLociInHomogeneousVarieties",
    Version => "1.0",
    Date => "Settembre 2026",
    Authors => {
        {Name => "K3Ale", Email => "tua.email@example.com"}
    },
    Headline => "Cohomology and zero loci in homogeneous varieties",
    Description => "A package for working with homogeneous vector bundles and their zero loci",
    DebuggingMode => false,
    CacheExampleOutput => true,
    PackageExports => {
        -- Elenca le tue funzioni principali qui
    },
    PackageImports => {}
    )

-- Carica il file principale
load "CohomologyZeroLociInHomogeneousVarieties/CohomologyZeroLociInHomogeneousVarieties.m2"
