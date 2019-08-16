//
// Created by Daria on 31/08/16.
//

#import <Foundation/Foundation.h>

/*!
 * @discussion This class is responsible executing java script in the particular java script environment.
 */
@protocol OMIDJSExecutor <NSObject>

/*!
 * @abstract A boolean value indicating whether java script could be injected from the background thread.
 */
@property(nonatomic, readonly) BOOL supportBackgroundThread;

/*!
 * @abstract The java script environment responsible for executing java scripts.
 */
@property(nonatomic, readonly) id jsEnvironment;

/*!
 * @abstract Injects java script to java script environment.
 *
 * @param script The script to be executed.
 */
- (void)injectJavaScriptFromString:(NSString *)script;

@end
