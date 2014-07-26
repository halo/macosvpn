//
//  NSArray+FSArgumentsNormalizer.m
//  ArgumentParser
//
//  Created by Christopher Miller on 5/15/12.
//  Copyright (c) 2012 Christopher Miller. All rights reserved.
//

#import "NSArray+FSArgumentsNormalizer.h"
#import "FSMutableAttributedArray.h"
#import "FSArgsKonstants.h"

@implementation NSArray (FSArgumentsNormalizer)
- (FSMutableAttributedArray *)fsargs_normalize
{
    FSMutableAttributedArray * args = [FSMutableAttributedArray attributedArrayWithCapacity:[self count]];
    [self enumerateObjectsUsingBlock:^(NSString * arg, NSUInteger idx, BOOL *stop) {
        if (![arg isKindOfClass:[NSString class]]) return; // just... what?
        
        // handle equals-sign assignments
        // possibly check for \= so that we can escape from = assignments. probably overkill though
        NSRange r = [arg rangeOfString:@"="];
        NSString * value = nil;
        if (r.location != NSNotFound) {
            value = [arg substringFromIndex:r.location+r.length];
            arg = [arg substringToIndex:r.location];
        }
        
        // long form switch
        if ([arg hasPrefix:@"--"]) {
            if ([arg length] == 2)
                [args addObject:[NSNull null] withAttributes:[NSDictionary dictionaryWithObject:__fsargs_barrier forKey:__fsargs_typeKey]];
            else
                [args addObject:arg withAttributes:[NSDictionary dictionaryWithObject:__fsargs_switch forKey:__fsargs_typeKey]];
        } else if ([arg hasPrefix:@"-"]) { // condensed switches
            for (NSUInteger i = 1;
                 i < [arg length];
                 ++i) {
                unichar c = [arg characterAtIndex:i];
                [args addObject:[NSString stringWithFormat:@"-%c", c] withAttributes:[NSDictionary dictionaryWithObject:__fsargs_switch forKey:__fsargs_typeKey]];
            }
        } else {
            [args addObject:arg withAttributes:[NSDictionary dictionaryWithObject:__fsargs_unknown forKey:__fsargs_typeKey]];
        }
        
        if (value) // if we had a value from and equals sign, then it's obviously an explicitly assigned value.
            [args addObject:value withAttributes:[NSDictionary dictionaryWithObject:__fsargs_value forKey:__fsargs_typeKey]];
    }];
    return args;
}
@end
