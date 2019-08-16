//
//  OMIDError.m
//  AppVerificationLibrary
//
//  Created by Saraev Vyacheslav on 11/12/2017.
//

#import <Foundation/Foundation.h>
#import "OMIDError.h"

@implementation OMIDError
+ (BOOL)setOMIDErrorFor:(NSError *__autoreleasing *)error code:(OMIDErrorCode)code message:(NSString *)message {
    if (error) {
        *error = [NSError errorWithDomain:OMID_ERROR_DOMAIN code:code userInfo:@{NSLocalizedDescriptionKey: message}];
        return YES;
    }    
    return NO;
}

@end
