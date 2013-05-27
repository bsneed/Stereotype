//
//  RFTrackEntity+RFCollection.h
//  Stereotype
//
//  Created by Brandon Sneed on 5/25/13.
//  Copyright (c) 2013 redf.net. All rights reserved.
//

#import "RFTrackEntity.h"

@interface RFTrackEntity (RFCollection)

- (id)imageRepresentation;
- (NSString *)imageRepresentationType;
- (NSString *)imageSubtitle;
- (NSString *)imageTitle;
- (NSString *)imageUID;
- (NSString *)imageVersion;
- (BOOL)isSelectable;

@end
