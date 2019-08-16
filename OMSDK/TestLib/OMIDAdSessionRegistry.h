//
//  OMIDAdViewRegistry.h
//  AppVerificationLibrary
//
//  Created by Daria Sukhonosova on 28/08/15.
//

#import <Foundation/Foundation.h>
#import "OMIDAdSession.h"
#import "OMIDAdSessionDelegate.h"

/*!
 * @discussion Ad session registry notifies observers when ad sessions become active or resign active.
 */
@protocol OMIDAdSessionRegistryStateObserver <NSObject>

/*!
 * @abstract Tells observers that ad session registry becomes active.
 *
 * @discussion Ad session registry becomes active when the first ad session is started.
 */
- (void)adSessionRegistryDidBecomeActive;

/*!
 * @abstract Tells observers that ad session registry resigns active.
 *
 * @discussion Ad session registry resigns active when the last active ad session is finished.
 */
- (void)adSessionRegistryDidResignActive;

/*!
 * @abstract Tells observers that particular ad session becomes active.
 *
 * @discussion Ad session becomes active when it is started.
 */
- (void)adSessionDidBecomeActive:(OMIDAdSession *)adSession;

@end

/*!
 * @discussion Ad session registry stores created ad sessions.
 */
@interface OMIDAdSessionRegistry : NSObject <OMIDAdSessionDelegate>

/*!
 * @abstract A list of all created ad sessions.
 *
 * @discussion Ad session registry stores weak references to ad sessions to avoid memory leaks. There could be a situation when ad session is created but not started. In this case there is no guarantee that ad session will be finished.
 */
@property(nonatomic, readonly) NSArray *adSessions;

/*!
 * @abstract A list of all started ad sessions.
 *
 * @discussion Ad session registry creates strong references to started ad sessions. Ad session registry removes ad session from active ad sessions once it has been finished.
 */
@property(nonatomic, readonly) NSArray *activeAdSessions;

/*!
 * @abstract A list of observers implementing OMIDAdSessionRegistryStateObserver protocol.
 */
@property(nonatomic, readonly) NSArray *observers;

/*!
 * @abstract A Boolean value indicating whether ad session registry is active.
 *
 * @discussion Ad session registry is active if there is at least one started ad session.
 */
@property(nonatomic, readonly, getter = isActive) BOOL active;

/*!
 * @abstract Shared OMIDAdSessionRegistry instance.
 */
+ (OMIDAdSessionRegistry *)getInstance;

/*!
 * @abstract Registers new ad session.
 *
 * @discussion Ad session registry adds provided ad session to adSessions list and sets itself as ad session's delegate.
 *
 * @param adSession New ad session.
 */
- (void)addAdSession:(OMIDAdSession *)adSession;

/*!
 * @abstract Registers observer.
 */
- (void)addStateObserver:(id<OMIDAdSessionRegistryStateObserver>)observer;

@end
