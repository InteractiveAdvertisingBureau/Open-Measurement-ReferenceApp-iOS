//
//  OMIDEventFilter.h
//  AppVerificationLibrary
//
//  Created by Daria on 06/07/2017.
//

#import <Foundation/Foundation.h>

/*!
 * @abstract A list of supported events.
 */
typedef enum OMIDEventCode : NSUInteger {
    OMIDEventCodeStart = (1 << 0),
    OMIDEventCodeImpression = (1 << 1),
    OMIDEventCodeLoaded = (1 << 2),
    OMIDEventCodeAdEventsRegistration = (1 << 3),
    OMIDEventCodeMediaEventsRegistration = (1 << 4),
    OMIDEventCodeFinish = (1 << 5)
} OMIDEventCode;

/*!
 * @discussion Utility class ensured that particular events are published once, are published in proper order, etc.
 */
@interface OMIDEventFilter : NSObject

/*!
 * @abstract A Boolean value indicating whether the final event has been published.
 */
@property(nonatomic, readonly, getter = isFinalEventAccepted) BOOL finalEventAccepted;

/*!
 * @abstract Initializes new event filter with final event code.
 *
 * @discussion Event filter will reject any event after final event has been published. Default final event is event with OMIDEventCodeFinish code.
 *
 * @param eventCode The code of the final event.
 * @return A new instance of event filter.
 */
- (instancetype)initWithFinalEventCode:(OMIDEventCode)eventCode;

/*!
 * @abstract Checks whether the event could be published.
 * 
 * @param eventCode The code of the event.
 * @return YES if event could be published. Returns NO if the event with this code has been already published or if the final event has been published.
 */
- (BOOL)acceptEventWithCode:(OMIDEventCode)eventCode;

/*!
 * @abstract Checks whether the event could be published.
 *
 * @discussion This method ensures that particular event will not published if any event from blockingEventCodes has been published. You could provide several blocking events using bitwise OR operator:
 * <p>
 * [eventFilter acceptEventWithCode:OMIDEventCodeMediaEventsRegistration blockingEventCodes:OMIDEventCodeStart | OMIDEventCodeImpression]
 *
 * @param eventCode The code of the event.
 * @param blockingEventCodes The codes of the events which should not be published prior to this event.
 * @return YES if event could be published. Returns NO if the event with this code has been already published, or if the final event has been published, or if any event from blockingEventCodes has been published.
 */
- (BOOL)acceptEventWithCode:(OMIDEventCode)eventCode blockingEventCodes:(OMIDEventCode)blockingEventCodes;

/*!
 * @abstract Checks whether any event could be published.
 *
 * @discussion This method is used for media events which could be published multiple times. This method ensures that the provided event will not be published if all events from requiredEventCodes have not been published. You could provide several required events using bitwise OR operator:
 * <p>
 * [eventFilter acceptAnyEventWithRequiredEventCodes:OMIDEventCodeStart | OMIDEventCodeImpression]
 *
 * @param requiredEventCodes The codes of the events which should be published prior to this event. The value should be 0 if this event does not require any prior events.
 * @return YES if event could be published. Returns NO if the final event has been published or if at least one event from requiredEventCodes has not been published.
 */
- (BOOL)acceptAnyEventWithRequiredEventCodes:(OMIDEventCode)requiredEventCodes;

@end
