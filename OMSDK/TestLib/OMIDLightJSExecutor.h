//
//  OMIDLightJSExecutor.h
//  AppVerificationLibrary
//
//  Created by Daria on 06/03/17.
//

#import <JavaScriptCore/JavaScriptCore.h>
#import <Foundation/Foundation.h>
#import "OMIDJSExecutor.h"
#import "OMIDJSTimer.h"
#import "OMIDJSNetworkBridge.h"
#import "OMIDJSInvoker.h"

@class OMIDJSTimer;

/*!
 * @discussion OMIDJSExecutor implementation for JSContext.
 */
@interface OMIDLightJSExecutor : NSObject<OMIDJSExecutor, OMIDJSInvoker>

/*!
 * @abstract JSContext used to execute java scripts.
 */
@property(nonatomic, readonly) JSContext *jsContext;

/*!
 * @abstract JS timer functions implementation.
 */
@property(nonatomic, readonly) OMIDJSTimer *timer;

/*!
 * @abstract JS networking functions implementation.
 */
@property(nonatomic, readonly) OMIDJSNetworkBridge *networkBridge;

/*!
 * @abstract Dispatch queue used to execute java scrips.
 */
@property(nonatomic, readonly) dispatch_queue_t dispatchQueue;

/*!
 * @abstract Factory method for creating OMIDLightJSExecutor instances.
 *
 * @return New OMIDLightJSExecutor instance.
 */
+ (OMIDLightJSExecutor *)lightJSExecutor;

/*!
 * @abstract Initializes new instance with provided JS timer and JS networkBridge.
 *
 * @param timer The JS timer.
 * @param networkBridge The network bridge.
 * @return New OMIDLightJSExecutor instance.
 */
- (id)initWithTimer:(OMIDJSTimer *)timer networkBridge:(OMIDJSNetworkBridge *)networkBridge;

@end
