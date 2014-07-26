//
//  FSArgumentPackage_Private.h
//  ArgumentParser
//
//  Created by Christopher Miller on 5/16/12.
//  Copyright (c) 2012 Christopher Miller. All rights reserved.
//

#import "FSArgumentPackage.h"

@class FSArgumentSignature;

@interface FSArgumentPackage () {
@public
    CFMutableDictionaryRef _countedValues;
    NSMutableDictionary * _valuedValues;
    NSMutableArray * _uncapturedValues;
    NSMutableSet * _allSignatures;
    NSMutableArray * _unknownSwitches;
}

- (void)incrementCountOfSignature:(FSArgumentSignature *)signature;
- (void)addObject:(id)object toSignature:(FSArgumentSignature *)signature;
- (NSString *)prettyDescription;

@end
