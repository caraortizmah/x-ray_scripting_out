# x-ray_scripting_out (Detailed example of use)

```
    Date: 06.07.22
    Author: Carlos Andrés Ortiz-Mahecha

```


### Usage

The pipeline is written in Shell script. It is recommendable to run it in linux SO.
You can run it either using `manager.sh` or `overall.sh`

If you are using `manager.sh`, the ORCA output can be placed in the same folder where all the scripts are placed.
But no other additional file should be there at the same time.

If you are using `overall.sh`, the list of ORCA outputs cannot be placed in the same folder where all the scripts are placed.
And no other additional file should be there at the same time.

### Prerequisites to run (inside the ORCA output)

The input required to run this pipeline is a XAS ouput from ORCA using `ROCIS/DFT` or `PNO-ROCIS/DFT`.
In this case, the input example is `AB_4.0A.out`.
The `AB_4.0A.out` file was done using `PNO-ROCIS/DFT`, it contains the molecular orbital (MO) L&ouml;wdin population

The L&ouml;wdin population looks as follows:

```
------------------------------------------
LOEWDIN REDUCED ORBITAL POPULATIONS PER MO
-------------------------------------------
THRESHOLD FOR PRINTING IS 0.1%
(...)
                      6         7         8         9        10        11   
                 -14.50765 -10.50448 -10.49076 -10.42139 -10.41074 -10.40620
                   2.00000   2.00000   2.00000   2.00000   2.00000   2.00000
                  --------  --------  --------  --------  --------  --------
 1 C  s               0.0       0.0       0.0       0.0       0.0      99.6
 2 C  s               0.0      99.6       0.0       0.0       0.0       0.0
 4 O  px              0.0       0.1       0.0       0.0       0.0       0.0
23 N  s              99.8       0.0       0.0       0.0       0.0       0.0
24 C  s               0.0       0.0       0.0       0.0      99.7       0.0
25 C  s               0.0       0.0      99.6       0.0       0.0       0.0
26 O  px              0.0       0.0       0.2       0.0       0.0       0.0
33 C  s               0.0       0.0       0.0      99.6       0.0       0.0
34 O  py              0.0       0.0       0.0       0.1       0.0       0.0
(...)

                    630       631   
                  78.09995  78.11164
                   0.00000   0.00000
                  --------  --------
 3 O  s               0.2       0.2
 4 O  s               0.5       0.3
26 O  s              13.5      61.6
27 O  s               4.1      20.7
34 O  s              81.7      17.2


                      *****************************
                      * MAYER POPULATION ANALYSIS *
                      *****************************
(...)
```

In the first group of six MOs are from the core space and the last two (in this example) belong to the virtual space.

In `AB_4.0A.out`, the XAS results has the folowing standard format of transitions by excited state with including the list of coupling MOs:

```
Eigenvectors of ROCIS calculation:
the threshold for printing is: 1e-02

  i->a            single excitation from orbital i to a
  i->t->a         single excitation from orbital i to a with a spin flip in orbital t
  i->t ; w->a     double excitation from orbital i to t and orbital w to a

STATE   0   Exc. Energy:   0.000mEh   0.000eV           0.0cm\*\*-1
        0                  :   1.0000  (1.000000)
(...)

STATE  25   Exc. Energy: 11123.847mEh  302.695eV     2441402.2cm\*\*-1
      13->93                :   0.0148   (-0.121820)
      19->93                :   0.0302   (0.173742)
      19->94                :   0.0204   (-0.142875)
      20->93                :   0.5270   (-0.725936)
      20->94                :   0.3885   (0.623308)

STATE  26   Exc. Energy: 11137.281mEh  303.061eV     2444350.6cm\*\*-1
      17->93                :   0.1316   (-0.362768)
      17->94                :   0.8630   (-0.928977)

STATE  27   Exc. Energy: 11138.907mEh  303.105eV     2444707.6cm\*\*-1
      13->93                :   0.7734   (0.879424)
      13->94                :   0.1133   (0.336583)
      14->93                :   0.0236   (0.153467)
      16->93                :   0.0577   (-0.240214)
      20->93                :   0.0157   (-0.125407)
(...)
Calculating transition densities   ...Done
(...)
```

There are more format versions for presenting the excited states and the MO coupling transitions.
This pipeline just **accepts** the format presented below.

### Run

`manager.sh` is the main script that runs all the scripts following their evident sequential step names. 
The way of running is by typing:

     $ ./manager.sh $1 $2 $3 $4 $5 $6 $7 $8

where:

    `$1` and `$2` are the atom range (initial and final atom) that represents a first molecular region target in the whole protein or peptide calculation
    `$3` and `$4` are the atom range (initial and final atom) that represents a second molecular region target in the whole protein or peptide calculation
    `$5` and `$6` are the core MO range (initial and final MO) corresponding to C 1s (in the furute will be adapt to N, O and S)
    `$7` is the XAS ORCA output
    `$8` is the excited state range described by two numbers jount by the character '-'

Examples of this in the following part.

`overall.sh` is another script that you can use to start the pipeline, the only difference is that overall is intended for a list of ORCA outputs.
So in this case you will repeat the pipeline the same number of times as number of ORCA outputs you present.

The only condition to run using `overall.sh` is to save all the ORCA outputs in another folder.

     $ .overall.sh $DIR

where:
     
     $DIR is the path where the list of ORCA outputs are placed (only ORCA output files!)

### Example:

`AB_4.0A.out` is an ORCA output that represents a system of two amino acids, face-to-face oriented by the side aromatic chain.
Phenylalanine (F) and tyrosine (Y) pair has a stacking distance of 4.0\AA.

The F is in the atom range 0 to 22.
The Y in the atom range 23 to 46.
The core MOs for C 1s are in the range of 7 to 24.
The information presented in matricial form will be constructed using the excited-state information list in the output since the 
excited state 1 up to the excited state 17.

     $ ./manager.sh 0 22 23 46 7 24 AB_4.0A.out 1-17

If you want to take all the excited states from `AB_4.0A.out` then $8 should be called none:

     $ ./manager.sh 0 22 23 46 7 24 AB_4.0A.out none


