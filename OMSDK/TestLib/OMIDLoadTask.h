//
//  OMIDStringDownloadTask.h
//  AppVerificationLibrary
//
//  Created by Daria on 24/05/2017.
//

#import <Foundation/Foundation.h>

typedef id (^OMIDResponseParser) (NSData *data);
typedef void (^OMIDLoadTaskCompletionHandler) (id response, NSError *error);

/*!
 * @discussion OMIDLoadTask is responsible for sending network requests.
 */
@interface OMIDLoadTask : NSObject

/*!
 * @abstract The request URL.
 */
@property(nonatomic, readonly) NSURL *url;

/*!
 * @abstract The maximum attempts which task could do to send the request.
 *
 * @discussion The task makes several attempts to send the request before invoking completion handler with error. Value of this property limits the attempts count.
 */
@property(nonatomic, readonly) NSUInteger attemptsCount;

/*!
 * @abstract The number of made attempts to send the request.
 */
@property(nonatomic, readonly) NSUInteger attemptNumber;

/*!
 * @abstract The dispatch queue for invoking completion handler.
 */
@property(nonatomic, readonly) dispatch_queue_t completionQueue;

/*!
 * @abstract A block object used to convert the response to another format before invoking completion handler.
 */
@property(nonatomic, copy) OMIDResponseParser responseParser;

/*!
 * @abstract A block object to be executed once the request is complete.
 */
@property(nonatomic, copy) OMIDLoadTaskCompletionHandler completionHandler;

/*!
 * @abstract Creates a new task which download the string from provided URL.
 * @param url The URL.
 * @param attemptsCount The maximum number of attempts.
 * @param completionHandler A block object to be executed once the request is complete
 */
+ (OMIDLoadTask *)taskToLoadStringFromURL:(NSURL *)url attemptsCount:(NSUInteger)attemptsCount completionHandler:(OMIDLoadTaskCompletionHandler)completionHandler;

/*!
 * @abstract Creates a new task which download the string from provided URL.
 * @param url The URL.
 * @param attemptsCount The maximum number of attempts.
 * @param completionQueue The dispatch queue to  invoke completion handler.
 * @param completionHandler The block object to be executed once the request is complete
 */
+ (OMIDLoadTask *)taskToLoadStringFromURL:(NSURL *)url attemptsCount:(NSUInteger)attemptsCount completionQueue:(dispatch_queue_t)completionQueue completionHandler:(OMIDLoadTaskCompletionHandler)completionHandler;

/*!
 * @abstract Creates a new task which sends a ping to provided URL.
 * @param url The URL.
 * @param completionQueue The dispatch queue to  invoke completion handler.
 * @param completionHandler The block object to be executed once the request is complete
 */
+ (OMIDLoadTask *)taskToSendPingToURL:(NSURL *)url completionQueue:(dispatch_queue_t)completionQueue completionHandler:(OMIDLoadTaskCompletionHandler)completionHandler;

/*!
 * @abstract Starts the task.
 */
- (void)start;

@end
