//
//  TryCatch.h
//  e-Homegreen
//
//  Created by Teodor Stevic on 7/28/15.
//  Copyright (c) 2015 Teodor Stevic. All rights reserved.
//

#import <Foundation/Foundation.h>
@import UIKit;

@interface TryCatch : NSObject

+(void)try:(void(^)())try catch:(void(^)(NSException*exception))catch finally:(void(^)())finally;

+(void)throwString:(NSString*)s;

+(void)throwException: (NSException*)e;

@end
