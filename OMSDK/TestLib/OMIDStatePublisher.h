//
//  OMIDStatePublisher.h
//  AppVerificationLibrary
//
//  Created by Daria on 20/03/17.
//

#import <Foundation/Foundation.h>

@class OMIDAdSessionRegistry;

/*!
 * @discussion State publisher is responsible for publishing native view hierarchy to ad sessions.
 */
@interface OMIDStatePublisher : NSObject

/*!
 * @abstract The last published native view hierarchy.
 */
@property(nonatomic, readonly) NSMutableDictionary *previousState;

/*!
 * @abstract Ad session registry containing ad sessions.
 */
@property(nonatomic, readonly) OMIDAdSessionRegistry *adSessionRegistry;

/*!
 * @abstract Initializes state publisher with ad session registry.
 *
 * @param adSessionRegistry The ad session registry.
 * @return A new state publisher instance.
 */
- (id)initWithAdSessionRegistry:(OMIDAdSessionRegistry *)adSessionRegistry;

/*!
 * @abstract Publishes native view hierarchy to ad sessions.
 *
 * @discussion Native view hierarchy is published only to ad sessions from sessionIds set. State publisher compares provided native view hierarchy with the last published hierarchy. If there are no changes in the hierarchy when state publisher will not publish it. State publisher compares hierarchies and converts hierarchy to string in the background thread. Publishing view hierarchy to ad sessions is performed in the main thread.
 *
 * @param state The native view hierarchy.
 * @param sessionIds The ads of ad sessions which should receive this native view hierarchy.
 * @param timestamp The timestamp of the native view hierarchy.
 */
- (void)publishState:(NSMutableDictionary *)state toSessions:(NSSet *)sessionIds timestamp:(NSTimeInterval)timestamp;

/*!
 * @abstract Publishes empty native view hierarchy to ad sessions.
 *
 * @discussion Empty native view hierarchy is published only to ad sessions from sessionIds set. State publisher creates the empty hierarchy and converts it to string in the background thread. Publishing view hierarchy to ad sessions is performed in the main thread.
 *
 * @param sessionIds The ads of ad sessions which should receive the empty native view hierarchy.
 * @param timestamp The timestamp of the empty native view hierarchy.
 */
- (void)publishEmptyStateToSessions:(NSSet *)sessionIds timestamp:(NSTimeInterval)timestamp;

/*!
 * @abstract Sets previousState to nil.
 *
 * @discussion This method is called when tree walker stops.
 */
- (void)cleanupCache;

@end
