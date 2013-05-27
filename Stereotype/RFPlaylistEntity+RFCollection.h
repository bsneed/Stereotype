//
//  RFPlaylistEntity+RFCollection.h
//  Stereotype
//
//  Created by Brandon Sneed on 5/27/13.
//  Copyright (c) 2013 redf.net. All rights reserved.
//

#import "RFPlaylistEntity.h"

@interface RFPlaylistEntity (RFCollection)

- (id)imageRepresentation;
- (NSString *)imageRepresentationType;
- (NSString *)imageSubtitle;
- (NSString *)imageTitle;
- (NSString *)imageUID;
- (NSString *)imageVersion;
- (BOOL)isSelectable;

@end
