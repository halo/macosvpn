//
//  FSMutableAttributedArray.m
//  ArgumentParser
//
//  Created by Christopher Miller on 5/15/12.
//  Copyright (c) 2012 Christopher Miller. All rights reserved.
//

#import "FSMutableAttributedArray.h"
#import "NSDictionary+RubyDescription.h"

@interface FSMutableAttributedArray ()
@property (strong) NSMutableArray * bucket;
@end

@interface __FSMutableAttributedArray_Container__ : NSObject {
@public
    id _value;
    NSMutableDictionary * _attributes;
}
@property (strong) id value;
@property (strong) NSMutableDictionary * attributes;
@end

@implementation FSMutableAttributedArray

@synthesize bucket = _bucket;

#pragma mark Creating and Initializing a Mutable Attributed Array

+ (id)attributedArray
{
    return [[self alloc] init];
}

+ (id)attributedArrayWithCapacity:(NSUInteger)capacity
{
    return [[self alloc] initWithCapacity:capacity];
}

- (id)init
{
    self = [super init];
    
    if (self) {
        _bucket = [NSMutableArray array];
    }
    
    return self;
}

- (id)initWithCapacity:(NSUInteger)capacity
{
    self = [super init];
    
    if (self) {
        _bucket = [NSMutableArray arrayWithCapacity:capacity];
    }
    
    return self;
}

#pragma mark Querying an Array

- (NSUInteger)count
{
    return [_bucket count];
}

- (id)objectAtIndex:(NSUInteger)index
{
    __FSMutableAttributedArray_Container__ * c = [_bucket objectAtIndex:index];
    return c->_value;
}

- (NSMutableDictionary *)attributesOfObjectAtIndex:(NSUInteger)index
{
    __FSMutableAttributedArray_Container__ * c = [_bucket objectAtIndex:index];
    return c->_attributes;
}

- (bool)hasAttribute:(id)key forObjectAtIndex:(NSUInteger)index
{
    __FSMutableAttributedArray_Container__ * c = [_bucket objectAtIndex:index];
    return ![c->_attributes objectForKey:key];
}

- (id)valueOfAttribute:(id)key forObjectAtIndex:(NSUInteger)index
{
    __FSMutableAttributedArray_Container__ * c = [_bucket objectAtIndex:index];
    return [c->_attributes objectForKey:key];
}

- (bool)booleanValueOfAttribute:(id)key forObjectAtIndex:(NSUInteger)index
{
    __FSMutableAttributedArray_Container__ * c = [_bucket objectAtIndex:index];
    NSNumber * n = [c->_attributes objectForKey:key];
    if (n) return (bool)[n boolValue];
    else return false;
}

#pragma mark Finding Objects in an Array

- (NSUInteger)indexOfObjectAtIndexes:(NSIndexSet *)indexSet options:(NSEnumerationOptions)opts passingTest:(bool (^)(id obj, NSMutableDictionary * attributes, NSUInteger idx, BOOL *stop))predicate
{
    return [_bucket indexOfObjectAtIndexes:indexSet options:opts passingTest:^BOOL(__FSMutableAttributedArray_Container__ * obj, NSUInteger idx, BOOL *stop) {
        return predicate(obj->_value, obj->_attributes, idx, stop);
    }];
}

#pragma mark Sending Messages to Elements

- (void)enumerateObjectsUsingBlock:(void (^)(id obj, NSMutableDictionary * attributes, NSUInteger idx, BOOL *stop))block
{
    [_bucket enumerateObjectsUsingBlock:^(__FSMutableAttributedArray_Container__ * obj, NSUInteger idx, BOOL *stop) {
        block(obj->_value, obj->_attributes, idx, stop);
    }];
}

- (void)enumerateObjectsWithOptions:(NSEnumerationOptions)opts usingBlock:(void (^)(id obj, NSMutableDictionary * attributes, NSUInteger idx, BOOL *stop))block
{
    [_bucket enumerateObjectsWithOptions:opts usingBlock:^(__FSMutableAttributedArray_Container__ * obj, NSUInteger idx, BOOL *stop) {
        block(obj->_value, obj->_attributes, idx, stop);
    }];
}

- (void)enumerateObjectsAtIndexes:(NSIndexSet *)indexSet options:(NSEnumerationOptions)opts usingBlock:(void (^)(id obj, NSMutableDictionary * attributes, NSUInteger idx, BOOL *stop))block
{
    [_bucket enumerateObjectsAtIndexes:indexSet options:opts usingBlock:^(__FSMutableAttributedArray_Container__ * obj, NSUInteger idx, BOOL *stop) {
        block(obj->_value, obj->_attributes, idx, stop);
    }];
}

#pragma mark Adding Objects

- (void)addObject:(id)object withAttributes:(NSDictionary *)attributes
{
    __FSMutableAttributedArray_Container__ * c = [[__FSMutableAttributedArray_Container__ alloc] init];
    c->_value = object;
    c->_attributes = attributes? [attributes mutableCopy] : [NSMutableDictionary dictionary];
    [_bucket addObject:c];
}

- (void)insertObject:(id)object withAttributes:(NSDictionary *)attributes atIndex:(NSUInteger)index
{
    __FSMutableAttributedArray_Container__ * c = [[__FSMutableAttributedArray_Container__ alloc] init];
    c->_value = object;
    c->_attributes = attributes? [attributes mutableCopy] : [NSMutableDictionary dictionary];
    [_bucket insertObject:c atIndex:index];
}

#pragma mark Replacing Objects

- (void)replaceObjectAtIndex:(NSUInteger)index withObject:(id)object attributes:(NSDictionary *)attributes
{
    __FSMutableAttributedArray_Container__ * c = [[__FSMutableAttributedArray_Container__ alloc] init];
    c->_value = object;
    c->_attributes = attributes? [attributes mutableCopy] : [NSMutableDictionary dictionary];
    [_bucket replaceObjectAtIndex:index withObject:c];
}

- (void)setValue:(id)value ofAttribute:(id)key forObjectAtIndex:(NSUInteger)index
{
    __FSMutableAttributedArray_Container__ * c = [_bucket objectAtIndex:index];
    [c->_attributes setObject:value forKey:key];
}

- (void)setBooleanValue:(bool)value ofAttribute:(id)key forObjectAtIndex:(NSUInteger)index
{
    __FSMutableAttributedArray_Container__ * c = [_bucket objectAtIndex:index];
    [c->_attributes setObject:[NSNumber numberWithBool:(BOOL)value] forKey:key];
}

#pragma mark Removing Objects

- (void)removeObjectAtIndex:(NSUInteger)index
{
    [_bucket removeObjectAtIndex:index];
}

- (void)removeLastObject
{
    [_bucket removeLastObject];
}

#pragma mark NSObject

- (NSString *)description
{
    return [_bucket description];
}

@end

@implementation __FSMutableAttributedArray_Container__
@synthesize value = _value;
@synthesize attributes = _attributes;
- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@:%p value:%@ attributes:%@>", NSStringFromClass([self class]), (const void *)self, _value, [_attributes fs_rubyHashDescription]];
}
@end
