//
//  FSFormatCtorParserDelegate.m
//  ArgumentParser
//
//  Created by Christopher Miller on 5/18/12.
//  Copyright (c) 2012 Christopher Miller. All rights reserved.
//

#import "FSFormatCtorParserDelegate.h"

#import "FSSwitchToken.h"
#import "FSAliasToken.h"

@implementation FSFormatCtorParserDelegate

- (id)parser:(CPParser *)parser didProduceSyntaxTree:(CPSyntaxTree *)syntaxTree
{
    if ([[syntaxTree children] count] == 1) {
        if ([[[syntaxTree children] objectAtIndex:0] isKindOfClass:[FSSwitchToken class]] || [[[syntaxTree children] objectAtIndex:0] isKindOfClass:[FSAliasToken class]]) {
            return [[syntaxTree children] objectAtIndex:0];
        }
    } else if ([[syntaxTree children] count] > 1) {
        if ([[[syntaxTree children] objectAtIndex:0] isKindOfClass:[CPKeywordToken class]]) {
            CPKeywordToken * t = [[syntaxTree children] objectAtIndex:0];
            if ([[t keyword] isEqual:@"="]) {
                // it's a keyword token!
                NSArray * subtree = [[syntaxTree children] objectAtIndex:1];
                if ([subtree count]==0)
                    return [syntaxTree children]; // just the =
                subtree = [[subtree objectAtIndex:0] children];
                NSMutableArray * a = [NSMutableArray arrayWithCapacity:[subtree count]+1];
                [a addObject:t];
                for (id obj in subtree)
                    if ([obj isKindOfClass:[NSArray class]]) [a addObjectsFromArray:obj];
                    else [a addObject:obj];
                // should now look something like { Number , Number } or { Number , }
                return [a copy];
            }
        }
    }
    
    return syntaxTree;
}

@end
