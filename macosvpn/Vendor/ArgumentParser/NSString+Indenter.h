//
//  NSString+Indenter.h
//  ArgumentParser
//
//  Created by Christopher Miller on 5/11/12.
//  Copyright (c) 2012 Christopher Miller. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Indenter)

- (NSMutableString *)fsargs_mutableStringByIndentingToWidth:(NSUInteger)indent lineLength:(NSUInteger)width;

@end
