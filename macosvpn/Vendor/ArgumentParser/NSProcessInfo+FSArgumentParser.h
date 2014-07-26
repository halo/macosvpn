//
//  NSProcessInfo+FSArgumentParser.h
//  ArgumentParser
//
//  Created by Christopher Miller on 5/15/12.
//  Copyright (c) 2012 Christopher Miller. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FSArgumentPackage;

@interface NSProcessInfo (FSArgumentParser)

- (FSArgumentPackage *)fsargs_parseArgumentsWithSignatures:(id)signatures;

@end
