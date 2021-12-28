# QCEIMS x MNDO Excited-state molecular dynamics

The **[MNDO](https://www.kofo.mpg.de/en/institute/history/1993-to-present/theoretical-chemistry)** program is used to conduct excited-state molecular dynamics.

The **[GAMESS](https://www.msg.chem.iastate.edu/gamess/)** program is used to calculate the molecular orbital energy.

The **[Binary-Encounter-Bethe (BEB) model](https://physics.nist.gov/PhysRefData/Ionization/intro.html)** is used to calculate the ionization cross-section.

![image](https://user-images.githubusercontent.com/30486093/147526011-6021876e-d079-4ddb-82fb-44bbe74d810b.png)
*Where T is the energy of the impact electrons; B is the electron binding energy of MO<sub>i</sub> , U is the kinetic energy of MO<sub>i</sub> ; the occupation number N of MO<sub>i</sub> is two for ground state molecules.*

A modified **[QCEIMS](QCEIM_module/qceims_mndo)** excutable program is used to conduct EXMD simulation.
## Workflow of QCEIMS EXMD
1) The EI spectra are simulated under both ground state and excited state molecular dynamics.
2) The ionization cross section of different electronic state is calculated by BEB model.
3) The hybrid spectrum is generated by mix of different spectra, D<sub>0</sub> and D<sub>1</sub> for example, according to the ionization cross section.
![image](https://user-images.githubusercontent.com/30486093/147525775-8c71fe9d-691d-41e7-a1cf-63e72aa6fbf3.png)
## Pipline using SLURM Workload Manager
### array_mndo.slurm
Slurm script to conduct ground/excited state MD and generate spectra of each.<br /> 
The mndo.opt and qceims.in is needed to run this batch command.<br />
**To use:**

sbatch<br />
  > --job-name=**name**<br />
  > --array=a-b **job list**<br />
  > --parsable array_mndo.slurm **this slurm file** <br />
  >> **work path**<br />
  >> **user name**<br />
  
Exapmle:
  ```bash
  sbatch   --job-name=array --array=1-400 --parsable array_molcas.slurm /home/ user1
  ```
## User defined command of EXMD (MNDO.opt)
**iroot=2 icross=1 ioutci=1 kci=5 ncigrd=1 +**

  iroot: Total number of lowest CI states computed.<br />
  icross: Choice of multi-surface treatment.<br />
    icross=1 Calculate energies and gradients for the states
        specified by ncigrd.<br />
  ioutci:Printing flag.<br />
  kci: Choice of correlation treatment.<br />
    kci=5 General configuration interaction based on the
        graphical unitary group approach (GUGA-CI).<br />
  ncigrd: Number of CI gradients to be computed.<br />

**movo=-4 ici1=1 ici2=1 nciref=1 +**

  movo: Explicit definition of active orbitals.<br />
    =-4 Include MOs with highest d-population in active space.<br />
      For details see description in GUGA section 3.9.<br />
  ici1: Number of active occupied orbitals.<br />
  ici2: Number of active unoccupied orbitals.<br />
  nciref: Number of reference occupations.<br />
    =1: SCF configuration, provided that the spin
    multiplicity is the same for the SCF and CI calculations.<br />
    
**mciref=0 levexc=2 +**

  Definition of reference occupations.<br />
        = 0 Chosen by default, no further input.<br />

  levexc: Maximum excitation level relative to any of the reference
          configurations.
          = 1 CIS, only single excitations.<br />
          = 2 CISD, up to double excitations.<br />

an input example for mndo99 generated by qceims is listed as **[inp](example_input/inp)**.
