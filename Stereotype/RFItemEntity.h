//
//  RFItemEntity.h
//  Stereotype
//
//  Created by brandon on 12/6/12.
//  Copyright (c) 2012 redf.net. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class RFTrackEntity;

@interface RFItemEntity : NSManagedObject

@property (nonatomic, retain) NSNumber * index;
@property (nonatomic, retain) RFTrackEntity *track;

@end
