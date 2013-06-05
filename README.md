SMUGMath
========

SMUGMath is an open-source library (MIT License) that is designed for working with large vector data sets. Applications lie in signal processing and statistics, among many others.

As of this writing, there is only a cursory feature set. The SMUGRealVector and SMUGComplexVector classes are defined, along with a handful of useful operations on either type. There are also some unit tests included, which should help explain the various operations, and allow further tests to be easily written.

SMUGMath’s strength lies in its flexibility. You can easily add highly-tuned numerical operations by creating categories on either class, using Apple’s Accelerate framework, OpenCL, Grand Central Dispach, or any combination of them, to suit your application.


----

### Disclaimer


This is a github mirror for [SMUGMath](http://bitbucket.org/liscio/smugmath) project developed by Chris Liscio from [SuperMegaUltraGroovy](http://supermegaultragroovy.com).

You can read more about this project [here](http://supermegaultragroovy.com/2009/11/20/math-and-cocoa).

---

Files were converted to ARC and changed a little.
