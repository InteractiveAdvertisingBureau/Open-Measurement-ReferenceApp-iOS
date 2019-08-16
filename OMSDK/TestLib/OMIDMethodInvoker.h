//
//  OMIDMethodInvoker.h
//  AppVerificationLibrary
//
//  Created by Daria on 10/07/2017.
//

#import <Foundation/Foundation.h>

/*!
 * @discussion Utility to invoke methods in the main thread.
 */
@interface OMIDMethodInvoker : NSObject

/*!
 * @abstract Performs selector in the main thread asynchronously.
 *
 * @discussion When called from the background thread, performs provided selector in the main thread asynchronously. When called from the main thread, performs provided selector synchronously.
 *
 * @param selector The selector to be performed.
 * @param target The object which performs the selector.
 */
+ (void)performSelectorAsync:(SEL)selector target:(id)target;

/*!
 * @abstract Performs selector in the main thread asynchronously.
 *
 * @discussion When called from the background thread, performs provided selector in the main thread asynchronously. When called from the main thread, performs provided selector synchronously.
 *
 * @param selector The selector to be performed.
 * @param target The object which performs the selector.
 * @param argument The argument which is passed to selector.
 */
+ (void)performSelectorAsync:(SEL)selector target:(id)target argument:(id)argument;

/*!
 * @abstract Performs selector in the main thread synchronously.
 *
 * @discussion When called from the background thread, performs provided selector in the main thread synchronously.
 *
 * @param selector The selector to be performed.
 * @param target The object which performs the selector.
 * @param argument The argument which is passed to selector.
 */
+ (void)performSelectorSync:(SEL)selector target:(id)target argument:(id)argument;

@end
