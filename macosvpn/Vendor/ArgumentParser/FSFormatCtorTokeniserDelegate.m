//
//  FSFormatCtorTokeniserDelegate.m
//  ArgumentParser
//
//  Created by Christopher Miller on 5/18/12.
//  Copyright (c) 2012 Christopher Miller. All rights reserved.
//

#import "FSFormatCtorTokeniserDelegate.h"

@implementation FSFormatCtorTokeniserDelegate

- (BOOL)tokeniser:(CPTokeniser *)tokeniser shouldConsumeToken:(CPToken *)token
{
    return YES;
}

- (NSArray *)tokeniser:(CPTokeniser *)tokeniser willProduceToken:(CPToken *)token
{
    // drop whitespace
    if ([token isKindOfClass:[CPWhiteSpaceToken class]])
        return [NSArray array];
    else
        return [NSArray arrayWithObject:token];
}

- (NSUInteger)tokeniser:(CPTokeniser *)tokeniser didNotFindTokenOnInput:(NSString *)input position:(NSUInteger)position error:(NSString **)errorMessage
{
    // perhaps some cool error handling here?
    
    return NSNotFound;
}

@end
