//
//  NSArray+FSArgumentsNormalizer.h
//  ArgumentParser
//
//  Created by Christopher Miller on 5/15/12.
//  Copyright (c) 2012 Christopher Miller. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "FSMutableAttributedArray.h"

@interface NSArray (FSArgumentsNormalizer)
- (FSMutableAttributedArray *)fsargs_normalize;
@end
