//
//  FSSwitchRecognizer.m
//  ArgumentParser
//
//  Created by Christopher Miller on 5/17/12.
//  Copyright (c) 2012 Christopher Miller. All rights reserved.
//

#import "FSSwitchRecognizer.h"
#import "FSSwitchToken.h"

#import "NSScanner+EscapedScanning.h"

#import "CoreParse.h"

@implementation FSSwitchRecognizer

+ (id)switchRecognizer
{
    return [[self alloc] init];
}

#pragma mark CPTokenRecogniser

- (CPToken *)recogniseTokenInString:(NSString *)tokenString currentTokenPosition:(NSUInteger *)tokenPosition
{
    static NSCharacterSet * cs;
    static dispatch_once_t onceToken0;
    dispatch_once(&onceToken0, ^{
        NSMutableCharacterSet * mcs = [NSMutableCharacterSet characterSetWithCharactersInString:@"]"];
        [mcs formUnionWithCharacterSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        cs = [mcs copy];
    });
    
    if ([tokenString characterAtIndex:*tokenPosition] != '-') {
        return nil;
    } else {
        // consume characters up to the next whitespace
        NSScanner * scanner = [NSScanner scannerWithString:tokenString];
        [scanner setScanLocation:*tokenPosition];

        NSString * rawPart;
        
        [scanner fsargs_scanUpToCharacterFromSet:cs unlessPrecededByCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@"\\"] intoString:&rawPart];
        
        if (![rawPart hasPrefix:@"--"] && [rawPart length] > 2)
            return nil; // it can't be so, that's just an error
        
        *tokenPosition = [scanner scanLocation];
        
        return [FSSwitchToken switchTokenWithIdentifier:rawPart];
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
