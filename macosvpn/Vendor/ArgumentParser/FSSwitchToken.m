//
//  FSSwitchToken.m
//  ArgumentParser
//
//  Created by Christopher Miller on 5/17/12.
//  Copyright (c) 2012 Christopher Miller. All rights reserved.
//

#import "FSSwitchToken.h"

@implementation FSSwitchToken
@synthesize identifier = _identifier;
+ (id)switchTokenWithIdentifier:(NSString *)identifier
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
    return @"Switch";
}
#pragma mark NSObject
- (NSString *)description
{
    return [NSString stringWithFormat:@"<Switch: %@>", _identifier];
}
@end
