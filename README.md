
FPGA Random number generator
============================

Generate random numbers on an FPGA using ringoscillators.

Example for Lattice ice40 FPGAs "icestick". Originally from http://svn.clifford.at/handicraft/2015/ringosc/ but much improved now.

Generates a metastable signal and uses this for random number generation.
Random data is sifted through a 16 bit LFSR to reduce effect of low entropy regions.
Then data is output over UART @3M Baud.
Also outputs metastable signal on a digital pin for verification on an oscilloscope.

Output data usually passes tests of [rngtest](https://linux.die.net/man/1/rngtest) and [NIST Entropy Assessment](https://github.com/usnistgov/SP800-90B_EntropyAssessment).
But don't hold me accountable. Entropy quality may heavily depends on routing, and FPGA fabric.

