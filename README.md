# QCEIMS x MNDO Excited-state molecular dynamics

The **[MNDO](https://www.kofo.mpg.de/en/institute/history/1993-to-present/theoretical-chemistry)** program is used to conduct excited-state molecular dynamics.

The **[GAMESS](https://www.msg.chem.iastate.edu/gamess/)** program is used to calculate the molecular orbital energy.

The **[Binary-Encounter-Bethe (BEB) model](https://physics.nist.gov/PhysRefData/Ionization/intro.html)** is used to calculate the ionization cross-section.

![image](https://user-images.githubusercontent.com/30486093/147525916-fb281061-6c6c-4dc4-97d0-756d5f55384c.png)

Where T is the energy of the impact electrons; B is the electron binding energy of MOi, U is the kinetic energy of MOi; the occupation number N of MOi is two for ground state molecules.![image](https://user-images.githubusercontent.com/30486093/147525928-cda95ca4-e4cd-4d64-bb13-9c2b5dae2152.png)

## Workflow of QCEIMS EXMD
1) The EI spectra are simulated under both ground state and excited state molecular dynamics.
2) The ionization cross section of different electronic state is calculated by BEB model.
3) The hybrid spectrum is generated by mix of different spectra, D<sub>0</sub> and D<sub>1</sub> for example, according to the ionization cross section.
![image](https://user-images.githubusercontent.com/30486093/147525775-8c71fe9d-691d-41e7-a1cf-63e72aa6fbf3.png)


