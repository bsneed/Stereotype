//
//  RFCoreData.h
//  Stereotype
//
//  Created by Brandon Sneed on 5/31/13.
//  Copyright (c) 2013 redf.net. All rights reserved.
//

// Refactored, improved and based on VPPCoreData.

//    Copyright (c) 2012 Víctor Pena Placer (@vicpenap)
//    http://www.victorpena.es/
//
//
//    Permission is hereby granted, free of charge, to any person obtaining a copy of
//    this software and associated documentation files (the "Software"), to deal in
//    the Software without restriction, including without limitation the rights to
//    use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
//    the Software, and to permit persons to whom the Software is furnished to do so,
//    subject to the following conditions:
//
//    The above copyright notice and this permission notice shall be included in all
//    copies or substantial portions of the Software.
//
//    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//    SOFTWARE.


#import <Foundation/Foundation.h>

@interface RFCoreData : NSObject

/** Specify the path where the database should be created.  If none is given, the 
 default location will be used. */
@property (nonatomic, copy) NSString *databasePath;

/** Specify the default database filename.  If none is given, database.sqlite will be used. */
@property (nonatomic, copy) NSString *databaseFilename;

/** Specify a filename to be copied from the bundle to start a database in a pre-made state. */
@property (nonatomic, copy) NSString *initialDatabaseFilename;

/** Returns a shared instance */
+ (RFCoreData *)sharedInstance;

/** Starts a new NSManagedObjectContext based on the current thread ID.  See
 commitContext and currentContext */
//- (void)beginContext;

/** Closes the NSManagedObjectContext for the current thread ID.  If there is
 unsaved content, it will be saved.  See beginContext and currentContext. */
//- (void)commitContext;

/** Returns the context for the current thread ID. */
- (NSManagedObjectContext *)currentContext;

/** Creates and returns a new object for the given entity. */
- (id) getNewObjectForEntity:(NSString *)entityName;

/** Returns the first object for the given entity that matches the given
 predicate. */
- (id) findObjectFromEntity:(NSString *)entity
              withPredicate:(NSPredicate *)predicate;

/** Counts all objects for the given entity that match the given predicate. */
- (NSUInteger) countObjectsForEntity:(NSString *)entity
                          filteredBy:(NSPredicate*)predicateOrNil;


/** Returns all objects for the given entity that match the given predicate.
 
 @param entity The objects' entity.
 @param sortDescriptors An array of `NSSortDescriptor`.
 @param predicateOrNil the predicate to filter the results.
 */
- (NSArray *) allObjectsForEntity:(NSString *)entity
                  sortDescriptors:(NSArray *)sortDescriptors
                       filteredBy:(NSPredicate *)predicateOrNil;


/** Returns all objects for the given entity that match the given predicate,
 ordered by the given attribute. */
- (NSArray *) allObjectsForEntity:(NSString *)entity
               orderedByAttribute:(NSString *)attributeOrNil
                        ascending:(BOOL)ascending
                       filteredBy:(NSPredicate *)predicateOrNil;

/** Returns a page of objects for the given entity that match the given predicate.
 
 @param entity The objects' entity.
 @param attributeOrNil the attribute used to sort the results. Can be `nil`.
 @param ascending Indicates whether the objects should be sorted ascending or
 descending (when ascending is NO).
 @param predicateOrNil the predicate to filter the results.
 @param fetchLimit the max amount of objects to retrieve.
 @param offset the page's offset.
 */
- (NSArray *) objectsForEntity:(NSString *)entity
            orderedByAttribute:(NSString *)attributeOrNil
                     ascending:(BOOL)ascending
                    filteredBy:(NSPredicate*)predicateOrNil
                    fetchLimit:(int)fetchLimit
                        offset:(int)offset;


/** Returns a page of objects for the given entity that match the given predicate.
 
 @param entity The objects' entity.
 @param sortDescriptors An array of `NSSortDescriptor`.
 @param predicateOrNil the predicate to filter the results.
 @param fetchLimit the max amount of objects to retrieve.
 @param offset the page's offset.
 */
- (NSArray *) objectsForEntity:(NSString *)entity
               sortDescriptors:(NSArray *)sortDescriptors
                    filteredBy:(NSPredicate*)predicateOrNil
                    fetchLimit:(int)fetchLimit
                        offset:(int)offset;


/** Removes all objects for the given entity. */
- (void) deleteAllObjectsFromEntity:(NSString *)entity;

/** Removes the given object. */
- (void) deleteObject:(id)object;

/** Saves all pending changes for the main managed object context.
 
 This operation would save all pending changes made to the objects that have
 been fetched through the main managed object context. */
- (void) saveAllChanges;

/** Refetches the given objects with the main managed object context.
 
 The specified `ids` array can hold objects from both `NSManagedObjectID` or
 `NSManagedObject`class. */
- (NSArray *) objectsWithExistingIDs:(NSArray *)ids;

/** Refetches the given object with the main managed object context.
 
 The specified `objectID` parameter can hold an object from both
 `NSManagedObjectID` or `NSManagedObject`class. */
- (id) objectWithExistingID:(id)objectID;

@end
