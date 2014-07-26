//
//  FSArgumentParser.h
//  FSArgumentParser
//
//  Created by Christopher Miller on 2/23/12.
//  Copyright (c) 2012 Christopher Miller. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FSArgumentPackage;

@interface FSArgumentParser : NSObject

- (id)initWithArguments:(NSArray *)arguments signatures:(id)signatures;
- (FSArgumentPackage *)parse;

@end
