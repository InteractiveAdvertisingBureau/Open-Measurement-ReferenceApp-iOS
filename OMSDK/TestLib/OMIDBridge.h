//
//  OMIDBridge.h
//  AppVerificationLibrary
//
//  Created by Daria Sukhonosova on 31/08/15.
//

#import <UIKit/UIKit.h>
#import "OMIDJSExecutor.h"
#import "OMIDCommandPublisher.h"
#import "OMIDSessionEventsPublisher.h"
#import "OMIDAdEventsPublisher.h"
#import "OMIDMediaEventsPublisher.h"

/*!
 * @discussion Utility to inject script to OMID JS.
 */
@interface OMIDBridge : NSObject <OMIDCommandPublisher, OMIDSessionEventsPublisher, OMIDAdEventsPublisher, OMIDMediaEventsPublisher>

/*!
 * @abstract Java script executor.
 */
@property(nonatomic, readonly) id<OMIDJSExecutor> jsExecutor;

/*!
 * @abstract Initializes new instance with provided java script executor.
 *
 * @param jsExecutor Java script executor.
 * @return New OMIDBridge instance.
 */
- (instancetype)initWithJSExecutor:(id<OMIDJSExecutor>)jsExecutor;

@end
