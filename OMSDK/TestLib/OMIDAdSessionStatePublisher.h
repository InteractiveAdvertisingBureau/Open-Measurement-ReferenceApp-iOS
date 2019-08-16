//
//  OMIDAdSessionStatePublisher.h
//  AppVerificationLibrary
//
//  Created by Daria on 06/07/2017.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "OMIDCommandPublisher.h"

/*!
 * @abstract A list of possible ad states.
 *
 * @constant OMIDAdStateIdle Means ad session has not received native view hierarchy.
 * @constant OMIDAdStateVisible Means ad session has received native view hierarchy.
 * @constant OMIDAdStateHidden Means ad session has received empty native view hierarchy.
 */
typedef enum OMIDAdState : NSUInteger {
    OMIDAdStateIdle,
    OMIDAdStateVisible,
    OMIDAdStateHidden
} OMIDAdState;

/*!
 * @discussion This class is responsible for publishing native view hierarchy and application state
 *     to OMID JS.
 */
@interface OMIDAdSessionStatePublisher : NSObject

/*!
 * @abstract The command publisher used to publish native view hierarchy and application state to
 *     OMID JS.
 */
@property(nonatomic, readonly) id<OMIDCommandPublisher> commandPublisher;

/*!
 * @abstract Current ad state.
 */
@property(nonatomic, readonly) OMIDAdState adState;

/*!
 * @abstract The timestamp of registered ad view.
 *
 * @discussion The value of this property is updated each time when ad view is registered or
 *     unregistered with the ad session.
 */
@property(nonatomic, readonly) NSTimeInterval timestamp;

/*!
 * @abstract Initializes new state publisher.
 *
 * @param commandPublisher OMIDCommandPublisher implementation.
 * @return A new state publisher instance.
 */
- (instancetype)initWithCommandPublisher:(id<OMIDCommandPublisher>)commandPublisher;

/*!
 * @abstract Sets adState to OMIDAdStateIdle and updates timestamp.
 *
 * @discusssion This method is called each time when ad view is registered or unregistered with the
 *     ad session.
 */
- (void)cleanupAdState;

/*!
 * @abstract Publishes native view hierarchy to OMID JS.
 *
 * @discussion Native view hierarchy will be ignored if timestamp of state publisher is larger than
 *     timestamp of native view hierarchy. This method sets adState to OMIDAdStateVisible.
 *
 * @param hierarchy String with JSON representation of native view hierarchy.
 * @param timestamp Timestamp of native view hierarchy.
 */
- (void)publishNativeViewStateWithHierarchy:(NSString *)hierarchy
                                  timestamp:(NSTimeInterval)timestamp;

/*!
 * @abstract Publishes empty native view hierarchy to OMID JS.
 *
 * @discussion Empty native view hierarchy is published when registered ad view is hidden or is not
 *     attached to window. Native view hierarchy will be ignored if timestamp of state publisher is
 *     larger than timestamp of native view hierarchy or if empty native view hierarchy has been
 *     already published. This method sets adState to OMIDAdStateHidden.
 *
 * @param hierarchy String with JSON representation of empty native view hierarchy.
 * @param timestamp Timestamp of empty native view hierarchy.
 */
- (void)publishEmptyNativeViewStateWithHierarchy:(NSString *)hierarchy
                                       timestamp:(NSTimeInterval)timestamp;

/*!
 * @abstract Publishes application state to OMID JS.
 *
 * @param appState A string representing application state.
 */
- (void)publishAppState:(NSString *)appState;

/*!
 * @abstract Publishes device volume level to OMID JS.
 *
 * @param volume A device volume level.
 */
- (void)publishDeviceVolume:(CGFloat)volume;

@end
