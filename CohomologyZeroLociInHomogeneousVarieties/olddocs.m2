
beginDocumentation()

document {Key => {CohomologyZeroLociInHomogeneousVarieties},
Headline => "Multi-Homogeneous varieties and homogeneous vector bundle"
}

document {Key => {HomogeneousVariety}, 
    Headline => "the class of all homogeneous varieties",
    PARA {"A ",EM"homogeneous variety"," is an algebraic variety which is isomorphic to the quotient of a semisimple Lie group ",TEX///$G$///,"by a parabolic subgroup ",TEX///$P$///,"."},
    Subnodes => {TO "homogeneousVariety"}
    }

document {Key => {EmbeddedVariety}, 
    Headline => "the class of all varieties embedded in homogeneous spaces",
    PARA {"An ",EM"embedded variety"," is an algebraic variety which is a subvariety of a homogeneous variety with normal bundle a homogeneous vector bundle."},
    Subnodes => {TO "embeddedVariety"}
    }

document {Key => {ParabolicGroup}, 
    Headline => "the class of all parabolic subgroups of a given Lie group",
    Subnodes => {TO "newParabolic"}
    }

document {Key => {MultiHomogeneousVariety},
    Headline => "the class of all multi-homogeneous varieties"
    }

document {Key => {HomogeneousVectorBundle},
    Headline => "the class of all homogeneous (completely reducible) vector bundles",
    Subnodes => {TO "homogeneousVectorBundle"}
    }

document {Key => {FiltrationBundle},
    Headline => "the class of all homogeneous vector bundles",
    Subnodes => {TO "filtrationBundle"}
    }

document {Key => {LineBundle},
    Headline => "the class of all line bundles",
    Subnodes => {TO "lineBundle"}
    }

document {Key => {newParabolic, (newParabolic,RootSystem,Set)},
    Headline => "the parabolic subgroup defined by a subset of the fundamental roots of a given root system",
    Usage => "newParabolic(R,S)",
    Inputs => {"R" => RootSystem => {"a root system..."}, "S" => Set => "a set of integers correspondings to the fundamental roots associated to the parabolic subgroup"},
    Outputs => {ParabolicGroup => {"the parabolic subgroup of the semisimple Lie group with root system ",TEX///$R$///," given by the fundamental roots in ", TEX///$S$///,"."}}
    }

document {Key => {homogeneousVariety, (homogeneousVariety, RootSystem, ParabolicGroup)},
    Headline => "the homogeneous variety given by the quotient by the parabolic subgroup of the corresponding Lie group",
    Usage => "homogeneousVariety (R,P)",
    Inputs => {"R" => RootSystem => {"a root system..."}, "P" => ParabolicGroup},
    Outputs => {HomogeneousVariety}
    }

document {Key => {embeddedVariety, (embeddedVariety, HomogeneousVectorBundle)},
    Headline => "the algebraic variety given by the zero locus of a general global section of the vector bundle",
    Usage => "embeddedVariety F",
    Inputs => {"F" => HomogeneousVectorBundle => {"a homogeneous vector bundle"}},
    Outputs => {EmbeddedVariety}
    }
	
document {Key => {lineBundle, (lineBundle, Weight, HomogeneousVariety)},
    Headline => "the line bundle corresponding to the given weight",
    Usage => "lineBundle(l,X)",
    Inputs => {"l" => Weight, "X" => HomogeneousVariety},
    Outputs => {LineBundle}
    }

document {Key => {homogeneousVectorBundle, (homogeneousVectorBundle, List, List, HomogeneousVariety)},
    Headline => "the completely reducible homogeneous vector bundle associated to the given list of (global) weights",
    Usage => "homogeneousVectorBundle(S,X)",
    Inputs => {"S" => List => {"the list of (global) weights"}, "m" => List => {"the list of multiplicities of the weights"}, "X" => HomogeneousVariety},
    Outputs => {HomogeneousVectorBundle}
    }

document {Key => {filtrationBundle, (filtrationBundle, List, HomogeneousVariety)},
    Headline => "the homogeneous vector bundle associated to the given list of homogeneous vector bundles which are the factors of the resulution of the bundle",
    Usage => "filtrationBundle(S,X)",
    Inputs => {"S" => List => {"the list of factors"}, "X" => HomogeneousVariety},
    Outputs => {FiltrationBundle}
    }

document {Key => {weylFormula, (weylFormula, Weight, RootSystem)},
    Headline => "the dimension of the irreducible representation of heighest weight ",TT"l", " computed through Weyl's formula",
    Usage => "weylFormula(l,R)",
    Inputs => {"l" => Weight, "R" => RootSystem},
    Outputs => {ZZ => {"the dimension of the irreducible representation"}}
    }
-*
document {Key => {dim, (dim, HomogeneousVariety)},
    Headline => "the dimension of the homogeneous variety ",TT"X", " ",
    Usage => "dim X",
    Inputs => {"X" => HomogeneousVariety},
    Outputs => {ZZ => {"the dimension of the homogeneous variety"}}
    }

document {Key => {dim, (dim, EmbeddedVariety)},
    Headline => "the dimension of the variety ",TT"Y", " ",
    Usage => "dim Y",
    Inputs => {"Y" => EmbeddedVariety},
    Outputs => {ZZ => {"the dimension of the variety"}}
    }

document {Key => {rank, (rank, HomogeneousVectorBundle)},
    Headline => "the rank of the vector bundle ",TT"E", ", computed using the Weyl's formula ",
    Usage => "rank E",
    Inputs => {"E" => HomogeneousVectorBundle},
    Outputs => {ZZ => {"the rank of the vector bundle"}}
    }

document {Key => {rank, (rank, FiltrationBundle)},
    Headline => "the rank of the vector bundle ",TT"E", ", computed using the Weyl's formula ",
    Usage => "rank E",
    Inputs => {"E" => FiltrationBundle},
    Outputs => {ZZ => {"the rank of the vector bundle"}}
    }
*-
---------------------- Chern classes ---------------------------------------------------------------------------

document {Key => {chern, (chern, ZZ, HomogeneousVariety)},
    Headline => "the chern classes of the variety ",TT"X", ", computed summing the parabolic parts of the positive roots ",
    Usage => "chern(p,X)",
    Inputs => {"X" => HomogeneousVariety},
    Outputs => {Vector => {"the p-th chern class of the variety"}}
    }

----------------------------------------------------------------------------------------------------------------

document {Key => {bott, (bott, HomogeneousVectorBundle)},
    Headline => "the theorem of Bott applied to a completely reducible homogeneous vector bundle",
    Usage => "bott E",
    Inputs => {"E" => HomogeneousVectorBundle},
    Outputs => {List => {"the dimensions of the graded pieces of the cohomology of ", TT"E"}}
    }


document {Key => {borelWeil, (borelWeil, LineBundle)},
    Headline => "the theorem of Borel-Weil applied to a line bundle",
    Usage => "borelWeil L",
    Inputs => {"L" => LineBundle},
    Outputs => {List => {"the dimensions of the graded pieces of the cohomology of ", TT"L"}}
    }

document {Key => {isAmple, (isAmple, LineBundle)},
    Headline => "checks whether a line bundle is ample",
    Usage => "isAmple L",
    Inputs => {"L" => LineBundle},
    Outputs => {Boolean}
    }
    

