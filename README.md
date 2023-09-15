# x-ray_scripting_out

```
    Date: 06.07.22
    Author: Carlos Andrés Ortiz-Mahecha

```
[comment]: <> (****)
[comment]: <> (First version: 20.03.23)
[comment]: <> (comment:)
[comment]: <> (First version to obtain core-virtial MO matrices having by values: transition intensities, force oscillator strenght and transition intensity probabilities)
[comment]: <> (Updated as a package - 15.9.23. Other two upgraded versions already exist and will be updated soon)
[comment]: <> (****)

`x-ray_scripting_out` is a pipeline that manipulates X-ray absoprtion spectra (XAS) outputs from ORCA quantum computational software. The main goal is to use the force oscillator strenght and transition intensity probabilities to get the core-virtual coupling MOs as matrices.
New set of outputs combine the transition intensity probabilities and the force oscillator strenght to create matrices in terms of MOs from the core and virtual space. This information in these matrices represents a core-virtual coupling MO such as:

     1. Number of transition intensities
     2. Transition intensity probability
     3. Force oscillator strenght
     
### Download

To get the git version type

    $ git clone https://github.com/caraortizmah/x-ray_scripting_out.git

### Usage

The pipeline is written in Shell script. It is recommendable to run it in linux SO.
You can run it either using `manager.sh` or `overall.sh`

### Prerequisites to run

The input required to run this pipeline is a XAS ouput from ORCA using `ROCIS/DFT` or `PNO-ROCIS/DFT`. And this input file should contain the molecular orbital (MO) L&ouml;wdin population, and the standard format of transitions by excited state with the list of coupling MOs.
You can set a localized number of atoms involved in the coupling MOs transitions, i.e., understanding the coupling MOs transitions between two group of atoms, e.g., two amino acids in a protein.

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

### Example:

Using as molecule a pair of amino acids: phenylalanine (F) and tyrosine (Y) face-to-face separated by 4.0\AA.
The F is in the atom range 0 to 22 and Y in the atom range 23 to 46 and the core MOs for C 1s are in the range of 7 to 24.
The information presented in matricial form will come from the ouput `FY_output.out` in the excited-state range number of 1 to 17.

     $ ./manager.sh 0 22 23 46 7 24 FY_output.out 1-17

More information about the running in `example/readme.md`

### Requirements - Linux text processing tool

* grep
* cut
* awk
* sed
* vim
