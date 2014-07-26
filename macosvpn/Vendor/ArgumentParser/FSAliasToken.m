//
//  FSAliasToken.m
//  ArgumentParser
//
//  Created by Christopher Miller on 5/17/12.
//  Copyright (c) 2012 Christopher Miller. All rights reserved.
//

#import "FSAliasToken.h"

@implementation FSAliasToken
@synthesize identifier = _identifier;
+ (id)aliasTokenWithIdentifier:(NSString *)identifier
{
    return [[self alloc] initWithIdentifier:identifier];
}
- (id)initWithIdentifier:(NSString *)identifier
{
    self = [super init];
    
    if (self) {
        _identifier = identifier;
    }
    
    return self;
}
#pragma mark CPToken
- (NSString *)name
{
    return @"Alias";
}
#pragma mark NSObject
- (NSString *)description
{
    return [NSString stringWithFormat:@"<Alias: %@>", _identifier];
}
@end
