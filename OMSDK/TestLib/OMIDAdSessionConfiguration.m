//
//  OMIDAdSessionConfiguration.m
//  AppVerificationLibrary
//
//  Created by Saraev Vyacheslav on 15/09/2017.
//

#import <Foundation/Foundation.h>
#import "OMIDAdSessionConfiguration.h"
#import "OMIDConstants.h"
#import "OMIDError.h"

@implementation OMIDAdSessionConfiguration

#pragma mark - Initializer

- (nullable instancetype)initWithCreativeType:(OMIDCreativeType)creativeType
                               impressionType:(OMIDImpressionType)impressionType
                              impressionOwner:(OMIDOwner)impressionOwner
                             mediaEventsOwner:(OMIDOwner)mediaEventsOwner
                   isolateVerificationScripts:(BOOL)isolateVerificationScripts
                                        error:(NSError *_Nullable *_Nullable)error {
    
    self = [super init];
    if (self) {
        if (creativeType < OMIDCreativeTypeDefinedByJavaScript || creativeType > OMIDCreativeTypeAudio) {
            [OMIDError setOMIDErrorFor:error code:OMIDCreativeTypeIsInvalidError message:OMID_CREATIVE_TYPE_IS_INVALID_ERROR_MESSAGE];
            return nil;
        }
        if (impressionType < OMIDImpressionTypeDefinedByJavaScript || impressionType > OMIDImpressionTypeOther) {
            [OMIDError setOMIDErrorFor:error code:OMIDImpressionTypeIsInvalidError message:OMID_IMPRESSION_TYPE_IS_INVALID_ERROR_MESSAGE];
            return nil;
        }
        if (impressionOwner == OMIDNoneOwner || impressionOwner == 0) {
            [OMIDError setOMIDErrorFor:error code:OMIDImpressionOwnerIsNoneError message:OMID_IMPRESSION_OWNER_CAN_NOT_BE_NONE_ERROR_MESSAGE];
            return nil;
        }
        if ((creativeType == OMIDCreativeTypeDefinedByJavaScript || impressionType == OMIDImpressionTypeDefinedByJavaScript)
            && impressionOwner == OMIDNativeOwner) {
            [OMIDError setOMIDErrorFor:error code:OMIDCreativeTypeAndImpressionTypeShouldBothBeJavaScriptError message:OMID_CREATIVE_TYPE_AND_IMPRESSION_TYPE_SHOULD_BE_JAVASCRIPT_ERROR_MESSAGE];
            return nil;
        }
        if (mediaEventsOwner == 0) {
            mediaEventsOwner = OMIDNoneOwner;
        }
        
        _creativeType = creativeType;
        _impressionType = impressionType;
        _impressionOwner = impressionOwner;
        _mediaEventsOwner = mediaEventsOwner;
        _isolateVerificationScripts = isolateVerificationScripts;
        return self;
    }
    
    return nil;
}

#pragma mark - Deprecated Methods

- (nullable instancetype)initWithImpressionOwner:(OMIDOwner)impressionOwner
                                videoEventsOwner:(OMIDOwner)videoEventsOwner
                      isolateVerificationScripts:(BOOL)isolateVerificationScripts
                                           error:(NSError *_Nullable *_Nullable)error {
    self = [super init];
    if (self) {
        if (impressionOwner == OMIDNoneOwner || impressionOwner == 0) {
            [OMIDError setOMIDErrorFor:error code:OMIDImpressionOwnerIsNoneError message:OMID_IMPRESSION_OWNER_CAN_NOT_BE_NONE_ERROR_MESSAGE];
            return nil;
        }
        if (videoEventsOwner == 0) {
            videoEventsOwner = OMIDNoneOwner;
        }
        _impressionOwner = impressionOwner;
        _mediaEventsOwner = videoEventsOwner;
        _isolateVerificationScripts = isolateVerificationScripts;
        return self;
    }
    
    return nil;
}

- (nullable instancetype)initWithImpressionOwner:(OMIDOwner)impressionOwner
                                videoEventsOwner:(OMIDOwner)videoEventsOwner
                                           error:(NSError *_Nullable *_Nullable)error {
    return [self initWithImpressionOwner:impressionOwner videoEventsOwner:videoEventsOwner isolateVerificationScripts:YES error:error];
}

@end
