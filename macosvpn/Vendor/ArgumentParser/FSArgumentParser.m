//
//  FSArgumentParser.m
//  FSArgumentParser
//
//  Created by Christopher Miller on 2/23/12.
//  Copyright (c) 2012 Christopher Miller. All rights reserved.
//

#import "FSArgumentParser.h"
#import "FSMutableAttributedArray.h"
#import "NSArray+FSArgumentsNormalizer.h"
#import "FSArguments_Coalescer_Internal.h"
#import "FSArgsKonstants.h"

#import "FSArgumentPackage.h"
#import "FSArgumentPackage_Private.h"

#import "FSArgumentSignature.h"
#import "FSCountedArgument.h"
#import "FSValuedArgument.h"

@interface FSArgumentParser () {
    FSMutableAttributedArray * _arguments;
    NSMutableSet * _signatures;
    NSMutableDictionary * _switches;
    NSMutableDictionary * _aliases;
    FSArgumentPackage * _package;
}
- (void)injectSignatures:(NSSet *)signatures;
- (void)performSignature:(FSArgumentSignature *)signature fromIndex:(NSUInteger)index;
- (NSRange)rangeOfValuesStartingFromIndex:(NSUInteger)index tryFor:(NSRange)wantedArguments;
@end

@implementation FSArgumentParser

- (id)initWithArguments:(NSArray *)arguments signatures:(id)signatures
{
    self = [super init];
    
    if (self) {
        _arguments = [arguments fsargs_normalize];
        _signatures = [__fsargs_coalesceToSet(signatures) mutableCopy];
        _switches = [[NSMutableDictionary alloc] init];
        _aliases = [[NSMutableDictionary alloc] init];
        _package = [[FSArgumentPackage alloc] init];
        [self injectSignatures:_signatures];
    }
    
    return self;
}

- (FSArgumentPackage *)parse
{
    for (NSUInteger i = 0;
         i < [_arguments count];
         ++i) {
        NSString * v = [_arguments objectAtIndex:i];
        FSArgumentSignature * signature;
        NSString * type = [_arguments valueOfAttribute:__fsargs_typeKey forObjectAtIndex:i];
        if ([type isEqual:__fsargs_switch]) {
            // switch
            NSString *switchKey = [v stringByReplacingOccurrencesOfString:@"-" withString:@""];
            if ((signature = [_switches objectForKey:switchKey]) != nil) {
                // perform the argument
                [self performSignature:signature fromIndex:i];
            } else {
                // it's an unknown switch, drop it into a bucket of unknown switches or something.
                [_package->_unknownSwitches addObject:v];
            }
        } else if ([type isEqual:__fsargs_value]) {
            // uncaptured valued
            if ([_arguments booleanValueOfAttribute:__fsargs_isValueCaptured forObjectAtIndex:i]) {
                continue; // just skip this one
            } else {
                // it's an uncaptured value, which is really quite rare. The only way to pre-mark a value to with an equals-sign, which means that an equals sign assignment was used on a signature which doesn't capture values.
                // find a way to associate this with what it wanted to be associated with in a weak way.
                [_package->_uncapturedValues addObject:v];
            }
        } else if ([type isEqual:__fsargs_unknown]) {
            if ([_arguments booleanValueOfAttribute:__fsargs_isValueCaptured forObjectAtIndex:i]) {
                continue; // just skip this one
            } else {
                // potentially uncaptured value, or else it could be an alias
                if ((signature = [_aliases objectForKey:v]) != nil) {
                    // perform the argument
                    [self performSignature:signature fromIndex:i];
                } else {
                    // it's an uncaptured value, not strongly associated with anything else
                    // it could be weakly associated with something, however
                    [_package->_uncapturedValues addObject:v];
                }
            }
        } else if ([type isEqualToString:__fsargs_barrier]) {
            // skip the barrier
        } else {
            // unknown type
            NSLog(@"Unknown type: %@", type);
        }
    }
    
    return _package;
}

/**
 * Inject a whole mess of signatures into the parser state.
 */
- (void)injectSignatures:(NSSet *)signatures
{
    [signatures enumerateObjectsUsingBlock:^(FSArgumentSignature * signature, BOOL *stop) {
        [signature.switches enumerateObjectsUsingBlock:^(id _switch, BOOL *stop) {
            [_switches setObject:signature forKey:_switch];
        }];
        [signature.aliases enumerateObjectsUsingBlock:^(id alias, BOOL *stop) {
            [_aliases setObject:signature forKey:alias];
        }];
    }];
}

/**
 * Handle the signature.
 */
- (void)performSignature:(FSArgumentSignature *)signature fromIndex:(NSUInteger)index
{
    // 1. is it valued?
    if ([signature isKindOfClass:[FSValuedArgument class]]) {
        FSValuedArgument * valuedSignature = (FSValuedArgument *)signature;
        
        // pop forward to find possible arguments
        
        NSRange rangeOfValues = [self rangeOfValuesStartingFromIndex:index+1 tryFor:valuedSignature.valuesPerInvocation];
        NSIndexSet * indexSetOfValues = [NSIndexSet indexSetWithIndexesInRange:rangeOfValues];
        [indexSetOfValues enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
            // grab that value
            NSString * value = [_arguments objectAtIndex:idx];
            [_arguments setBooleanValue:true ofAttribute:__fsargs_isValueCaptured forObjectAtIndex:idx];
            [_package addObject:value toSignature:valuedSignature];
        }];
        
    } else {
        [_package incrementCountOfSignature:signature];
    }
    // 2. inject subsignatures
    [self injectSignatures:signature.injectedSignatures];
}

- (NSRange)rangeOfValuesStartingFromIndex:(NSUInteger)index tryFor:(NSRange)wantedArguments
{
    bool (^isValue)(NSMutableDictionary *) = ^(NSMutableDictionary * attributes) {
        NSString * vType = [attributes objectForKey:__fsargs_typeKey];
        return (bool)([vType isEqual:__fsargs_value] || [vType isEqual:__fsargs_unknown]);
    };
    bool (^isBarrier)(NSMutableDictionary *)= ^(NSMutableDictionary * attributes) {
        return (bool)([[attributes objectForKey:__fsargs_typeKey] isEqual:__fsargs_barrier]);
    };
    bool (^isCaptured)(NSMutableDictionary *)= ^(NSMutableDictionary * attributes){
        return (bool)([[attributes objectForKey:__fsargs_isValueCaptured] boolValue] == YES);
    };
    
    NSRange retVal={0,0};
    retVal.location = [_arguments indexOfObjectAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(index, [_arguments count] - index)] options:0 passingTest:^bool(id obj, NSMutableDictionary *attributes, NSUInteger idx, BOOL *stop) {
        if (isBarrier(attributes) && !isCaptured(attributes)) {
            [attributes setObject:[NSNumber numberWithBool:YES] forKey:__fsargs_isValueCaptured]; // capture this barrier
            *stop = YES;
            return NO;
        } else if (isValue(attributes) && !isCaptured(attributes))
            return YES;
        
        return NO;
    }];
    
    if (retVal.location == NSNotFound) return retVal;
    
    retVal.length = [_arguments indexOfObjectAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(retVal.location, MIN(wantedArguments.length, [_arguments count] - retVal.location))] options:0 passingTest:^bool(id obj, NSMutableDictionary *attributes, NSUInteger idx, BOOL *stop) {
        if (isValue(attributes) && !isCaptured(attributes)) return false;
        return true;
    }] - retVal.location;
    
    if (retVal.length == 0) retVal.length ++ ;
    if (retVal.length == NSNotFound - retVal.location) retVal.length = 1;
            
    return retVal;
}

@end
