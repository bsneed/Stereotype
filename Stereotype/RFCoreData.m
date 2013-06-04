//
//  RFCoreData.m
//  Stereotype
//
//  Created by Brandon Sneed on 5/31/13.
//  Copyright (c) 2013 redf.net. All rights reserved.
//

#import "RFCoreData.h"

@implementation RFCoreData
{
    NSManagedObjectContext *_mainContext;
    NSPersistentStoreCoordinator *_persistentStoreCoordinator;
    NSManagedObjectModel *_managedObjectModel;
    NSString *_persistentStoreType;
}

+ (RFCoreData *)sharedInstance
{
    static dispatch_once_t onceToken;
    static id __instance = nil;
    dispatch_once(&onceToken, ^{
        __instance = [[[self class] alloc] init];
    });
    
    return __instance;
}

- (id)init
{
    self = [super init];
    
    self.databasePath = [[self applicationDocumentsDirectory] copy];
    self.databaseFilename = @"database.sqlite";
    
    return self;
}

- (NSManagedObjectContext *)currentContext
{
    NSMutableDictionary *threadDictionary = [NSThread currentThread].threadDictionary;
    NSManagedObjectContext *currentContext = [threadDictionary objectForKey:@"rfcoredata.threadContext"];
    if (!currentContext)
    {
        currentContext = [self createManagedObjectContext];
        [threadDictionary setObject:currentContext forKey:@"rfcoredata.threadContext"];
    }
    
    return currentContext;
}

#pragma mark - Utilities

- (NSString *)applicationDocumentsDirectory
{
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

#pragma mark - CoreData stack

- (NSManagedObjectContext *)createManagedObjectContext
{
    NSManagedObjectContext *context = nil;
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil)
    {
        context = [[NSManagedObjectContext alloc] init];
        [context setPersistentStoreCoordinator:coordinator];
        
        return context;
    }
    
    return nil;
}

- (void)setManagedObjectModel:(NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil)
        _managedObjectModel = nil;
    _managedObjectModel = managedObjectModel;
}

- (NSManagedObjectModel *)managedObjectModel
{    
    if (_managedObjectModel != nil)
        return _managedObjectModel;

    _managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];
    return _managedObjectModel;
}

- (void)setPersistentStoreCoordinator:(NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil)
        _persistentStoreCoordinator = nil;

    _persistentStoreCoordinator = persistentStoreCoordinator;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil)
        return _persistentStoreCoordinator;
    
    NSURL *storeURL = nil;
    if ([NSSQLiteStoreType isEqualToString:self.persistentStoreType])
    {
        NSString *storePath = [self.databasePath stringByAppendingPathComponent:self.databaseFilename];

        NSFileManager *fileManager = [NSFileManager defaultManager];

        if ([fileManager fileExistsAtPath: [storePath stringByDeletingLastPathComponent]] == NO)
        {
            // Go and create the last path component.
            NSError *error;
            [fileManager createDirectoryAtPath:[storePath stringByDeletingLastPathComponent]
                   withIntermediateDirectories: YES
                                    attributes: nil
                                         error: &error];
            if (error)
            {
                NSLog(@"Could not create missing path for %@. Error: %@", storePath, error);
            }
        }

        storeURL = [NSURL fileURLWithPath:storePath];

        if (self.initialDatabaseFilename)
        {
            if (![fileManager fileExistsAtPath:storePath])
            {
                NSString *initialStorePath = [[NSBundle mainBundle] pathForResource:self.initialDatabaseFilename ofType:nil];
                if (initialStorePath)
                    [fileManager copyItemAtPath:initialStorePath toPath:storePath error:NULL];
            }
        }
    }
    
    NSError *error = nil;

    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:self.persistentStoreType configuration:nil URL:storeURL options:nil error:&error])
    {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}

- (NSString *)persistentStoreType
{
    if (!_persistentStoreType)
        self.persistentStoreType = NSSQLiteStoreType;
    
    return _persistentStoreType;
}

- (void)setPersistentStoreType:(NSString *)persistentStoreType
{
    _persistentStoreType = persistentStoreType;
}

- (void)mergeChanges:(NSNotification *)notification
{
    if (![NSThread currentThread].isMainThread)
    {
        [self performBlockOnMainThread:^{
            [self mergeChanges:notification];
        }];
        return;
    }
    
    [self.currentContext mergeChangesFromContextDidSaveNotification:notification];
}

- (BOOL)saveManagedObjectContext:(NSManagedObjectContext *)managedObjectContext error:(NSError **)error
{
    if (managedObjectContext != nil && [managedObjectContext hasChanges])
    {
        // Register context with the notification center
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        [nc addObserver:self
               selector:@selector(mergeChanges:)
                   name:NSManagedObjectContextDidSaveNotification
                 object:managedObjectContext];
        
        return [managedObjectContext save:error];
    }
    
    return YES;
}

- (NSArray *)objectsWithExistingIDs:(NSArray *)ids 
{
    if (!ids)
        return nil;
    
    NSMutableArray *objects = [NSMutableArray array];
    for (id obj in ids)
    {
        NSManagedObjectID *oID = nil;
        if ([obj isKindOfClass:[NSManagedObjectID class]])
            oID = (NSManagedObjectID *)obj;
        else
        if ([obj isKindOfClass:[NSManagedObject class]])
            oID = [(NSManagedObject *)obj objectID];
        else
            return nil;

        [objects addObject:[self.currentContext existingObjectWithID:oID error:NULL]];
    }
    
    return objects;
}

- (id)objectWithExistingID:(id)objectID
{
    if (!objectID)
        return nil;

    NSArray *objects = [self objectsWithExistingIDs:[NSArray arrayWithObject:objectID]];
    
    if ([objects count] != 0)
        return [objects objectAtIndex:0];

    return nil;
}

- (NSUInteger)countObjectsForEntity:(NSString *)entity filteredBy:(NSPredicate *)predicateOrNil
{
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *entityDescription = [NSEntityDescription entityForName:entity inManagedObjectContext:self.currentContext];
	[fetchRequest setEntity:entityDescription];
	
    if (predicateOrNil)
        [fetchRequest setPredicate:predicateOrNil];
    
	NSError *error = nil;
	NSUInteger result = [self.currentContext countForFetchRequest:fetchRequest error:&error];
    
	if (error)
    {
		// Manage error executing fetch
	}
	
	return result;
}

- (NSArray *)allObjectsForEntity:(NSString *)entity orderedByAttribute:(NSString *)attributeOrNil ascending:(BOOL)ascending filteredBy:(NSPredicate *)predicateOrNil
{
    return [self objectsForEntity:entity orderedByAttribute:attributeOrNil ascending:ascending filteredBy:predicateOrNil fetchLimit:0 offset:0];
}

- (NSArray *)objectsForEntity:(NSString *)entity orderedByAttribute:(NSString *)attributeOrNil ascending:(BOOL)ascending filteredBy:(NSPredicate *)predicateOrNil fetchLimit:(int)fetchLimit offset:(int)offset
{
    NSArray *sortDescriptors = nil;
    if (attributeOrNil)
    {
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:attributeOrNil ascending:ascending];
        sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    }
    
    NSArray *r = [self objectsForEntity:entity sortDescriptors:sortDescriptors filteredBy:predicateOrNil fetchLimit:fetchLimit offset:offset];
    return r;
}

- (NSArray *)allObjectsForEntity:(NSString *)entity sortDescriptors:(NSArray *)sortDescriptors filteredBy:(NSPredicate *)predicateOrNil
{
    return [self objectsForEntity:entity sortDescriptors:sortDescriptors filteredBy:predicateOrNil fetchLimit:0 offset:0];
}

- (NSArray *)objectsForEntity:(NSString *)entity sortDescriptors:(NSArray *)sortDescriptors filteredBy:(NSPredicate *)predicateOrNil fetchLimit:(int)fetchLimit offset:(int)offset
{
	// Create the fetch request for the entity.
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	// Edit the entity name as appropriate.
	NSEntityDescription *entityDescription = [NSEntityDescription entityForName:entity inManagedObjectContext:self.currentContext];
	[fetchRequest setEntity:entityDescription];
	
    // Set the batch size to a suitable number.
    [fetchRequest setFetchLimit:fetchLimit];
    [fetchRequest setFetchOffset:offset];
	
    if (sortDescriptors)
        [fetchRequest setSortDescriptors:sortDescriptors];
	
    if (predicateOrNil)
        [fetchRequest setPredicate:predicateOrNil];
    
	NSError *error = nil;
	NSArray *result = [self.currentContext executeFetchRequest:fetchRequest error:&error];
    
	if (error)
    {
		// Manage error executing fetch
	}
    
	return result;
}

- (id)findObjectFromEntity:(NSString *)entity withPredicate:(NSPredicate *)predicate
{
	NSArray *tmp = [self objectsForEntity:entity orderedByAttribute:nil ascending:YES filteredBy:predicate fetchLimit:1 offset:0];
	
	if (tmp.count != 0)
		return [tmp objectAtIndex:0];

	return nil;
}

- (id)getNewObjectForEntity:(NSString *)entityName
{    
    id obj = [NSEntityDescription insertNewObjectForEntityForName:entityName inManagedObjectContext:self.currentContext];
	
	NSError *error = nil;
    if (![self saveManagedObjectContext:self.currentContext error:&error])
    {
        
		//This is a serious error saying the record
		//could not be saved. Advise the user to
		//try again or restart the application.
        
    }
    
    return obj;
}

- (void)deleteObject:(id)object
{
	[self.currentContext deleteObject:object];
    
	NSError *error = nil;
    if (![self saveManagedObjectContext:self.currentContext error:&error])
    {
		
		//This is a serious error saying the record
		//could not be saved. Advise the user to
		//try again or restart the application.
		
	}
}

- (void)deleteAllObjectsFromEntity:(NSString *)entity
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entityDesc = [NSEntityDescription entityForName:entity inManagedObjectContext:self.currentContext];
    [fetchRequest setEntity:entityDesc];
	
    NSError *error = nil;
    NSArray *items = [self.currentContext executeFetchRequest:fetchRequest error:&error];
	
	
    for (NSManagedObject *managedObject in items)
    {
        [self.currentContext deleteObject:managedObject];
        NSLog(@"%@ object deleted",entity);
    }
    
    if (![self saveManagedObjectContext:self.currentContext error:&error])
    {
        NSLog(@"Error deleting %@ - error:%@",entity,error);
    }
}

- (void)saveAllChanges
{
    [self.currentContext save:NULL];
}

@end
