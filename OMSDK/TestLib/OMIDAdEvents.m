//
//  OMIDAdEvents.m
//  AppVerificationLibrary
//
//  Created by Daria Sukhonosova on 22/06/2017.
//

#import "OMIDAdEvents.h"
#import "OMIDAdSession+Private.h"
#import "OMIDConstants.h"
#import "OMIDError.h"

@interface OMIDAdEvents () {
    OMIDAdSession *_adSession;
}

@end

@implementation OMIDAdEvents

- (nullable instancetype)initWithAdSession:(nonnull OMIDAdSession *)session
                                     error:(NSError * _Nullable *_Nullable)error {
    self = [super init];
    if (self) {
        if (session == nil) {
            [OMIDError setOMIDErrorFor:error code:OMIDAdSessionIsNilError message:OMID_AD_SESSION_CAN_NOT_BE_NIL_ERROR_MESSAGE];
            return nil;
        }
        if (![session.eventFilter acceptEventWithCode:OMIDEventCodeAdEventsRegistration]) {
            [OMIDError setOMIDErrorFor:error code:OMIDEventFilterDoesNotAcceptError message:OMID_EVENT_FILTER_DOES_NOT_ACCEPT_ERROR_MESSAGE];
            return nil;
        }
        _adSession = session;
    }
    return self;
}

- (BOOL)impressionOccurredWithError:(NSError *_Nullable *_Nullable)error {
    if (_adSession.configuration.impressionOwner != OMIDNativeOwner) {
        [OMIDError setOMIDErrorFor:error code:OMIDImpressionOwnerShouldBeNativeError message:OMID_IMPRESSION_OWNER_SHOULD_BE_NATIVE_ERROR_MESSAGE];
        return NO;
    }
    if ([_adSession.eventFilter acceptEventWithCode:OMIDEventCodeImpression]) {
        [self startSessionIfNeeded];
        [_adSession.adEventsPublisher publishImpressionEvent];
        return YES;
    } else {
        [OMIDError setOMIDErrorFor:error code:OMIDEventFilterDoesNotAcceptError message:OMID_EVENT_FILTER_DOES_NOT_ACCEPT_ERROR_MESSAGE];
    }
    return NO;
}

- (BOOL)loadedWithError:(NSError *_Nullable *_Nullable)error {
  if (_adSession.configuration.impressionOwner != OMIDNativeOwner) {
    [OMIDError setOMIDErrorFor:error code:OMIDImpressionOwnerShouldBeNativeError message:OMID_IMPRESSION_OWNER_SHOULD_BE_NATIVE_ERROR_MESSAGE];
    return NO;
  }
  if ([_adSession.eventFilter acceptEventWithCode:OMIDEventCodeLoaded]) {
    [_adSession.adEventsPublisher publishLoadedEvent];
    return YES;
  } else {
    [OMIDError setOMIDErrorFor:error code:OMIDEventFilterDoesNotAcceptError message:OMID_EVENT_FILTER_DOES_NOT_ACCEPT_ERROR_MESSAGE];
  }
  return NO;
}

- (BOOL)loadedWithVastProperties:(OMIDVASTProperties *_Nonnull)vastProperties
                           error:(NSError *_Nullable *_Nullable)error {
  if (_adSession.configuration.impressionOwner != OMIDNativeOwner) {
    [OMIDError setOMIDErrorFor:error code:OMIDImpressionOwnerShouldBeNativeError message:OMID_IMPRESSION_OWNER_SHOULD_BE_NATIVE_ERROR_MESSAGE];
    return NO;
  }
  if ([_adSession.eventFilter acceptEventWithCode:OMIDEventCodeLoaded]) {
    [_adSession.adEventsPublisher publishLoadedEventWithVastProperties:vastProperties];
    return YES;
  } else {
    [OMIDError setOMIDErrorFor:error code:OMIDEventFilterDoesNotAcceptError message:OMID_EVENT_FILTER_DOES_NOT_ACCEPT_ERROR_MESSAGE];
  }
  return NO;
}

- (void)startSessionIfNeeded {
    if (![_adSession.eventFilter acceptAnyEventWithRequiredEventCodes:OMIDEventCodeStart]) {
        [_adSession start];
    }
}

@end
