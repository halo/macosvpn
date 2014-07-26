//
//  NSProcessInfo+FSArgumentParser.m
//  ArgumentParser
//
//  Created by Christopher Miller on 5/15/12.
//  Copyright (c) 2012 Christopher Miller. All rights reserved.
//

#import "NSProcessInfo+FSArgumentParser.h"

#import "FSArgumentParser.h"

@implementation NSProcessInfo (FSArgumentParser)

- (FSArgumentPackage *)fsargs_parseArgumentsWithSignatures:(id)signatures
{
    FSArgumentParser * p = [[FSArgumentParser alloc] initWithArguments:[self arguments] signatures:signatures];
    id retVal = [p parse];
    p = nil;
    return retVal;
}

@end
