# CohomologyZeroLociInHomogeneousVarieties

A package for working with homogeneous vector bundles and their zero loci.

## Installation

1. Download the repository (`Code > Download ZIP` on GitHub, or
   `git clone https://github.com/K3Ale/package-HomogeneousVarieties.git`).

2. Make the package visible to Macaulay2, using one of these two ways:

   **(a) Permanent:** copy the file `CohomologyZeroLociInHomogeneousVarieties.m2`
   and the folder `CohomologyZeroLociInHomogeneousVarieties/` into a directory
   that is in Macaulay2's `path` (for example the `code` folder inside
   `applicationDirectory()`; check with `path`).

   **(b) Per session:** in Macaulay2, add the downloaded folder to the path:

```m2
   path = prepend("/full/path/to/package-HomogeneousVarieties/", path)
```

3. Load the package:

```m2
   needsPackage "CohomologyZeroLociInHomogeneousVarieties"
```

4. (Optional) Install the package with its documentation:

```m2
   installPackage "CohomologyZeroLociInHomogeneousVarieties"
```

## Usage

WorkInProgress


## Requirements

- Macaulay2 ≥ 1.25.11 (needed for the `Python` package's `@@` syntax and NumPy support)
- The `Schubert2`, `Python`, and `WeylGroups` M2 packages (bundled with Macaulay2)
- Python with NumPy installed and reachable from M2's Python interface
  (see the M2 Python package tutorial on virtual environments if `numpy` is missing)


## Author

Alessandro Frassineti


