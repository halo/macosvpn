//
//  FSArguments_Coalescer_Internal.h
//  ArgumentParser
//
//  Created by Christopher Miller on 5/11/12.
//  Copyright (c) 2012 Christopher Miller. All rights reserved.
//

#import <Foundation/Foundation.h>

NSCharacterSet * __fsargs_coalesceToCharacterSet(id);
NSArray * __fsargs_coalesceToArray(id);
NSSet * __fsargs_coalesceToSet(id);
NSArray * __fsargs_charactersFromCharacterSetAsArray(NSCharacterSet *);
NSString * __fsargs_charactersFromCharacterSetAsString(NSCharacterSet *);
NSString * __fsargs_expandSwitch(NSString *); // expand a switch, taking c to -c and config to --config
NSArray * __fsargs_expandAllSwitches(id);