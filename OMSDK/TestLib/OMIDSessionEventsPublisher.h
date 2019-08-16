//
//  OMIDSessionEventsPublisher.h
//  AppVerificationLibrary
//
//  Created by Daria on 09/08/2017.
//

#import <Foundation/Foundation.h>
#import "OMIDAdSession.h"

/*!
 * @discussion Provides a capacity to publish session events to JS layer.
 */
@protocol OMIDSessionEventsPublisher <NSObject>

- (void)publishInitWithConfiguration:(OMIDAdSessionConfiguration *)configuration;

/*!
 * @abstract Publishes start event.
 *
 * @param adSessionId The ad session identifier.
 * @param context The ad session context in JSON format.
 * @param verificationParameters JSON object mapping vendor keys to verification parameter strings.
 */
- (void)publishStartEventWithAdSessionId:(NSString *)adSessionId
                             JSONContext:(NSDictionary *)context
                  verificationParameters:(NSDictionary *)verificationParameters;

/*
 * @abstract Publishes event error
 *
 * @param type The error type.
 * @param errorMessage The message containing details of the error.
 */
- (void)publishErrorWithType:(OMIDErrorType)type errorMessage:(NSString *)message;

/*!
 * @abstract Publishes finish event.
 */
- (void)publishFinishEvent;

@end
