//
//  NSURL+RFExtensions.h
//  Stereotype
//
//  Created by brandon on 11/8/12.
//  Copyright (c) 2012 redf.net. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSURL (RFExtensions)

- (NSURL*)URLByResolvingSymlinksAndAliases;

@end
