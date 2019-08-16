//
//  OMIDManager.h
//  AppVerificationLibrary
//
//  Created by Daria Sukhonosova on 23/07/15.
//

#import <Foundation/Foundation.h>
#import "OMIDAdSessionRegistry.h"
#import "OMIDStateWatcher.h"

/*!
 * @discussion This class is responsible for starting and stopping tree walker and state watcher.
 */
@interface OMIDManager : NSObject<OMIDAdSessionRegistryStateObserver, OMIDStateWatcherDelegate>

/*!
 * @abstract Shared OMIDManager instance.
 */
+ (OMIDManager *)getInstance;

/*!
 * @abstract Performs initial setup.
 */
- (void)setup;

// Private methods

/*!
 * @abstract Starts tree walker and state watcher.
 *
 * @discussion This method is called when ad session registry becomes active.
 */
- (void)start;

/*!
 * @abstract Stops tree walker and state watcher.
 *
 * @discussion This method is called when ad session registry resigns active.
 */
- (void)stop;

@end
