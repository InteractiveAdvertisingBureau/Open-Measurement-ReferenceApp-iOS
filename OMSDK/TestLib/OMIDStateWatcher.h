//
//  OMIDStateWatcher.h
//  AppVerificationLibrary
//
//  Created by Daria Sukhonosova on 23/07/15.
//

#import "OMIDAdSession.h"
#import "OMIDConstants.h"

/*!
 * @discussion State watcher notifies delegate about application state changes.
 */
@protocol OMIDStateWatcherDelegate <NSObject>

/*!
 * @abstract Tells the delegate that the application becomes active.
 */
- (void)appDidBecomeActive;

/*!
 * @abstract Tells the delegate that the application becomes inactive.
 */
- (void)appDidResignActive;

@end


@interface OMIDStateWatcher : NSObject

/*!
 * @abstract A boolean value indicating whether the application is in active state.
 */
@property(nonatomic, readonly) BOOL appIsActive;

/*!
 * @abstract Current application state.
 */
@property(nonatomic, readonly) OMIDAppState appState;

/*!
 * @abstract State watcher's delegate.
 */
@property(nonatomic, weak) id<OMIDStateWatcherDelegate> delegate;

/*!
 * @abstract Shared state watcher instance.
 */
+ (OMIDStateWatcher *)getInstance;

/*!
 * @abstract Starts listening for application state changes.
 */
- (void)start;

/*!
 * @abstract Stops listening for application state changes.
 */
- (void)stop;

/*!
 * @abstract Notifies state watcher that ad session became active.
 *
 * @discussion State watcher publishes current application state to provided ad session.
 *
 * @param adSession The ad session.
 */
- (void)adSessionDidBecomeActive:(OMIDAdSession *)adSession;

@end
