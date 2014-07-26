//
//  FSArgumentSignature_Private.h
//  ArgumentParser
//
//  Created by Christopher Miller on 5/14/12.
//  Copyright (c) 2012 Christopher Miller. All rights reserved.
//

#import "FSArgumentSignature.h"

#import "CoreParse.h"

// used in computing the hash value
#import <CommonCrypto/CommonDigest.h>

NSRegularExpression * __fsargs_generalRegex(NSError **);

@interface FSArgumentSignature () {
@protected
    NSSet * _switches;
    NSSet * _aliases;
    NSSet * _injectedSignatures;
    NSString * (^_descriptionHelper) (FSArgumentSignature * currentSignature, NSUInteger indentLevel, NSUInteger terminalWidth);
}

- (id)initWithSwitches:(id)switches aliases:(id)aliases;

- (void)updateHash:(CC_MD5_CTX *)md5; // update the hash value with shared bits

- (bool)respondsToSwitch:(NSString *)s;
- (bool)respondsToAlias:(NSString *)alias;

+ (CPTokeniser *)formatTokens;
+ (CPGrammar *)formatGrammar;
+ (CPParser *)formatParser;

@end
