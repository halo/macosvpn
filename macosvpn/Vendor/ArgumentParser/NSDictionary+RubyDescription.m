//
//  NSDictionary+RubyDescription.m
//  ArgumentParser
//
//  Created by Christopher Miller on 5/15/12.
//  Copyright (c) 2012 Christopher Miller. All rights reserved.
//

#import "NSDictionary+RubyDescription.h"

@implementation NSDictionary (RubyDescription)
- (NSString *)fs_rubyHashDescription
{
    NSMutableString * s = [NSMutableString stringWithString:@"{ "];
    
    [self enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [s appendFormat:@"%@: \"%@\", ", key, obj];
    }];
    
    if ([self count] > 0) {
        [s deleteCharactersInRange:NSMakeRange([s length] - 2, 2)];
    }
    
    [s appendString:@" }"];
    
    return [s copy];
}
@end
