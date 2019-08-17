
FPGA Random number generator
============================

Generate random numbers on an FPGA using ringoscillators.

Example for Lattice parts:
(pick your poison in the Makefile)

* iCE40HX1K on "icestick" development board
* iCE40LP384 (custom board)
* LFE5UM5G-85F-8BG381 on "LFE5UM5G-85F-EVN" development board


Generates a metastable signal and uses this for random number generation.
Random data is sifted through a 16 bit LFSR to reduce effect of low entropy regions.
Then data is output over UART @3M Baud.
Also outputs metastable signal on a digital pin for verification on an oscilloscope.

Output data usually passes tests of [rngtest](https://linux.die.net/man/1/rngtest) and [NIST Entropy Assessment](https://github.com/usnistgov/SP800-90B_EntropyAssessment).
But don't hold me accountable. Entropy quality may heavily depend on FPGA fabric, routing and other effects.


Related work
------------

* [Original code](http://svn.clifford.at/handicraft/2015/ringosc/) by Clifford Wolf, but was changed a lot
* Using more advanced designs for TRNG on an FPGA:
  - [FPGA-based TRNG using Circuit Metastability with Adaptive Feedback Control](https://people.csail.mit.edu/devadas/pubs/ches-fpga-random.pdf)
  - [Slides for above](https://www.iacr.org/workshops/ches/ches2011/presentations/Session%201/CHES2011_Session1_2.pdf)
  - [FPGA PUF using programmable delay lines](https://www.researchgate.net/publication/224218293_FPGA_PUF_using_programmable_delay_lines)
  - [Ring Oscillator PUF Design and Results](http://class.ece.iastate.edu/cpre583/project_presentations/PUFs_report.pdf)

