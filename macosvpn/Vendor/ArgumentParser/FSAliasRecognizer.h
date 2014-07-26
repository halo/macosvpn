//
//  FSValueRecognizer.h
//  ArgumentParser
//
//  Created by Christopher Miller on 5/17/12.
//  Copyright (c) 2012 Christopher Miller. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "CPTokenRecogniser.h"

@interface FSAliasRecognizer : NSObject < CPTokenRecogniser >
+ (id)aliasRecognizer;
@end
