
## Example files:

1. `AB_4.0A.out` for S'=S (option `0`)
2. `AB_4.1A.out` for S'=S+1 and SOC evaluation (option `1`).
3. `AB_5.0A.out` for S'=S+1 and SOC evaluation (option `1`).


`AB_4.0A.out` is an ORCA output representing a system of two amino acids, oriented face-to-face by their side aromatic chains.
The phenylalanine (F) and tyrosine (Y) pair are stacked with a distance of 4.0 Å.

- The F (phenylalanine) atoms are in the range 0 to 22 for the core space.
- The Y (tyrosine) atoms are in the range 23 to 46 for the virtual space.
- The core MOs for C 1s are in the range from 7 to 24. 

The matrix-formatted information will be constructed using the excited-state data from the output, covering excited states 1 through 17.

     $ ./manager.sh 0 22 23 46 7 24 AB_4.0A.out 1-17

If you want to include all the excited states from `AB_4.0A.out`, then $8 should be set to "none" (no quotes):

     $ ./manager.sh 0 22 23 46 7 24 AB_4.0A.out none

`AB_4.1A.out` is the same ORCA calculation as `AB_4.0A.out`, representing a face-to-face orientation by the side aromatic chain. The pair interaction also has a stacking distance of 4.0 Å. 

The **only difference** is that `AB_4.1A.out` includes a higher multiplicity and spin-orbit coupling (SOC) evaluation.

The calculation offers two options: `0` for S' = S and `1` for S' = S + 1 with SOC evaluation. 
Therefore, `AB_4.0A.out` corresponds to option `0` (S' = S) and `AB_4.1A.out` corresponds to option `1` (S' = S + 1 with SOC evaluation).

## Sulfur case

`AB_5.0A.out` is an ORCA output representing a system of two amino acids, oriented face-to-face by their side aromatic chains.
The metionine (M) and triptophane (W) pair are stacked with a distance of 5.0 Å, uses S as core atom for p typ or core molecular orbitals.

This calculation corresponds better the SOC evaluation options.


## Missing Information, Explanations, or Examples

There may be exceptions or cases not covered in this documentation. Please feel free to contact me for further details.
