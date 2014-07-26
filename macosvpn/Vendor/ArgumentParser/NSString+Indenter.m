//
//  NSString+Indenter.m
//  ArgumentParser
//
//  Created by Christopher Miller on 5/11/12.
//  Copyright (c) 2012 Christopher Miller. All rights reserved.
//

#import "NSString+Indenter.h"

@implementation NSString (Indenter)

- (NSMutableString *)fsargs_mutableStringByIndentingToWidth:(NSUInteger)indent lineLength:(NSUInteger)width
{
    if (width < 20) width = 20; // just make sure
    NSParameterAssert(indent < width); // probably a good idea
    
    NSMutableString * prefix = [NSMutableString stringWithCapacity:indent];
    for (NSUInteger i = 0;
         i < indent;
         ++i) [prefix appendString:@" "];
    
    NSMutableString * s = [NSMutableString string];
    NSUInteger chunkAtLength = width - indent;
    [self enumerateLinesUsingBlock:^(NSString *line, BOOL *stop) {
        // chunkify at chunkAtLength and then append using @"\n" as the componentsJoinedByString
        // someone please shoot the Engrish in the above line
        NSMutableArray * a = [NSMutableArray arrayWithCapacity:[line length]/chunkAtLength +1];
        for (NSUInteger i = 0;
             i < [line length];
             i += chunkAtLength) {
            NSUInteger length = chunkAtLength;
            if (i + length > [line length])
                length = [line length] - i;
            [a addObject:[NSString stringWithFormat:@"%@%@", prefix, [line substringWithRange:NSMakeRange(i, length)]]];
        }
        [s appendString:[a componentsJoinedByString:@"\n"]];
        [s appendString:@"\n"];
    }];
    
    return s;
}

@end
