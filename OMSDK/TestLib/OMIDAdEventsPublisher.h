//
//  OMIDAdEventsPublisher.h
//  AppVerificationLibrary
//
//  Created by Daria on 01/08/2017.
//

#import <Foundation/Foundation.h>
#import "OMIDVASTProperties.h"

/*!
 * @discussion Provides a capacity to publish ad events to JS layer.
 */
@protocol OMIDAdEventsPublisher <NSObject>

/*!
 * @abstract Publishes impression event.
 */
- (void)publishImpressionEvent;

/*!
 * @abstract Publishes display loaded event.
 */
- (void)publishLoadedEvent;

/*!
 *@abstract Publishes video/audio loaded event.
 */
- (void)publishLoadedEventWithVastProperties:(OMIDVASTProperties *_Nonnull)vastProperties;

@end
