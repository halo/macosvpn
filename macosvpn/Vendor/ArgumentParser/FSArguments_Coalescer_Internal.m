//
//  FSArguments_Coalescer_Internal.m
//  ArgumentParser
//
//  Created by Christopher Miller on 5/11/12.
//  Copyright (c) 2012 Christopher Miller. All rights reserved.
//

#import "FSArguments_Coalescer_Internal.h"

NSCharacterSet * __fsargs_coalesceToCharacterSet_nsstring(NSString *);
NSCharacterSet * __fsargs_coalesceToCharacterSet_nsarray(NSArray *);
NSCharacterSet * __fsargs_coalesceToCharacterSet_nsset(NSSet *);
NSCharacterSet * __fsargs_coalesceToCharacterSet_nsorderedset(NSOrderedSet *);
NSCharacterSet * __fsargs_coalesceToCharacterSet_nsobject(NSObject *);

NSCharacterSet * __fsargs_coalesceToCharacterSet(id o) {
    if (o==nil) return nil;
    else if ([o isKindOfClass:[NSString class]]) return __fsargs_coalesceToCharacterSet_nsstring(o);
    else if ([o isKindOfClass:[NSArray class]]) return __fsargs_coalesceToCharacterSet_nsarray(o);
    else if ([o isKindOfClass:[NSSet class]]) return __fsargs_coalesceToCharacterSet_nsset(o);
    else if ([o isKindOfClass:[NSOrderedSet class]]) return __fsargs_coalesceToCharacterSet_nsorderedset(o);
    else return __fsargs_coalesceToCharacterSet_nsobject(o);
}

NSCharacterSet * __fsargs_coalesceToCharacterSet_nsstring(NSString * s) {
    return [NSCharacterSet characterSetWithCharactersInString:s];
}

NSCharacterSet * __fsargs_coalesceToCharacterSet_nsarray(NSArray * a) {
    NSMutableCharacterSet * s = [[NSMutableCharacterSet alloc] init];
    [a enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [s formUnionWithCharacterSet:__fsargs_coalesceToCharacterSet(obj)];
    }];
    return s;
}

NSCharacterSet * __fsargs_coalesceToCharacterSet_nsset(NSSet * s) {
    NSMutableCharacterSet * cs = [[NSMutableCharacterSet alloc] init];
    [s enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
        [cs formUnionWithCharacterSet:__fsargs_coalesceToCharacterSet(obj)];
    }];
    return cs;
}

NSCharacterSet * __fsargs_coalesceToCharacterSet_nsorderedset(NSOrderedSet * s) {
    NSMutableCharacterSet * cs = [[NSMutableCharacterSet alloc] init];
    [s enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [cs formUnionWithCharacterSet:__fsargs_coalesceToCharacterSet(obj)];
    }];
    return cs;
}

NSCharacterSet * __fsargs_coalesceToCharacterSet_nsobject(NSObject * o) {
    return __fsargs_coalesceToCharacterSet_nsstring([o description]);
}

NSArray * __fsargs_coalesceToArray(id o) {
    if (!o) return nil;
    else if ([o isKindOfClass:[NSArray class]]) return o;
    else if ([o isKindOfClass:[NSString class]]) return [NSArray arrayWithObject:o];
    else if ([o isKindOfClass:[NSSet class]]||[o isKindOfClass:[NSOrderedSet class]]) return [o allObjects];
    else return [NSArray arrayWithObject:[o description]];
}

NSSet * __fsargs_coalesceToSet(id o) {
    if (!o) return nil;
    else if ([o isKindOfClass:[NSArray class]]) return [NSSet setWithArray:o];
    else if ([o isKindOfClass:[NSString class]]) return [NSSet setWithObject:o];
    else if ([o isKindOfClass:[NSSet class]]) return o;
    else if ([o isKindOfClass:[NSOrderedSet class]]) return [(NSOrderedSet *)o set];
    else return [NSSet setWithObject:o];
}

NSArray * __fsargs_charactersFromCharacterSetAsArray(NSCharacterSet * characterSet) {
    NSMutableArray * a = [NSMutableArray array];
    for (unichar c = 0;
         c < 256;
         ++c)
        if ([characterSet characterIsMember:c]) [a addObject:[NSString stringWithFormat:@"%c", c]];
    return [a copy];
}

NSString * __fsargs_charactersFromCharacterSetAsString(NSCharacterSet * characterSet) {
    NSMutableString * s = [NSMutableString stringWithCapacity:10];
    for (unichar c = 0;
         c < 256;
         ++c)
        if ([characterSet characterIsMember:c]) [s appendFormat:@"%c", c];
    return [s copy];
}

NSString * __fsargs_expandSwitch(NSString * s)
{
    if ([s length] == 1)
        return [NSString stringWithFormat:@"-%@", s];
    else
        return [NSString stringWithFormat:@"--%@", s];
}

NSArray * __fsargs_expandAllSwitches(id switches)
{
    NSMutableArray * a = [NSMutableArray arrayWithCapacity:[switches count]];
    for (NSString * s in switches) {
        [a addObject:__fsargs_expandSwitch(s)];
    }
    return [a copy];
}
