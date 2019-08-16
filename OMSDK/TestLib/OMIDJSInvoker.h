//
//  OMIDJSInvoker.h
//  AppVerificationLibrary
//
//  Created by Daria Sukhonosova on 03/08/2017.
//

#import <JavaScriptCore/JavaScriptCore.h>

/*!
 * @discussion OMIDJSInvoker provides a capacity to execute java scripts and java script functions inside JSContext.
 */
@protocol OMIDJSInvoker <NSObject>

/*!
 * @abstract Dispatch queue used to execute java scrips.
 */
@property(nonatomic, readonly) dispatch_queue_t _Nonnull dispatchQueue;

/*!
 * @abstract Executes provided callback. The callback could be a string with java script or a java script function.
 *
 * @param callback The callback.
 */
- (void)invokeCallback:(JSValue *_Nonnull)callback;

/*!
 * @abstract Executes provided callback with argument. The callback could be a string with java script or a java script function. The argument can be error code or JS content.
 *
 * @param callback The callback.
 * @param argument The argument.
 */
- (void)invokeCallback:(JSValue *_Nonnull)callback argument:(nonnull id)argument;

/*!
 * @abstract Executes java script.
 *
 * @param script The java script.
 */
- (void)invokeScript:(NSString *_Nonnull)script;

@end
