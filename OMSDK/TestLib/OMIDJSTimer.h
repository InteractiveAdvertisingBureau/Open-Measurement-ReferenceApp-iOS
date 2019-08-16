//
//  OMIDJSTimer.h
//  AppVerificationLibrary
//
//  Created by Daria Sukhonosova on 09/03/17.
//

#import <JavaScriptCore/JavaScriptCore.h>
#import "OMIDJSInvoker.h"

/*!
 * @discussion Native implementation of JS timer functions.
 */
@interface OMIDJSTimer : NSObject

/*!
 * @abstract OMIDJSInvoker used to invoke timer callbacks.
 */
@property(nonatomic, weak) id<OMIDJSInvoker> jsInvoker;

@property(nonatomic, readonly) NSMutableSet *timerIds;

/*!
 * @abstract Injects timer bridge methods for provided JS object.
 *
 * @param jsObject The JS object to inject bridge methods.
 */
- (void)setupMethodsForJSObject:(JSValue *)jsObject;

// Private methods

/*!
 * @abstract Creates and schedules new timer.
 *
 * @param timeout The JSValue containing timeout in milliseconds.
 * @param callback The JSValue containing timer callback. It could wrap a string with java script or a java script function.
 * @param repeatable A boolean flag indicating whether the timer is repeating.
 * @return NSNumber containing timer identifier.
 */
- (NSNumber *)scheduleTimerWithTimeout:(JSValue *)timeout callback:(JSValue *)callback repeatable:(BOOL)repeatable;

/*!
 * @abstract Schedules the timer.
 *
 * @param timerId The NSNumber containing timer identifier.
 * @param timeout The timeout in milliseconds.
 * @param callback The JSValue containing timer callback. It could wrap a string with java script or a java script function.
 * @param repeatable A boolean flag indicating whether the timer is repeating.
 */
- (void)scheduleTimerWithId:(NSNumber *)timerId timeout:(double)timeout callback:(JSValue *)callback repeatable:(BOOL)repeatable;

/*!
 * @abstract Executes the timer callback and re-schedules repeatable timer.
 *
 * @discussion This method is called when scheduled timer fires.
 *
 * @param timerId The NSNumber containing timer identifier.
 * @param timeout The timeout in milliseconds.
 * @param callback The JSValue containing timer callback. It could wrap a string with java script or a java script function.
 * @param repeatable A boolean flag indicating whether the timer is repeating.
 */
- (void)handleTimerWithId:(NSNumber *)timerId timeout:(double)timeout callback:(JSValue *)callback repeatable:(BOOL)repeatable;

/*!
 * @abstract Cancels the timer.
 *
 * @param timerId The JSValue containing timer identifier.
 */
- (void)cancelTimerWithId:(JSValue *)timerId;

/*!
 * @abstract Cancels all timers.
 */
- (void)cancelAllTimers;

@end
