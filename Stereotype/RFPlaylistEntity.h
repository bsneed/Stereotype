//
//  RFPlaylistEntity.h
//  Stereotype
//
//  Created by brandon on 12/6/12.
//  Copyright (c) 2012 redf.net. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class RFItemEntity;

@interface RFPlaylistEntity : NSManagedObject

@property (nonatomic, retain) NSString * itunesPlaylistID;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * masterLibrary;
@property (nonatomic, retain) NSString * smartPlaylistQuery;
@property (nonatomic, retain) NSSet *items;
@end

@interface RFPlaylistEntity (CoreDataGeneratedAccessors)

- (void)addItemsObject:(RFItemEntity *)value;
- (void)removeItemsObject:(RFItemEntity *)value;
- (void)addItems:(NSSet *)values;
- (void)removeItems:(NSSet *)values;

@end
