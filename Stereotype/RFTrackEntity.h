//
//  RFTrackEntity.h
//  Stereotype
//
//  Created by brandon on 12/25/12.
//  Copyright (c) 2012 redf.net. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface RFTrackEntity : NSManagedObject

@property (nonatomic, retain) NSString * albumTitle;
@property (nonatomic, retain) NSString * artist;
@property (nonatomic, retain) NSNumber * bitRate;
@property (nonatomic, retain) NSNumber * bitsPerChannel;
@property (nonatomic, retain) NSNumber * bpm;
@property (nonatomic, retain) NSNumber * compilation;
@property (nonatomic, retain) NSString * composer;
@property (nonatomic, retain) NSNumber * discNumber;
@property (nonatomic, retain) NSNumber * discTotal;
@property (nonatomic, retain) NSNumber * duration;
@property (nonatomic, retain) NSString * format;
@property (nonatomic, retain) NSString * genre;
@property (nonatomic, retain) NSString * itunesID;
@property (nonatomic, retain) NSNumber * rating;
@property (nonatomic, retain) NSString * releaseDate;
@property (nonatomic, retain) NSNumber * sampleRate;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSNumber * trackNumber;
@property (nonatomic, retain) NSNumber * trackTotal;
@property (nonatomic, retain) NSString * url;
@property (nonatomic, retain) NSString * albumArtist;

@end
