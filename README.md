# NBCoreDataController

NBCoreDataController is a simple and lightweight implementatoin of the elegant three-context scheme proposed by [Marcus Zarra](http://www.cimgf.com) for asynchronous CoreData saving, as [documented by Cocoanetics](http://www.cocoanetics.com/2012/07/multi-context-coredata/).

![Scheme](http://www.cocoanetics.com/files/Bildschirmfoto-2012-07-18-um-4.14.55-PM.png "Multi-Context CoreData stack with Asynchronous Saving (by Cocoanetics)")

It provides a shared instance with a CoreData stack for the default SQLite database and model created by Xcode templates, and provides a simple API for saving data in the background.

```objective-c
[[NBCoreDataController sharedInstance] saveWithBlock:^(NSManagedObjectContext *localContext) {
	// Do the heavy work here
} completion:^(BOOL success, NSError *error) {
	// Do something on the main thread after the save has been completed
}];
```

It also provides helpful [extensions](https://github.com/nunobaldaia/NBCoreDataController/blob/master/NSManagedObject%2BNBExtensions.h) to `NSManagedObject` for fetching and manipulating objects on any context.

## Problems
Since all changes flow from temporary background contexts through the main context up to the root (writing) context, the main context can suffer a [degrade in performance for intensive writing](http://floriankugler.com/2013/04/29/concurrent-core-data-stack-performance-shootout/). Also, reading from the root context will be locked while it is writing data.

For intensive reading/writing apps, or if you need something more configurable and complete, take a look into the popular [MagicalRecord](https://github.com/magicalpanda/MagicalRecord).

For regular data IO, this is a pretty simple architecture that's working fine on production for [Listary](http://listaryapp.com).