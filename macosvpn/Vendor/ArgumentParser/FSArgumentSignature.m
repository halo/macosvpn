//
//  FSArgumentSignature.m
//  FSArgumentParser
//
//  Created by Christopher Miller on 2/22/12.
//  Copyright (c) 2012 Christopher Miller. All rights reserved.
//

#import "FSArgumentSignature.h"
#import "FSArgumentSignature_Private.h"
#import "FSArguments_Coalescer_Internal.h"

#import "FSCountedArgument.h"
#import "FSValuedArgument.h"

// more robust format ctors
#import "CoreParse.h"

#import "FSSwitchRecognizer.h"
#import "FSSwitchToken.h"
#import "FSAliasRecognizer.h"
#import "FSAliasToken.h"
#import "FSFormatCtorTokeniserDelegate.h"
#import "FSFormatCtorParserDelegate.h"

// used in computing the hash value
#import <CommonCrypto/CommonDigest.h>

@implementation FSArgumentSignature

@synthesize switches = _switches;
@synthesize aliases = _aliases;

@synthesize injectedSignatures = _injectedSignatures;
@synthesize descriptionHelper = _descriptionHelper;

- (id)initWithSwitches:(id)switches aliases:(id)aliases
{
    self = [self init];
    
    switches = __fsargs_coalesceToSet(switches);
    aliases = __fsargs_coalesceToSet(aliases);
    
    if (self) {
        _switches = switches?:_switches; // keep empty set
        _aliases = aliases?:_aliases; // keep empty set
    }
    
    return self;
}

- (NSString *)descriptionForHelpWithIndent:(NSUInteger)indent terminalWidth:(NSUInteger)width
{
    return @"";
}

#pragma mark Format String Constructors

+ (id)argumentSignatureWithFormat:(NSString *)format, ...
{
    va_list args;
    va_start(args, format);
    
    FSArgumentSignature * signature = [FSArgumentSignature argumentSignatureWithFormat:format arguments:args];
    
    va_end(args);
    
    return signature;
}

- (id)initWithFormat:(NSString *)format, ...
{
    va_list args;
    va_start(args, format);
    
    self = [self initWithFormat:format arguments:args];
    
    va_end(args);
    
    return self;
}

+ (id)argumentSignatureWithFormat:(NSString *)format arguments:(va_list)args
{
    return [[[self class] alloc] initWithFormat:format arguments:args];
}

- (id)initWithFormat:(NSString *)format arguments:(va_list)args
{
    NSString * input = [[NSString alloc] initWithFormat:format arguments:args];
    
    CPTokeniser * tokeniser = [[self class] formatTokens];
    CPParser * parser = [[self class] formatParser];
    
    CPSyntaxTree * tree = [parser parse:[tokeniser tokenise:input]];
    
    if (tree) {
        // grab some data from the tree
        bool valued = false;
        NSRange valueRange = NSMakeRange(1, 1);
        NSArray * aliasesAndSwitches = [[tree children] objectAtIndex:1];
        NSArray * values = [[tree children] objectAtIndex:3];
        if ([values count] > 0) {
            values = [values objectAtIndex:0]; // some random inner array for no good reason
            valued = true;
            if ([values count] >= 5) {
                // it has value. 0:= 1:{ 2:number 3:, 4:(number or }) 5:}?
                NSAssert([[values objectAtIndex:0] isKindOfClass:[CPKeywordToken class]], @"expecting keyword token");
                NSAssert([[values objectAtIndex:1] isKindOfClass:[CPKeywordToken class]], @"expecting keyword token");
                NSAssert([[values objectAtIndex:3] isKindOfClass:[CPKeywordToken class]], @"expecting keyword token");
                NSNumber * location = [[values objectAtIndex:2] number];
                valueRange.location = [location integerValue];
                valueRange.length = [location integerValue];
                NSNumber * length;
                if ([[values objectAtIndex:4] isKindOfClass:[CPNumberToken class]]) {
                    length = [[values objectAtIndex:4] number];
                    valueRange.length = MAX(valueRange.location, [length integerValue]);
                } else {
                    valueRange.length = NSNotFound; // infinite
                }
            }
        }
        
        NSMutableSet * aliases = [NSMutableSet set];
        NSMutableSet * switches = [NSMutableSet set];
        for (CPToken * t in aliasesAndSwitches) {
            if ([t isKindOfClass:[FSSwitchToken class]]) {
                NSString * sw = [((FSSwitchToken *)t) identifier];
                if ([sw hasPrefix:@"--"])
                    [switches addObject:[sw substringFromIndex:2]];
                else if ([sw hasPrefix:@"-"])
                    [switches addObject:[sw substringFromIndex:1]];
                else
                    NSAssert(YES==NO, @"Dude, seriously?");
            } else if ([t isKindOfClass:[FSAliasToken class]]) {
                [aliases addObject:[((FSAliasToken *)t) identifier]];
            } else {
                NSAssert(YES==NO, @"dude, seriously?");
            }
        }        
        
        // init a subclass based on what that says
        if (valued)
            self = [FSValuedArgument valuedArgumentWithSwitches:[switches copy] aliases:[aliases copy] valuesPerInvocation:valueRange];
        else
            self = [FSCountedArgument countedArgumentWithSwitches:[switches copy] aliases:[aliases copy]];
        
    } else {
        return nil;
    }
    
    return self;
}

#pragma mark Private Implementation

- (void)updateHash:(CC_MD5_CTX *)md5
{
    // note that _injectedSignatures and _descriptionHelper is ignored in the uniqueness evaluation
    
    // add the class name too, just to make it more unique
    NSUInteger classHash = [NSStringFromClass([self class]) hash];
    CC_MD5_Update(md5, (const void *)&classHash, sizeof(NSUInteger));
    
    for (NSString * s in _switches) {
        NSUInteger hash = [__fsargs_expandSwitch(s) hash];
        CC_MD5_Update(md5, (const void *)&hash, sizeof(NSUInteger));
    }
    
    for (NSString * s in _aliases) {
        NSUInteger hash = [s hash];
        CC_MD5_Update(md5, (const void *)&hash, sizeof(NSUInteger));
    }
}

- (bool)respondsToSwitch:(NSString *)s
{
    if ([s hasPrefix:@"--"]) s = [s substringFromIndex:2];
    else if ([s hasPrefix:@"-"]) s = [s substringFromIndex:1];
    
    return (bool)[_switches containsObject:s];
}

- (bool)respondsToAlias:(NSString *)alias
{
    return (bool)[_aliases containsObject:alias];
}

+ (CPTokeniser *)formatTokens
{
    static CPTokeniser * expressionTokens;
    static FSFormatCtorTokeniserDelegate * delegate;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        expressionTokens = [[CPTokeniser alloc] init];
        [expressionTokens addTokenRecogniser:[CPNumberRecogniser integerRecogniser]];
        [expressionTokens addTokenRecogniser:[CPWhiteSpaceRecogniser whiteSpaceRecogniser]];
        [expressionTokens addTokenRecogniser:[CPKeywordRecogniser recogniserForKeyword:@"["]];
        [expressionTokens addTokenRecogniser:[CPKeywordRecogniser recogniserForKeyword:@"]"]];
        [expressionTokens addTokenRecogniser:[CPKeywordRecogniser recogniserForKeyword:@"{"]];
        [expressionTokens addTokenRecogniser:[CPKeywordRecogniser recogniserForKeyword:@"}"]];
        [expressionTokens addTokenRecogniser:[CPKeywordRecogniser recogniserForKeyword:@","]];
        [expressionTokens addTokenRecogniser:[CPKeywordRecogniser recogniserForKeyword:@"="]];
        [expressionTokens addTokenRecogniser:[FSSwitchRecognizer switchRecognizer]];
        [expressionTokens addTokenRecogniser:[FSAliasRecognizer aliasRecognizer]];
        delegate = [[FSFormatCtorTokeniserDelegate alloc] init];
        [expressionTokens setDelegate:delegate];
    });
    return expressionTokens;
}

+ (CPGrammar *)formatGrammar
{
    static CPGrammar * expressionGrammer;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString * bnfFormat =
        @"FormatSequence   ::= \"[\" <FormatInvocation>+ \"]\" <ValueInvocation>?;"
        @"FormatInvocation ::= \"Switch\" | \"Alias\";"
        @"ValueInvocation  ::= \"=\" <ValueSpecifier>?;"
        @"ValueSpecifier   ::= \"{\" \"Number\" \",\" \"Number\"? \"}\";"
        ;
        NSError * error = nil;
        expressionGrammer = [CPGrammar grammarWithStart:@"FormatSequence" backusNaurForm:bnfFormat error:&error];
        
        // try and blow up if error isn't nil; i'd be more worried if I hadn't already tested this grammar
    });
    return expressionGrammer;
}

+ (CPParser *)formatParser
{
    static CPParser * expressionParser;
    static FSFormatCtorParserDelegate * delegate;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        expressionParser = [CPSLRParser parserWithGrammar:[self formatGrammar]];
        delegate = [[FSFormatCtorParserDelegate alloc] init];
        [expressionParser setDelegate:delegate];
    });
    return expressionParser;
}

#pragma mark NSCopying

- (id)copy
{
    FSArgumentSignature * copy = [[[self class] alloc] initWithSwitches:_switches aliases:_aliases];
    
    if (copy) {
        copy->_injectedSignatures = _injectedSignatures;
    }
    
    return copy;
}

- (id)copyWithZone:(NSZone *)zone
{
    return [self copy];
}

#pragma mark NSObject

- (id)init
{
    if ([self class] == [FSArgumentSignature class]) {
        [NSException raise:@"net.fsdev.ArgumentParser.VirtualClassInitializedException" format:@"This is supposed to be a pure-virtual class. Please use either %@ or %@ instead of directly using this class.", NSStringFromClass([FSCountedArgument class]), NSStringFromClass([FSValuedArgument class])];
    }
    
    self = [super init];
    
    if (self) {
        _injectedSignatures = [NSSet set];
        _switches = [NSSet set];
        _aliases = [NSSet set];
    }
    
    return self;
}

- (BOOL)isEqual:(id)object
{
    if ([object class] == [self class])
        return [object hash] == [self hash];
    else
        return NO;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@:%p>", NSStringFromClass([self class]), self];
}

@end

NSRegularExpression * __fsargs_generalRegex(NSError ** error)
{
    static NSRegularExpression * r;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        r = [NSRegularExpression regularExpressionWithPattern:@"\\A\\[([^\\]]*)\\](=)?\\{?(\\d)?,?(\\d)?\\}?\\z" options:0 error:error];
        // \A\[([^\]]*)\](=)?\{?(\d)?,?(\d)?\}?\z
        // "[-f --file if]={1,1}"       => "-f --file if", "=", "1", "1", nil
        // "[-f --file if]={1,}"        => "-f --file if", "=", "1", nil, nil
        // "[-f --file if]="            => "-f --file if", "=", nil, nil, nil
    });
    return r;
}
