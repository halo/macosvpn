//
//  FSArgumentPackage.h
//  FSArgumentParser
//
//  Created by Christopher Miller on 2/23/12.
//  Copyright (c) 2012 Christopher Miller. All rights reserved.
//

#import <Foundation/Foundation.h>

//! dumb return structure which bundles up all the relevant information
@interface FSArgumentPackage : NSObject

- (NSArray *)allObjectsForSignature:(id)signature;
- (id)firstObjectForSignature:(id)signature;
- (id)lastObjectForSignature:(id)signature;
- (id)objectAtIndex:(NSUInteger)index forSignature:(id)signature;

- (bool)booleanValueForSignature:(id)signature;
- (NSUInteger)countOfSignature:(id)signature;

- (NSArray *)unknownSwitches;
- (NSArray *)uncapturedValues;

@end
