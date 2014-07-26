//
//  FSValuedArgument.h
//  ArgumentParser
//
//  Created by Christopher Miller on 5/11/12.
//  Copyright (c) 2012 Christopher Miller. All rights reserved.
//

#import "FSArgumentSignature.h"

/** An argument which has one or more values attached to it. */
@interface FSValuedArgument : FSArgumentSignature

/**
 * The number of values per invocation, which should start at one and have a maximum of NSNotFound (infinity).
 *
 * Note that this is not used as NSRange is normally used! The `location` is the *minimum* number of values per invocation, and the `length` is the *maximum* number of values per invocation.
 */
@property (assign) NSRange valuesPerInvocation;

+ (id)valuedArgumentWithSwitches:(id)switches aliases:(id)aliases;
- (id)initWithSwitches:(id)switches aliases:(id)aliases;

+ (id)valuedArgumentWithSwitches:(id)switches aliases:(id)aliases valuesPerInvocation:(NSRange)valuesPerInvocation;
- (id)initWithSwitches:(id)switches aliases:(id)aliases valuesPerInvocation:(NSRange)valuesPerInvocation;


@end
