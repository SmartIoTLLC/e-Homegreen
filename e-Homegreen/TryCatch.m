//
//  TryCatch.m
//  e-Homegreen
//
//  Created by Teodor Stevic on 7/28/15.
//  Copyright (c) 2015 Teodor Stevic. All rights reserved.
//

#import "TryCatch.h"

@implementation TryCatch

+(void)try:(void(^)())try catch:(void(^)(NSException*exception))catch finally:(void(^)())finally {
    @try {
        try ? try() : nil;
    }
    @catch (NSException *exception) {
        catch ? catch(exception) : nil;
    }
    @finally {
        finally ? finally() : nil;
    }
}

+(void)throwString:(NSString*)s {
    @throw [NSException exceptionWithName:s reason:s userInfo:Nil];
}

+(void)throwException: (NSException*)e {
    @throw e;
}

@end
