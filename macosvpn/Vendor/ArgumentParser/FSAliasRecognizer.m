//
//  FSValueRecognizer.m
//  ArgumentParser
//
//  Created by Christopher Miller on 5/17/12.
//  Copyright (c) 2012 Christopher Miller. All rights reserved.
//

#import "FSAliasRecognizer.h"
#import "FSAliasToken.h"

#import "NSScanner+EscapedScanning.h"

#import "CoreParse.h"

@implementation FSAliasRecognizer

+ (id)aliasRecognizer
{
    return [[self alloc] init];
}

#pragma mark CPTokenRecogniser

- (CPToken *)recogniseTokenInString:(NSString *)tokenString currentTokenPosition:(NSUInteger *)tokenPosition
{
    static NSCharacterSet * illegalAliasStartCharacters;
    static dispatch_once_t onceToken0;
    dispatch_once(&onceToken0, ^{
        illegalAliasStartCharacters =
        [NSCharacterSet characterSetWithCharactersInString:@"-= "];
    });
    static NSCharacterSet * stopCharacters;
    static dispatch_once_t onceToken1;
    dispatch_once(&onceToken1, ^{
        NSMutableCharacterSet * mcs = [NSMutableCharacterSet characterSetWithCharactersInString:@"]"];
        [mcs formUnionWithCharacterSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        stopCharacters = [mcs copy];
    });
    if (![illegalAliasStartCharacters characterIsMember:[tokenString characterAtIndex:*tokenPosition]]) {
        NSScanner * scanner = [NSScanner scannerWithString:tokenString];
        [scanner setScanLocation:*tokenPosition];
        NSString * alias;
        [scanner fsargs_scanUpToCharacterFromSet:stopCharacters unlessPrecededByCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@"\\"] intoString:&alias];
        *tokenPosition = [scanner scanLocation];
        
        return [FSAliasToken aliasTokenWithIdentifier:alias];
    }
    
    return nil;
}

#pragma mark NSCoding

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [self init];
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    // really easy when you have no ivars
}

@end
