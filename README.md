NBCoreDataController
====================

Thin multi-context CoreData stack with asynchronous saving based on the [Multi-Context CoreData](http://www.cocoanetics.com/2012/07/multi-context-coredata/) article by Cocoanetics.

This is a lighweight alternative to the popular [MagicalRecord](https://github.com/magicalpanda/magicalrecord) the following goals:

1. Setup a multi-context CoreData stack with asynchronous saving
2. Provide a block based solution to save data on background
3. Provide a minimum set of helpers to deal with managed objects