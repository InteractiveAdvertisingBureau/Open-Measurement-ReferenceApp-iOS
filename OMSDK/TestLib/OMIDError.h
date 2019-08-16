//
//  OMIDError.h
//  AppVerificationLibrary
//
//  Created by Saraev Vyacheslav on 11/12/2017.
//

#import <Foundation/Foundation.h>
#import "OMIDConstants.h"

@interface OMIDError: NSObject
+ (BOOL)setOMIDErrorFor:(NSError *__autoreleasing *)error code:(OMIDErrorCode)code message:(NSString *)message;
@end
