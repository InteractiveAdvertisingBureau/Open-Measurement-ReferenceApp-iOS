//
//  OMIDStringDownloadTask.m
//  AppVerificationLibrary
//
//  Created by Daria on 24/05/2017.
//

#import "OMIDLoadTask.h"

@implementation OMIDLoadTask

+ (NSURLSession *)sharedSession {
    static dispatch_once_t pred = 0;
    __strong static NSURLSession *session;
    dispatch_once(&pred, ^{
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        configuration.requestCachePolicy = NSURLRequestReloadIgnoringCacheData;
        session = [NSURLSession sessionWithConfiguration:configuration delegate:nil delegateQueue:nil];
    });
    return session;
}

+ (OMIDLoadTask *)taskToLoadStringFromURL:(NSURL *)url attemptsCount:(NSUInteger)attemptsCount completionHandler:(OMIDLoadTaskCompletionHandler)completionHandler {
    return [self taskToLoadStringFromURL:url attemptsCount:attemptsCount completionQueue:dispatch_get_main_queue() completionHandler:completionHandler];
}

+ (OMIDLoadTask *)taskToLoadStringFromURL:(NSURL *)url attemptsCount:(NSUInteger)attemptsCount completionQueue:(dispatch_queue_t)completionQueue completionHandler:(OMIDLoadTaskCompletionHandler)completionHandler {
    OMIDLoadTask *task = [[OMIDLoadTask alloc] initWithURL:url attemptsCount:attemptsCount completionQueue:completionQueue];
    task.completionHandler = completionHandler;
    task.responseParser = ^id (NSData *data) {
        return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    };
    return task;
}

+ (OMIDLoadTask *)taskToSendPingToURL:(NSURL *)url completionQueue:(dispatch_queue_t)completionQueue completionHandler:(OMIDLoadTaskCompletionHandler)completionHandler {
    OMIDLoadTask *task = [[OMIDLoadTask alloc] initWithURL:url attemptsCount:1 completionQueue:completionQueue];
    task.completionHandler = completionHandler;
    return task;
}

- (id)initWithURL:(NSURL *)url attemptsCount:(NSUInteger)attemptsCount completionQueue:(dispatch_queue_t)completionQueue {
    self = [super init];
    if (self) {
        _url = url;
        _attemptsCount = attemptsCount;
        _completionQueue = completionQueue;
    }
    return self;
}

- (void)start {
#ifndef TEST
    NSURLSessionDataTask *task = [[OMIDLoadTask sharedSession] dataTaskWithURL:_url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        [self handleResponseWithData:data error:error];
    }];
    [task resume];
#endif
}

- (void)handleResponseWithData:(NSData *)data error:(NSError *)error {
    _attemptNumber++;
    if (error && _attemptNumber < _attemptsCount) {
        [self start];
        return;
    }
    id result = (error) ? nil : (_responseParser) ? _responseParser(data) : data;
    dispatch_async(_completionQueue, ^{
        self.completionHandler(result, error);
    });
}

@end
