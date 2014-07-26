//
//  FSCountedArgument.h
//  ArgumentParser
//
//  Created by Christopher Miller on 5/11/12.
//  Copyright (c) 2012 Christopher Miller. All rights reserved.
//

#import "FSArgumentSignature.h"

/** Counted or boolean argument signature. */
@interface FSCountedArgument : FSArgumentSignature

+ (id)countedArgumentWithSwitches:(id)switches aliases:(id)aliases;
- (id)initWithSwitches:(id)switches aliases:(id)aliases;

@end
