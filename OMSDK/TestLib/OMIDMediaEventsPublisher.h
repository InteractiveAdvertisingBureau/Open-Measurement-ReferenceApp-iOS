//
//  OMIDMediaEventsPublisher.h
//  AppVerificationLibrary
//
//  Created by Daria on 01/08/2017.
//

#import <Foundation/Foundation.h>

/*!
 * @discussion Provides a capacity to publish media events to JS layer.
 */
@protocol OMIDMediaEventsPublisher <NSObject>

/*!
 * @abstract Publishes media event.
 *
 * @param name The media event name.
 * @param parameters The media event parameters in JSON format.
 */
- (void)publishMediaEventWithName:(NSString *)name parameters:(NSDictionary *)parameters;

@end
