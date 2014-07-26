//
//  FSArgumentPackage.m
//  FSArgumentParser
//
//  Created by Christopher Miller on 2/23/12.
//  Copyright (c) 2012 Christopher Miller. All rights reserved.
//

#import "FSArgumentPackage.h"
#import "FSArgumentPackage_Private.h"

#import "FSArgumentSignature.h"
#import "FSArgumentSignature_Private.h"
#import "FSCountedArgument.h"
#import "FSValuedArgument.h"

NSString * __fsargs_expect_valuedSig = @"Please don't ask for values from an unvalued argument signature.";
NSString * __fsargs_expect_countedSig = @"Please don't ask for counts from a valued argument signature.";

/*
    CFMutableDictionaryRef _countedValues;
    NSMutableDictionary * _valuedValues;
    NSMutableArray * _uncapturedValues;
    NSMutableSet * _allSignatures;
*/

@interface FSArgumentPackage ()
- (FSArgumentSignature *)signatureForObject:(id)o;
- (FSArgumentSignature *)signatureForSwitch:(NSString *)s;
- (FSArgumentSignature *)signatureForAlias:(NSString *)alias;
@end

@implementation FSArgumentPackage

- (NSArray *)allObjectsForSignature:(id)signature
{
    signature = [self signatureForObject:signature];
    if (signature) {
        NSAssert([signature isKindOfClass:[FSValuedArgument class]], __fsargs_expect_valuedSig);
        return [_valuedValues objectForKey:signature];
    }
    
    return nil;
}

- (id)firstObjectForSignature:(id)signature
{
    signature = [self signatureForObject:signature];
    if (signature) {
        NSAssert([signature isKindOfClass:[FSValuedArgument class]], __fsargs_expect_valuedSig);
        NSMutableArray * values = [_valuedValues objectForKey:signature];
        if (values) return [values objectAtIndex:0];
        else return nil;
    }
    
    return nil;
}

- (id)lastObjectForSignature:(id)signature
{
    signature = [self signatureForObject:signature];
    if (signature) {
        NSAssert([signature isKindOfClass:[FSValuedArgument class]], __fsargs_expect_valuedSig);
        NSMutableArray * values = [_valuedValues objectForKey:signature];
        if (values) return [values lastObject];
        else return nil;
    }
    
    return nil;
}

- (id)objectAtIndex:(NSUInteger)index forSignature:(id)signature
{
    signature = [self signatureForObject:signature];
    if (signature) {
        NSAssert([signature isKindOfClass:[FSValuedArgument class]], __fsargs_expect_valuedSig);
        NSMutableArray * values = [_valuedValues objectForKey:signature];
        if (values) return [values objectAtIndex:index];
        else return nil;
    }
    
    return nil;
}

- (bool)booleanValueForSignature:(id)signature
{
    signature = [self signatureForObject:signature];
    if (signature) {
        NSAssert([signature isKindOfClass:[FSCountedArgument class]], __fsargs_expect_countedSig);
        if (CFDictionaryContainsKey(_countedValues, (__bridge const void *)signature)) {
            size_t * value = (size_t *)CFDictionaryGetValue(_countedValues, (__bridge const void *)signature);
            return value[0] > 0;
        }
        return false;
    }
    return false;
}

- (NSUInteger)countOfSignature:(id)signature
{
    signature = [self signatureForObject:signature];
    if (signature) {
        if ([signature isKindOfClass:[FSCountedArgument class]]) {
            if (CFDictionaryContainsKey(_countedValues, (__bridge const void *)signature)) {
                size_t * value = (size_t *)CFDictionaryGetValue(_countedValues, (__bridge const void *)signature);
                return value[0];
            }
            return 0;
        } else if ([signature isKindOfClass:[FSValuedArgument class]]) {
            NSMutableArray * values = [_valuedValues objectForKey:signature];
            if (values) return [values count];
            else return 0;
        } else {
            NSAssert(true==false, @"Dude, third eye?");
        }
    }
    
    return NSNotFound;
}

- (NSArray *)unknownSwitches
{
    return _unknownSwitches;
}

- (NSArray *)uncapturedValues
{
    return _uncapturedValues;
}

- (void)incrementCountOfSignature:(FSArgumentSignature *)signature
{
    NSAssert([signature isKindOfClass:[FSCountedArgument class]], __fsargs_expect_countedSig);
    [_allSignatures addObject:signature];
    size_t * value;
    if (CFDictionaryContainsKey(_countedValues, (__bridge const void *)signature)) {
        value = (size_t *)CFDictionaryGetValue(_countedValues, (__bridge const void *)signature);
        value[0]++;
    } else {
        value = malloc(sizeof(size_t) * 1);
        value[0] = 1;
    }
    CFDictionarySetValue(_countedValues, (__bridge const void *)signature, (const void *)value);
}

- (void)addObject:(id)object toSignature:(FSArgumentSignature *)signature
{
    NSAssert([signature isKindOfClass:[FSValuedArgument class]], __fsargs_expect_valuedSig);
    [_allSignatures addObject:signature];
    NSMutableArray * values = [_valuedValues objectForKey:signature];
    if (values) [values addObject:object];
    else [_valuedValues setObject:[NSMutableArray arrayWithObject:object] forKey:signature];
}

- (FSArgumentSignature *)signatureForObject:(id)o
{
    if ([o isKindOfClass:[FSArgumentSignature class]]) return o;
    if ([o isKindOfClass:[NSString class]]) {
        NSString * s = o;
        if ([s hasPrefix:@"-"]) return [self signatureForSwitch:s];
        else return [self signatureForAlias:s];
    }
    return nil;
}

- (FSArgumentSignature *)signatureForSwitch:(NSString *)s
{
    for (FSArgumentSignature * signature in _allSignatures)
        if ([signature respondsToSwitch:s]) return signature;
    return nil;
}

- (FSArgumentSignature *)signatureForAlias:(NSString *)alias
{
    for (FSArgumentSignature * signature in _allSignatures)
        if ([signature respondsToAlias:alias]) return signature;
    return nil;
}

- (NSString *)prettyDescription
{
    NSMutableDictionary * countedDict = [NSMutableDictionary dictionaryWithCapacity:CFDictionaryGetCount(_countedValues)];
    for (FSArgumentSignature * s in _allSignatures) {
        if (CFDictionaryContainsKey(_countedValues, (__bridge const void *)s)) {
            NSUInteger v = [self countOfSignature:s];
            [countedDict setObject:[NSNumber numberWithUnsignedInteger:v] forKey:s];
        }
    }
    
    return [[NSDictionary dictionaryWithObjectsAndKeys:
             countedDict, @"countedValues",
             _valuedValues, @"valuedValues",
             _uncapturedValues, @"uncapturedValues",
             [_allSignatures allObjects], @"allSignatures", // get around stupid Foundation description bs. (only dicts and arrays get pretty print).
             _unknownSwitches, @"unknownSwitches", nil] description];
}

#pragma mark NSObject

- (id)init
{
    self = [super init];
    
    if (self) {
        _countedValues = CFDictionaryCreateMutable(NULL, 0, /*nocopy*/ &kCFTypeDictionaryKeyCallBacks, /*perform no retain/release on values*/ NULL);
        _valuedValues = [[NSMutableDictionary alloc] init];
        _uncapturedValues = [[NSMutableArray alloc] init];
        _allSignatures = [[NSMutableSet alloc] init];
        _unknownSwitches = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (void)dealloc
{
    CFRelease(_countedValues);
}

@end
