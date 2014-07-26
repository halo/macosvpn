//
//  FSAliasToken.h
//  ArgumentParser
//
//  Created by Christopher Miller on 5/17/12.
//  Copyright (c) 2012 Christopher Miller. All rights reserved.
//

#import "CPToken.h"

@interface FSAliasToken : CPToken
@property (strong) NSString * identifier;
+ (id)aliasTokenWithIdentifier:(NSString *)identifier;
- (id)initWithIdentifier:(NSString *)identifier;
@end
